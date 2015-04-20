class Fulfillment < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid

  belongs_to :line_item

  has_many :components, as: :composable
  has_many :notes, as: :notable
  has_many :documents

  delegates :quantity_type, :line_item

end
