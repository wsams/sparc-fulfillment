class StudyScheduleController < ApplicationController
  def change_page
    @page = params[:page]
    @arm = Arm.find params[:arm_id]
    @protocol = @arm.protocol
    @tab = params[:tab]
    @visit_groups = @arm.visit_groups.paginate(page: @page)
  end

  def change_tab
    @protocol = Protocol.find(params[:protocol_id])
    @arms_and_pages = {}
    hash = params[:arms_and_pages]
    hash.each do |arm_id, page|
      arm = Arm.find(arm_id)
      @arms_and_pages[arm_id] = {arm: arm, page: page}
    end
    @tab = params[:tab]
  end

  def check_row
    @check = params[:check]
    @line_item_id = params[:line_item_id]
    qty = (@check == 'true' ? 1 : 0)
    visits = Visit.where(line_item_id: @line_item_id)
    visits.update_all(research_billing_qty: qty, insurance_billing_qty: 0, effort_billing_qty: 0)
    visits.each do |visit|
      visit.update_procedures qty.to_i, 'research_billing_qty'
      visit.update_procedures 0, 'insurance_billing_qty'
    end
  end

  def check_column
    @check = params[:check]
    @visit_group_id = params[:visit_group_id]
    qty = (@check == 'true' ? 1 : 0)
    visits = Visit.where(visit_group_id: @visit_group_id)
    visits.update_all(research_billing_qty: qty, insurance_billing_qty: 0, effort_billing_qty: 0)
    visits.each do |visit|
      visit.update_procedures qty.to_i, 'research_billing_qty'
      visit.update_procedures 0, 'insurance_billing_qty'
    end
  end
end
