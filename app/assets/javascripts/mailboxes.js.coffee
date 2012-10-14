#= require spin

$ ->

  $("[data-toggle-dom]").each ->
    $(this).change(->
      $("[data-toggable=#{$(this).data("toggle-dom")}]").toggle $(this).is(":checked")
    ).change()

  $("select:visible").chosen()

  $(document).on 'nested:fieldAdded', (event) ->
    $("select", event.field).chosen()

