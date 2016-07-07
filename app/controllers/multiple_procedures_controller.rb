class MultipleProceduresController < ApplicationController

  before_action :find_procedures, only: [:complete_all, :incomplete_all, :update_procedures]
  before_action :save_original_procedure_status, only: [:update_procedures]

  def complete_all
    @procedure_ids = params[:procedure_ids]
  end

  def incomplete_all
    @note = Note.new(kind: 'reason')
  end

  def update_procedures
    NoteCreator.new(@procedures, params, current_identity, @original_procedure_status).create_note_before_update
    @core_id = @procedures.first.sparc_core_id
    status = params[:status]

    if status == 'incomplete'
      #Create test note for validation.
      # @note = Note.new(kind: 'reason', reason: params[:reason], notable_type: 'Procedure')

      # if @note.valid?
        #Now update all @procedures with incomplete status and create notes.
      @performed_by = params[:performed_by]
      @procedures.each do |procedure|
        procedure.update_attributes(status: "incomplete", performer_id: @performed_by)
      end
    elsif status == 'complete'
      #Mark all @procedures as complete.
      @performed_by = params[:performed_by]
      @procedures.each{|procedure| procedure.update_attributes(status: 'complete', performer_id: @performed_by, completed_date: params[:completed_date])}
      @completed_date = params[:completed_date]
    end
  end

  def reset_procedures
    @appointment = Appointment.find(params[:appointment_id])
    #Status is used by the 'show' re-render
    @statuses = @appointment.appointment_statuses.map{|x| x.status}

    #Reset parent appointment
    @appointment.update_attributes(start_date: nil, completed_date: nil)
    #Remove custom procedures from appointment
    @appointment.procedures.where(visit_id: nil).each{|proc| proc.destroy_regardless_of_status}
    #Reset all procedures under appointment
    @appointment.procedures.each{|procedure| procedure.reset}

    @refresh_dashboard = true

    render 'appointments/show'
  end

  private

  def find_procedures
    @procedures = Procedure.where(id: params[:procedure_ids])
  end

  def save_original_procedure_status
    @original_procedure_status = []
    @procedures.each do |procedure|
      @original_procedure_status << procedure.status
    end
  end
end
