# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class Organization < ActiveRecord::Base

  include SparcShard

  before_save :compute_lft_and_rgt

  belongs_to :parent, class_name: "Organization"

  has_many :services,
            -> {where(is_available: true)}
  has_many :sub_service_requests
  has_many :protocols, through: :sub_service_requests
  has_many :pricing_setups
  has_many :super_users
  has_many :clinical_providers

  has_many :children, class_name: "Organization", foreign_key: :parent_id

  # Returns this organization's pricing setup that is effective on a given date.
  def effective_pricing_setup_for_date(date=Date.today)
    if self.pricing_setups.blank?
      raise ArgumentError, "Organization has no pricing setups" if self.parent.nil?
      return self.parent.effective_pricing_setup_for_date(date)
    end

    current_setups = self.pricing_setups.select { |x| x.effective_date.to_date <= date.to_date }

    raise ArgumentError, "Organization has no current effective pricing setups" if current_setups.empty?
    sorted_setups = current_setups.sort { |lhs, rhs| lhs.effective_date <=> rhs.effective_date }
    pricing_setup = sorted_setups.last

    return pricing_setup
  end

  def inclusive_child_services(scope)
    Service.
      send(scope).
      joins(:organization).
      where("(process_ssrs = 0 AND organizations.lft > ? AND organizations.rgt < ?) OR (organizations.id = ?)", lft, rgt, id).
      order(:name)
  end

  def all_child_organizations
    Organization.where("lft > ? AND rgt < ?", lft, rgt).
      order(lft: :asc)
  end

  def child_orgs_with_protocols
    all_child_organizations.joins(:protocols).distinct
  end

  private

  def compute_lft_and_rgt
    if parent_id_changed? || !id
      new_parent = Organization.find_by(id: parent_id)
      if new_parent
        self.lft = new_parent.rgt
        self.rgt = self.lft + 1
        Organization.where('rgt >= ?', self.lft).update_all('rgt = rgt + 2')
        Organization.where('lft > ?', self.lft).update_all('lft = lft + 2')
      else
        last_rgt = Organization.maximum(:rgt) || 0
        self.lft = last_rgt + 1
        self.rgt = self.lft + 1
      end
    end
  end
end
