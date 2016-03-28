class ArmsController < ApplicationController

  respond_to :json, :html
  before_action :find_arm, only: [:destroy, :refresh_vg_dropdown]

  def new
    @protocol = Protocol.find(params[:protocol_id])
    @services = @protocol.line_items.map(&:service).uniq
    @arm = Arm.new(protocol: @protocol)
    @schedule_tab = params[:schedule_tab]
  end

  def create
    @arm                      = Arm.new(arm_params)
    @arm_visit_group_creator  = ArmVisitGroupsImporter.new(@arm)
    arm_creator = ArmCreator.new(@arm, params[:services])
    if @arm_visit_group_creator.save_and_create_dependents
      arm_creator.create_arm
      set_schedule_tab_and_flash_success
    else
      @errors = @arm_visit_group_creator.arm.errors
    end
  end

  def update
    @arm = Arm.find(params[:id])
    if @arm.update_attributes(arm_params)
      flash[:success] = t(:arm)[:flash_messages][:updated]
    else
      @errors = @arm.errors
    end
  end

  def destroy
    if Arm.where("protocol_id = ?", params[:protocol_id]).count == 1
      @arm.errors.add(:protocol, "must have at least one Arm.")
      @errors = @arm.errors
    elsif @arm.appointments.map{|a| a.has_completed_procedures?}.include?(true) # don't delete if arm has completed procedures
      @arm.errors.add(:arm, "'#{@arm.name}' has completed procedures and cannot be deleted")
      @errors = @arm.errors
    else
      @arm.delay.destroy
      flash.now[:alert] = t(:arm)[:deleted]
    end
  end

  def navigate_to_arm
    # Used in study schedule management for navigating to a arm.
    @protocol = Protocol.find(params[:protocol_id])
    @intended_action = params[:intended_action]
    @arm = params[:arm_id].present? ? Arm.find(params[:arm_id]) : @protocol.arms.first
  end

  private

  def set_schedule_tab_and_flash_success
    flash.now[:success] = t(:arm)[:created]
    @schedule_tab = params[:schedule_tab]
  end

  def arm_params
    params.require(:arm).permit(:protocol_id, :name, :visit_count, :subject_count)
  end

  def find_arm
    @arm = Arm.find(params[:id])
  end
end
