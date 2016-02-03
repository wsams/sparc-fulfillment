$("#modal_area").html("<%= escape_javascript(render(partial: @report_type, locals: { title: @title, report_type: @report_type })) %>")
$("#modal_place").modal('show')
$('#start_date').datetimepicker(format: 'MM-DD-YYYY')
$('#end_date').datetimepicker(format: 'MM-DD-YYYY')
$(".modal-content .selectpicker").selectpicker()

$ ->

$(document).on 'change', '#institution_select', ->
	$.ajax
		url: "#{update_providers_reports_path}"
		data: institution_id: $('#institution_select').val()
		dataType: "script"