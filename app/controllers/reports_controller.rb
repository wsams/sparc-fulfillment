class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]
  before_action :find_report_type, only: [:new, :create]

  def new

    @title = @report_type.titleize
    @institutions = current_identity.clinical_provider_organizations.where(type: "Institution")
    # @institutions = Organization.where(type: "Institution")
    # @providers = Organization.where(type: "Provider").limit(2)
    # @programs = Organization.where(type: "Program").limit(2)
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

  def update_providers
    puts "update_providers"
    institution_id = (params[:institution_id]).to_i
    puts institution_id.inspect()
    @providers = Organization.where(type: "Provider").where(parent_id: institution_id)
    puts @providers.inspect()

  end

  def update_programs
    puts "update_programs"
    provider_id = (params[:provider_id]).to_i
    @programs = Organization.where(type: "Program").where(parent_id: provider_id)
    puts @programs.inspect()
  end

  def update_cores
    puts "update_cores"
    program_id = (params[:program_id]).to_i
    @cores = Organization.where(type: "Core").where(parent_id: program_id)
    puts @cores.inspect()
  end
  

  private

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
              :protocol_id,
              :participant_id,
              :documentable_id,
              :documentable_type,
              :protocol_ids => []).merge(identity_id: current_identity.id)
  end
end
