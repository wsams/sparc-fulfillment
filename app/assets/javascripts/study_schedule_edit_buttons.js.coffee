$ ->

  if $("body.protocols-show").length > 0
    # initialize visit group select list
    change_arm()

    $(document).on 'change', '#arms', ->
      change_arm()


    $(document).on 'click', '#remove_visit_button', ->
      calendar_tab = $('#current_tab').attr('value')
      visit_group_id = $("#visits").val()
      protocol_id = $('#arms').data('protocol_id')
      arm_id = $("#arms").val()
      page = $("#visits_select_for_#{arm_id}").val()
      del = confirm "Are you sure you want to delete the selected visit from all particpants?"
      if del
        $.ajax
          type: 'DELETE'
          url: "/protocols/#{protocol_id}/arms/#{arm_id}/visit_groups/#{visit_group_id}.js?page=#{page}&calendar_tab=#{calendar_tab}"

    $(document).on 'click', '#add_arm_button', ->
      protocol_id = $('#arms').data('protocol_id')
      $.ajax
        type: 'GET'
        url: "/protocols/#{protocol_id}/arms/new"

    $(document).on 'click', '#remove_arm_button', ->
      protocol_id = $('#arms').data('protocol_id')
      arm_id = $("#arms").val()
      del = confirm "Are you sure you want to delete the selected arm from this protocol"
      if del
        $.ajax
          type: 'DELETE'
          url: "/protocols/#{protocol_id}/arms/#{arm_id}"


    $(document).on 'click', '#add_visit_button', ->
      calendar_tab = $('#current_tab').attr('value')
      protocol_id = $('#arms').data('protocol_id')
      arm_id = $('#arms').val()
      page = $("#visits_select_for_#{arm_id}").val()
      $.get "/protocols/#{protocol_id}/arms/#{arm_id}/visit_groups/new?page=#{page}&calendar_tab=#{calendar_tab}"

    $(document).on 'click', '#add_service_button', ->
      calendar_tab = $('#current_tab').attr('value')
      page_hash = {}
      $(".visit_dropdown.form-control").each (index) ->
        key = $(this).data('arm_id')
        value = $(this).attr('page')
        page_hash[key] = value
      data =
        'page_hash': page_hash
        'calendar_tab': calendar_tab
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      $.ajax
        type: 'GET'
        url: "/multiple_line_items/#{protocol_id}/#{service_id}/new"
        data: data

    $(document).on 'click', '#remove_service_button', ->
      calendar_tab = $('#current_tab').attr('value')
      page_hash = {}
      $(".visit_dropdown.form-control").each (index) ->
        key = $(this).data('arm_id')
        value = $(this).attr('page')
        page_hash[key] = value
      data =
        'page_hash': page_hash
        'calendar_tab': calendar_tab
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      $.ajax
        type: 'GET'
        url: "/multiple_line_items/#{protocol_id}/#{service_id}/edit"
        data: data

    $(document).on 'change', "#service_id", ->
      if $('#header_text').val() == 'Remove Services'
        service_id = $(this).find('option:selected').val()
        change_service service_id

(exports ? this).change_service = (service_id) ->
  protocol_id = $('#arms').data('protocol_id')
  $.ajax
    type: 'GET'
    url: "/multiple_line_items/#{protocol_id}/#{service_id}/necessary_arms"

(exports ? this).create_arm = (name, id) ->
  $select = $('#arms')
  $select.append('<option value=' + id + '>' + name + '</option>')
  $select.selectpicker('refresh')

(exports ? this).change_arm = ->
  $select = $('#visits')
  protocol_id = $('#arms').data('protocol_id')
  arm_id = $('#arms').val()

  $.get "/protocols/#{protocol_id}/arms/#{arm_id}/change", (data) ->
    visit_groups = data
    $select.find('option').remove()

    $.each visit_groups, (key, visit_group) ->
      $select.append('<option value=' + visit_group.id + '>' + visit_group.name + '</option>')

    $select.selectpicker('refresh')

(exports ? this).remove_arm = (arm_id) ->
  $select = $('#arms')
  $select.find("[value=#{arm_id}]").remove()
  $select.selectpicker('refresh')
  $(".calendar.service.arm_#{arm_id}").remove()

