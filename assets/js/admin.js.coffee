$(document).ready(() ->
  $(".row-edit").parents('td').click(() ->
    console.log("CLICK")
    me = $(this)
    tr = me.parents('tr')
    parent = me.parents('table')
    tblname = parent.data('tblname')
    id = tr.data('id')
    window.location.href = "/admin/db/#{tblname}/#{id}"
  )

  $(".form-json-editor").each(() ->
    try
      me = $(this)
      textarea = $("textarea[data-editor='#{me.attr('id')}']")
      editor = (((id) ->
        console.log(id)
        return new JSONEditor(document.getElementById(id))).bind(window, me.attr('id')))()
      editor.set(JSON.parse(textarea.val()))

      updater = ((textarea, editor) ->
        textarea.val(JSON.stringify(editor.get()))).bind(null, textarea, editor)
      $('#dataform').submit(updater)
      $(editor.frame).keyup(updater).mouseup(updater).focusout(updater)

      inv_updater = ((textarea, editor) ->
        editor.set(JSON.parse(textarea.val()))
        editor.expandAll()
      ).bind(null, textarea, editor)

      textarea.keyup(inv_updater).mouseup(inv_updater)
    catch err
      console.log(err)
  )
)
