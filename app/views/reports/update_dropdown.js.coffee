$("#<%= @org_type.downcase %>_section").closest('.form-group').show()
$("#<%= @org_type.downcase %>_section").html('<%= escape_javascript(select_tag @org_type.downcase, options_from_collection_for_select(@organizations, "id", "name"), multiple: true, include_blank: "Select All", "data-live-search" => true, class: "selectpicker form-control", id: "#{@org_type.downcase}_select") %>')
$('.selectpicker').selectpicker('refresh')

$('#protocol_section').empty()
$('#protocol_section').html('<%= escape_javascript(select_tag "protocol_ids", options_from_collection_for_select(@protocols, "id", "short_title_with_sparc_id"), multiple: true, include_blank: "Select All", "data-live-search" => true, class: "selectpicker form-control", id: "protocol_select") %>')
$('.selectpicker').selectpicker('refresh')


$('select#provider_select').on 'change', ->
  update_organization_dropdown("Program", $(this).val())

$('select#program_select').on 'change', ->
  update_organization_dropdown("Core", $(this).val())

$('select#core_select').on 'change', ->
  # update_organization_dropdown("Core", $(this).val())
  data = {org_ids: $(this).val()}
  $.ajax
    url: '/reports/update_dropdown'
    data: data
    dataType: "script"

update_organization_dropdown = (org_type, org_ids) ->
  data = {org_type: org_type, org_ids: org_ids}
  $.ajax
    url: '/reports/update_dropdown'
    data: data
    dataType: "script"