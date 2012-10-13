#= require spin

$ ->
  $("[data-check-mailbox-verification]").each ->
    id = $(this).data("check-mailbox-verification")

    spinner = new Spinner().spin(this)

    statusCheck = (cb)->
      $.ajax
        url: "/mailboxes/#{id}"
        dataType: "json"
        success: (data) ->
          if not data.mailbox.credentials_verified
            after 3000, -> statusCheck(cb)
          else
            spinner.stop()
            cb()
        error: ->
          console.log "FOCK"

    statusCheck -> document.location.reload(true)
