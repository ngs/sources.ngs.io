rails = $.rails
_fire = rails.fire
modal = null

createModal = () ->
  $("body").append('<div class="modal hide fade" id="confirm-modal">
    <div class="modal-header">
      <a class="close" data-dismiss="modal">&times;</a>
      <h3>Confirmation</h3>
    </div>
    <div class="modal-body">
      <p class="modal-message"></p>
    </div>
    <div class="modal-footer">
      <a href="#" class="btn" data-dismiss="modal">Cancel</a>
      <a href="#" class="btn btn-danger" data-submit-modal="modal">OK</a>
    </div>
  </div>')
  modal = $("#confirm-modal")

rails.fire = fire = (obj, name, data) ->
  if name == 'confirm'
    message = obj.data 'confirm'
    (modal||createModal())
      .modal({ backdrop: true, keyboard: true, show: true })
      .one "hide", () ->
        btnSubmit.unbind "click"
        false
    btnSubmit = modal
      .find("a[data-submit-modal]")
      .one "click", () ->
        if obj.is rails.linkDisableSelector
          rails.disableElement obj
        if obj.data('remote') != undefined && rails.handleRemote(obj) == false
          rails.enableElement obj
        else if obj.data 'method'
          rails.handleMethod obj
        modal.unbind("hide").modal("hide")
        false
    modal
      .find(".modal-message")
      .html(obj.data("confirm"))
    false
  else
    _fire.apply this, [obj, name, data]