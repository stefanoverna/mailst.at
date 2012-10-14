
$ ->

  refreshPage = (context) ->
    $("[data-toggle-dom]:visible", context).each ->
      $(this).change(->
        $(this).parents(".fields").find(".rename-folder").toggle $(this).is(":checked")
      ).change()
    $("select:visible", context).chosen()

  $(document).on 'nested:fieldAdded', (event) ->
    refreshPage(event.field)

  $(document).on 'ajaxSend', (event) ->
    refreshPage(document)

  refreshPage(document)

