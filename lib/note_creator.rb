class NoteCreator
  def initialize(procedures, params, current_identity, original_procedure_status)
    @current_identity = current_identity
    @procedures = procedures
    @params = params
    @params[:procedure] ? @params = procedure_params : ''
    @original_procedure_status = original_procedure_status
  end

  def create_note_before_update
    if reset_status_detected?
      @procedures.each do |procedure|
        procedure.notes.create(identity: @current_identity,
                                comment: 'Status reset',
                                kind: 'log')
      end
    elsif incomplete_status_detected?
      @procedures.each do |procedure|
        procedure.notes.create(identity: @current_identity,
                                comment: 'Status set to incomplete',
                                kind: 'reason', 
                                reason: @params[:reason], 
                                comment: @params[:comment])
      end
    elsif change_in_completed_date_detected?
      @procedures.each do |procedure|
        procedure.notes.create(identity: @current_identity,
                                comment: "Completed date updated to #{@params[:completed_date]} ",
                                kind: 'log')
      end
    elsif complete_status_detected?
      @procedures.each do |procedure|
        procedure.notes.create(identity: @current_identity,
                                comment: 'Status set to complete',
                                kind: 'log')
      end
    elsif change_in_performer_detected?
      new_performer = Identity.find(@params[:performed_by] || @params[:performer_id])
      @procedures.each do |procedure|
        procedure.notes.create(identity: @current_identity,
                                comment: "Performer changed to #{new_performer.full_name}",
                                kind: 'log')
      end
    end
  end

  def change_in_completed_date_detected?
    if @params[:completed_date]
      Time.strptime(@params[:completed_date], "%m/%d/%Y") != @procedures.first.completed_date
    else
      return false
    end
  end

  def reset_status_detected?
    @params[:status] == "unstarted"
  end

  def incomplete_status_detected?
    @params[:status] == "incomplete"
  end

  def complete_status_detected?
    !@original_procedure_status.include?('complete') &&@params[:status] == "complete"
  end

  def change_in_performer_detected?
    @params[:performed_by].present? && (@params[:performed_by] || @params[:performer_id]) != @procedures.first.performer_id
  end

  def procedure_params
    @params.
      require(:procedure).
      permit(:status,
             :follow_up_date,
             :completed_date,
             :billing_type,
             :performer_id,
             notes_attributes: [:comment, :kind, :identity_id, :reason],
             tasks_attributes: [:assignee_id, :identity_id, :body, :due_at])
  end
end