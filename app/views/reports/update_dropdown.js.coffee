$("#<%= @org_type.downcase %>_section").closest('.form-group').show()
$("#<%= @org_type.downcase %>_section").html('<%= escape_javascript(select_tag @org_type.downcase, options_from_collection_for_select(@organizations, "id", "name"), include_blank: "Select A #{@org_type}", "data-live-search" => true, class: "selectpicker form-control", id: "#{@org_type.downcase}_select") %>')
$('.selectpicker').selectpicker('refresh')

$('#')
