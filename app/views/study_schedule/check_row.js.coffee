button = $(".check_row[data-line-item-id='<%= @line_item_id %>']")

if "<%= @check %>" == "true"
  button.removeClass("glyphicon-ok").addClass("glyphicon-remove")
  button.attr('check', 'false')
  button.attr('title', I18n["visit"]["uncheck_row"])
  $(".visits_for_line_item_<%= @line_item_id %> input[type=checkbox]").prop('checked', true)
  $(".visits_for_line_item_<%= @line_item_id %> input[type=text].research").val(1)
else
  button.removeClass("glyphicon-remove").addClass("glyphicon-ok")
  button.attr('check', 'true')
  button.attr('title', I18n["visit"]["check_row"])
  $(".visits_for_line_item_<%= @line_item_id %> input[type=checkbox]").prop('checked', false)
  $(".visits_for_line_item_<%= @line_item_id %> input[type=text].research").val(0)

button.tooltip('destroy').tooltip()
$(".visits_for_line_item_<%= @line_item_id %> input[type=text].insurance").val(0)