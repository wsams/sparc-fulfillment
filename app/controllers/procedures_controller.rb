class ProceduresController < ApplicationController

  before_action :find_procedure, only: [:edit, :update, :destroy]
  before_action :save_original_procedure_status, only: [:update]

  def create
    @appointment = Appointment.find params[:appointment_id]
    qty             = params[:qty].to_i
    service         = Service.find params[:service_id]
    performer_id    = params[:performer_id]
    @procedures     = []

    qty.times do
      @procedures << Procedure.create(appointment: @appointment,
                                      service_id: service.id,
                                      service_name: service.name,
                                      performer_id: performer_id,
                                      billing_type: 'research_billing_qty',
                                      sparc_core_id: service.sparc_core_id,
                                      sparc_core_name: service.sparc_core_name)
    end
  end

  def edit
    @task = Task.new
    if params[:partial].present?
      @note = @procedure.notes.new(kind: 'reason')
      render params[:partial]
    else
      @clinical_providers = ClinicalProvider.where(organization_id: current_identity.protocols.map{|p| p.sub_service_request.organization_id })
      render
    end
  end

  def update
    NoteCreator.new([@procedure], params, current_identity, @original_procedure_status).create_note_before_update
    @procedure.update_attributes(procedure_params)
    @appointment = @procedure.appointment
    @statuses = @appointment.appointment_statuses.map{|x| x.status}
  end

  def destroy
    @procedure.destroy
  end

  private

  def save_original_procedure_status
    @original_procedure_status = @procedure.status
  end

  def procedure_params
    params.
      require(:procedure).
      permit(:status,
             :follow_up_date,
             :completed_date,
             :billing_type,
             :performer_id,
             notes_attributes: [:comment, :kind, :identity_id, :reason],
             tasks_attributes: [:assignee_id, :identity_id, :body, :due_at])
  end

  def find_procedure
    @procedure = Procedure.find params[:id]
  end
end
