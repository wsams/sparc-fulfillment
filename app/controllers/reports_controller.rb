class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]
  before_action :find_report_type, only: [:new, :create]

  def new

    @title = @report_type.titleize
    @institutions = current_identity.organization_lookup("Institution")
    @protocols = current_identity.protocols
  end

  def create
    @document = Document.new(title: reports_params[:title].humanize, report_type: @report_type)
    @report = @report_type.classify.constantize.new(reports_params)

    @errors = @report.errors
    
    if @report.valid?
      @reports_params = reports_params
      @documentable.documents.push @document
      ReportJob.perform_later(@document, reports_params)
    end
  end

  def update_dropdown
    if params[:org_type]
      @org_type = params[:org_type]
      @organizations = current_identity.organization_lookup(@org_type)
      puts "******"
      puts @org_type
      puts @organizations.size()
    end
    @protocols = find_protocols(params[:org_ids])
    puts "^^^^^"
    puts @protocols.size()
  end

  private

  def find_protocols(org_ids)
    orgs = Array.wrap(Organization.find(org_ids))
    orgs_with_children = orgs.map{|x| x.all_child_organizations(true)}.flatten + orgs.flatten
    org_protocols = orgs_with_children.map(&:protocols).flatten
    current_identity.protocols.select{|protocol| org_protocols.include?(protocol)}
  end

  def find_documentable
    if params[:documentable_id].present? && params[:documentable_type].present?
      @documentable = params[:documentable_type].constantize.find params[:documentable_id]
    else
      @documentable = current_identity
    end
  end

  def find_report_type
    @report_type = reports_params[:report_type]
  end

  def reports_params
    params.require(:report_type) # raises error if report_type not present

    params.permit(:format,
              :utf8,
              :report_type,
              :title,
              :start_date,
              :end_date,
              :time_zone,
              :protocol_id,
              :participant_id,
              :documentable_id,
              :documentable_type,
              :protocol_ids => []).merge(identity_id: current_identity.id)
  end
end
