button = $(".check_column[data-visit-group-id='<%= @visit_group_id %>']")
visit_identifier = ".visit_for_visit_group_<%= @visit_group_id %>"

if "<%= @check %>" == "true"
  button.removeClass("glyphicon-ok").addClass("glyphicon-remove")
  button.attr('check', 'false').attr('title', I18n["visit"]["uncheck_column"])
  $("#{visit_identifier} input[type=checkbox]").prop('checked', true)
  $("#{visit_identifier} input[type=text].research").val(1)
else
  button.removeClass("glyphicon-remove").addClass("glyphicon-ok")
  button.attr('check', 'true').attr('title', I18n["visit"]["check_column"])
  $("#{visit_identifier} input[type=checkbox]").prop('checked', false)
  $("#{visit_identifier} input[type=text].research").val(0)

button.tooltip('destroy').tooltip()
$("#{visit_identifier} input[type=text].insurance").val(0)