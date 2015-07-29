$ ->

##              **BEGIN MANAGE ARMS**                     ##

    $(document).on 'click', '#add_arm_button', ->
      data =
        "protocol_id" : $('#manage_arms').data('protocol-id')
        "schedule_tab" : $('#current_tab').attr('value')
      $.ajax
        type: 'GET'
        url: "/arms/new"
        data: data

    $(document).on 'click', '#remove_arm_button', ->
      arm_id = $('#manage_arms').data('first-arm')
      $.ajax
        type: 'GET'
        url: "/arms/#{arm_id}/edit"
        data: "intended_action" : "destroy"

    $(document).on 'click', '#remove_arm_form_button', ->
      # Ensure there are at least two arms in dropdown
      # so that protocol always has at least one arm.
      # Arms are deleted through a delayed job, so
      # we need the count from the dropdown and not
      # the server.
      arm_select = $("#remove_arm_select")
      if $("#remove_arm_select > option").size() > 1
        protocol_id = $('#manage_arms').data('protocol-id')
        arm_id = arm_select.val()
        arm_name = $(".bootstrap-select > button[data-id='remove_arm_select']").attr('title')
        if confirm "Are you sure you want to remove arm: #{arm_name} from this protocol?"
          $.ajax
            type: 'DELETE'
            url: "/arms/#{arm_id}?protocol_id=#{protocol_id}"
      else
        alert("Cannot remove the last Arm for this Protocol. All Protocols must have at least one Arm.")

    $(document).on 'click', '#edit_arm_button', ->
      arm_id = $('#manage_arms').data('first-arm')
      $.ajax
        type: 'GET'
        url: "/arms/#{arm_id}/edit"
        data: "intended_action" : "edit"

    $(document).on 'change', "#edit_arm_select", ->
      arm_id = $(this).val()
      $.ajax
        type: 'GET'
        url: "/arms/#{arm_id}/edit"
        data: "intended_action" : "edit"

##              **END MANAGE ARMS**                     ##
##          **BEGIN MANAGE VISIT GROUPS**               ##


    $(document).on 'click', '#add_visit_group_button', ->
      current_page = $(".visit_dropdown").first().attr('page')
      protocol_id = $('#manage_arms').data('protocol-id')
      schedule_tab = $('#current_tab').attr('value')
      data =
        'current_page': current_page
        'schedule_tab': schedule_tab
        'protocol_id' : protocol_id
      $.ajax
        type: 'GET'
        url: "/visit_groups/new"
        data: data

    $(document).on 'click', '#edit_visit_group_button', ->
      visit_group_id = $('#visits').val()
      protocol_id = $('#arms').data('protocol_id')
      data =
        'protocol_id'    : protocol_id
        'visit_group_id' : visit_group_id
      $.ajax
        type: 'GET'
        url: "/visit_groups/#{visit_group_id}/edit"
        data: data

    $(document).on 'click', '#remove_visit_group_button', ->
      schedule_tab = $('#current_tab').attr('value')
      visit_group_id = $("#visits").val()
      arm_id = $('#arms').val()
      page = $("#visits_select_for_#{arm_id}").val()
      del = confirm "Are you sure you want to delete the selected visit from all particpants?"
      data =
        'page': page
        'schedule_tab': schedule_tab
      if del
        $.ajax
          type: 'DELETE'
          url: "/visit_groups/#{visit_group_id}.js"
          data: data

##          **END MANAGE VISIT GROUPS**               ##
##          **BEGIN MANAGE LINE ITEMS**               ##


    $(document).on 'click', '#add_service_button', ->
      schedule_tab = $('#current_tab').attr('value')
      page_hash = {}
      $(".visit_dropdown.form-control").each (index) ->
        key = $(this).data('arm_id')
        value = $(this).attr('page')
        page_hash[key] = value
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      data =
        'page_hash': page_hash
        'schedule_tab': schedule_tab
        'protocol_id': protocol_id
        'service_id': service_id
      $.ajax
        type: 'GET'
        url: "/multiple_line_items/new_line_items"
        data: data

    $(document).on 'click', '#remove_service_button', ->
      schedule_tab = $('#current_tab').attr('value')
      page_hash = {}
      $(".visit_dropdown.form-control").each (index) ->
        key = $(this).data('arm_id')
        value = $(this).attr('page')
        page_hash[key] = value
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      data =
        'page_hash': page_hash
        'schedule_tab': schedule_tab
        'protocol_id': protocol_id
        'service_id': service_id
      $.ajax
        type: 'GET'
        url: "/multiple_line_items/edit_line_items"
        data: data




    $(document).on 'change', "#service_id", ->
      if $('#header_text').val() == 'Remove Services'
        service_id = $(this).find('option:selected').val()
        change_service service_id

    $(document).on 'change', '#visit_group_arm_id', ->
      arm_id = $(this).find('option:selected').val()
      update_visit_group_form_page(arm_id)
      data =
        'arm_id': arm_id
      $.ajax
        type: 'GET'
        url: '/visit_groups/update_positions_on_arm_change'
        data: data

##          **END MANAGE LINE ITEMS**               ##



(exports ? this).update_visit_group_form_page = (arm_id) ->
  page = $("#visits_select_for_#{arm_id}").val()
  $("#current_page").val(page)

(exports ? this).change_service = (service_id) ->
  protocol_id = $('#arms').data('protocol_id')
  data =
    'protocol_id': protocol_id
    'service_id': service_id
  $.ajax
    type: 'GET'
    url: "/multiple_line_items/necessary_arms"
    data: data

(exports ? this).edit_visit_group_name = (name, id) ->
  $(".visit_dropdown option[value=#{id}]").text("- #{name}") #update page dropdown
  $(".visit_dropdown").selectpicker('refresh')
  $("#visits option[value=#{id}]").text("#{name}") #update manage visits dropdown
  $("#visits").selectpicker('refresh')
  $("#visit_group_#{id}").val("#{name}")

(exports ? this).remove_visit_group = (visit_group_id) ->
  $select = $('#visits')
  $select.find("[value=#{visit_group_id}]").remove()
  $select.selectpicker('refresh')
  $(".study_schedule.service.visit_group_#{visit_group_id}").remove()

# Add a tooltip to elt (e.g., "#visits_219_insurance_billing_qty")
# containing content, which disappears after about 3 seconds.
(exports ? this).error_tooltip_on = (elt, content) ->
  $elt = $(elt)
  $elt.attr('data-toggle', 'tooltip').attr('title', content)
  $elt.tooltip({container: 'body'})
  $elt.tooltip('show')
  delay = (ms, func) -> setTimeout func, ms
  delay 3000, -> $elt.tooltip('destroy')
