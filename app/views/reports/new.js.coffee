$("#modal_area").html("<%= escape_javascript(render(partial: @report_type, locals: { title: @title, report_type: @report_type })) %>")
$("#modal_place").modal('show')
$('#start_date').datetimepicker(format: 'MM-DD-YYYY')
$('#end_date').datetimepicker(format: 'MM-DD-YYYY')
$('select#organization_select').multiselect({})
$('select#organization_select').multiSelect('select_all')
$(".modal-content .selectpicker").selectpicker()

update_organization_dropdown = (org_ids) ->
  data = { org_ids: org_ids }
  $.ajax
    url: '/reports/update_dropdown'
    data: data
    dataType: "script"
$ ->
  
  # $('core_names')
  # $('core_ids')
  # $('.selectpicker').selectpicker()
  # $('.selectpicker').selectpicker('refresh')
	$('select#organization_select').on 'change', ->
    # $('.selectpicker').selectpicker()
    # $('.selectpicker').selectpicker('refresh')
    console.log($(this).val())
    # update_organization_dropdown($(this).val())
  

	# $('#institution_select').on 'change', ->
	# 	console.log("institution selected")
	# 	data = {institution_id: $('#institution_select').val()}
	# 	console.log(data)
	# 	$.ajax
	# 		type: 'PUT'
	# 		url: '/reports/update_providers'
	# 		data: data
	# 		dataType: "script"
	# 	console.log()

	# $('#provider_select').on 'change', ->
	# 	console.log("provider selected")
	# 	data = {provider_id: $('#provider_select').val()}
	# 	console.log(data)
	# 	$.ajax
	# 		url: '/reports/update_programs'
	# 		data: data
	# 		dataType: "script"

