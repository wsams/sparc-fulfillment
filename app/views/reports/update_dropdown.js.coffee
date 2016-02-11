$("#<%= @org_type.downcase %>_section").closest('.form-group').show()
$("#<%= @org_type.downcase %>_section").html('<%= escape_javascript(select_tag @org_type.downcase, options_from_collection_for_select(@organizations, "id", "name"), include_blank: "Select All", "data-live-search" => true, class: "selectpicker form-control", id: "#{@org_type.downcase}_select") %>')
$('.selectpicker').selectpicker('refresh')

$('#protocol_section').empty()
$('#protocol_section').html('<%= escape_javascript(select_tag "protocol_ids", options_from_collection_for_select(@protocols, "id", "short_title_with_sparc_id"), include_blank: "Select All", "data-live-search" => true, class: "selectpicker form-control", id: "protocol_select") %>')
$('.selectpicker').selectpicker('refresh')