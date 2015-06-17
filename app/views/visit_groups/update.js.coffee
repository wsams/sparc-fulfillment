$("#modal_errors").html("<%= escape_javascript(render(partial: 'modal_errors', locals: {errors: @errors})) %>");

<% if @visit_group.errors[:name].any? %>
# reset name field, if there was a validation error
$("#visit_group_<%= @visit_group.id %>").val("<%= @visit_group.reload.name %>")
error_tooltip_on("#visit_group_<%= @visit_group.id %>", "Name " + "<%= raw(@visit_group.errors[:name][0]) %>")
<% end %>

<% unless @errors %>
$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
edit_visit_group_name("<%= @visit_group.name %>", "<%= @visit_group.id %>");
$("#visit-before-display-<%= @visit_group.id %>").html("<%= @visit_group.window_before %>")
$("#visit-after-display-<%= @visit_group.id %>").html("<%= @visit_group.window_after %>")
$("#visit-day-display-<%= @visit_group.id %>").html("<%= @visit_group.day %>")
<% end %>
