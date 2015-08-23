$(document).ready ->
  $('#table_view').on 'change', ->
    $('#meta_table_search_form').submit()
    false