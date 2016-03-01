class ReportsController < ApplicationController

  before_action :find_documentable, only: [:create]
  before_action :find_report_type, only: [:new, :create]

  def new

    # @title = @report_type.titleize
    # @institutions = current_identity.organization_lookup("Institution")
    # @protocols = current_identity.protocols
    # @fulfillment_organizations = current_identity.fulfillment_organizations

    institutions = current_identity.fulfillment_organizations.select{|org| org.type == "Institution"}
    institution_names = institutions.map(&:name)
    institution_ids = institutions.map(&:id)
    
    providers = current_identity.fulfillment_organizations.select{|org| org.type == "Provider"}
    provider_names = providers.map(&:name)
    provider_ids = providers.map(&:id)
    
    programs = current_identity.fulfillment_organizations.select{|org| org.type == "Program"}
    program_names = programs.map(&:name)
    program_ids = programs.map(&:id)
    
    cores = current_identity.fulfillment_organizations.select{|org| org.type == "Core"}
    core_names = cores.map(&:name)
    core_ids = cores.map(&:id)

    

    @grouped_options = [
      ['Institutions',
        organization_name_id_to_array(institution_names, institution_ids)],
      ['Providers',
        organization_name_id_to_array(provider_names, provider_ids)],
      ['Programs',
        organization_name_id_to_array(program_names, program_ids)],
      ['Cores',
        organization_name_id_to_array(core_names, core_ids)]
    ]
    

    # @organizations = current_identity.fulfillment_organizations
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
    # if params[:org_type]
    #   @org_type = params[:org_type]
    #   @organizations = current_identity.organization_lookup(@org_type)
    #   puts "******"
    #   puts @org_type
    #   puts @organizations.size()
    # end
    @protocols = find_protocols(params[:org_ids])
    puts "^^^^^"
    puts @protocols.size()
  end

  def organization_name_id_to_array(org_names, org_ids)
    org_name_id_array = []
    org_names.each_with_index do |name, index|
      org_name_id_array << [name, org_ids[index]]
    end
    return org_name_id_array
  end

  private

  def find_protocols(org_ids)
    binding.pry
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
