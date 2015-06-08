# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->

  $(document).on 'click', '.page_change_arrow', ->
    data =
      'arm_id': $(this).data('arm_id'),
      'page'  : $(this).attr('page'),
      'tab'   : $('#current_tab').val()
    $.ajax
      type: 'GET'
      url:  '/service_calendar/change_page'
      data: data

  $(document).on 'change', '.visit_dropdown', ->
    page = $(this).find('option:selected').attr('parent_page')
    cur_page = $(this).attr('page')
    tab = $('#current_tab').val()
    if page == undefined || page == false
      page = $(this).val()

    # Early out when selecting a visit that is already shown
    if page == cur_page
      $(this).val(page)
      return

    data =
      'arm_id': $(this).data('arm_id')
      'page'  : page
      'tab'   : tab
    $.ajax
      type: 'GET'
      url:  '/service_calendar/change_page'
      data: data

  $(document).on 'click', '#service_calendar_tabs a', ->
    protocol_id = $(this).data('protocol')
    tab = $(this).data('tab')
    $('#current_tab').val(tab)
    arms_and_pages = {}

    $('.visit_dropdown.selectpicker').each ->
      page = $(this).val()

      arm_id = $(this).data('arm_id')
      arms_and_pages[arm_id] = page

    data =
      'arms_and_pages': arms_and_pages,
      'tab'   : tab
      'protocol_id' : protocol_id
    $.ajax
      type: 'GET'
      url:  '/service_calendar/change_tab'
      data: data

  $(document).on 'change', '.visit', ->
    visit_id = $(this).val()
    research = + $(this).prop('checked') # unary operator '+' evaluates true/false to num
    data = 'visit':
      'research_billing_qty':  research,
      'insurance_billing_qty': 0,
      'effort_billing_qty': 0
    $.ajax
      type: 'PUT'
      url:  "/visits/#{visit_id}"
      data: data

  # Add a tooltip to elt (e.g., "#visits_219_insurance_billing_qty")
  # containing content, which disappears when user focuses to it.
  window.error_tooltip_on = (elt, content) ->
    $elt = $(elt)
    $elt.attr('data-toggle', 'tooltip').attr('title', content)
    $elt.tooltip({container: 'body'})
    $elt.tooltip('show')
    delay = (ms, func) -> setTimeout func, ms
    delay 3000, -> $elt.tooltip('destroy')

  $(document).on 'change', '.quantity', ->
    visit_id = $(this).attr('visit_id')
    quantity = $(this).val()
    qty_type = $(this).attr('qty_type')

    data = 'visit':
      "#{qty_type}": quantity
    $.ajax
      type: 'PUT'
      url:  "/visits/#{visit_id}"
      data: data

  $(document).on 'change', '.visit_name', ->
    visit_group_id = $(this).data('visit_group_id')
    name = $(this).val()
    data = 'visit_group' : 'name' : name
    $.ajax
      type: 'PUT'
      url:  "/visit_groups/#{visit_group_id}"
      data: data

  $(document).on 'click', '.change_line_item_service', ->
    line_item_id = $(this).attr('line_item_id')
    $.ajax
      type: 'GET'
      url: "/line_items/#{line_item_id}/edit"

  $(document).on 'click', '.check_row', ->
    check = $(this).attr('check')
    line_item_id = $(this).data('line_item_id')
    data =
      'line_item_id': line_item_id,
      'check':        check
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/check_row'
      data: data
      success: =>
        # Check off visits
        # Update text fields
        identifier = ".visits_for_line_item_#{line_item_id}"
        if check == 'true'
          check_row_column($(this), identifier, 'glyphicon-ok', 'glyphicon-remove', 'false', true, 1, 0)
        else
          check_row_column($(this), identifier, 'glyphicon-remove', 'glyphicon-ok', 'true', false, 0, 0)

  $(document).on 'click', '.check_column', ->
    check = $(this).attr('check')
    visit_group_id = $(this).attr('visit_group_id')
    data =
      'visit_group_id': visit_group_id,
      'check':        check
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/check_column'
      data: data
      success: =>
        # Check off visits
        # Update text fields
        identifier = ".visit_for_visit_group_#{visit_group_id}"
        if check == 'true'
          check_row_column($(this), identifier, 'glyphicon-ok', 'glyphicon-remove', 'false', true, 1, 0)
        else
          check_row_column($(this), identifier, 'glyphicon-remove', 'glyphicon-ok', 'true', false, 0, 0)

  check_row_column = (obj, identifier, remove_class, add_class, attr_check, prop_check, research_val, insurance_val) ->
    obj.removeClass(remove_class).addClass(add_class)
    obj.attr('check', attr_check)
    $("#{identifier} input[type=checkbox]").prop('checked', prop_check)
    $("#{identifier} input[type=text].research").val(research_val)
    $("#{identifier} input[type=text].insurance").val(insurance_val)

  (exports ? this).change_service = (service_id) ->
    protocol_id = $('#arms').data('protocol_id')
    data =
      'protocol_id': protocol_id
      'service_id': service_id
    $.ajax
      type: 'GET'
      url: "/multiple_line_items/necessary_arms"
      data: data

  # Use cookie to remember study schedule tab
  current_tab = $.cookie("active-schedule-tab")
  if current_tab && current_tab.length > 0
    $(".schedule-tab > a[href='##{current_tab}']").click() # show tab on load

  $('.schedule-tab > a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    tab = String(e.target).split("#")[1]
    $.cookie("active-schedule-tab", tab, expires: 1, path: '/') # save tab to cookie
