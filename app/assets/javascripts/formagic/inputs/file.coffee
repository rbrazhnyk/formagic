# -----------------------------------------------------------------------------
# Author: Alexander Kravets <alex@slatestudio.com>,
#         Slate Studio (http://www.slatestudio.com)
# -----------------------------------------------------------------------------
# INPUT FILE
# -----------------------------------------------------------------------------
# @TODO: add clear button when file is picked for the first time and you want
#        to cancel that pick
# -----------------------------------------------------------------------------
class @InputFile extends InputString
  constructor: (@name, @value, @config, @object) ->
    @_create_el()

    @_add_label()
    @_add_input()
    @_update_state()
    @_add_required()
    @_add_disabled()

    return this

  # PRIVATE ===================================================================

  _create_el: ->
    @$el =$ "<div class='form-input input-#{ @config.type } input-#{ @config.klassName }'>"

  _add_input: ->
    @$link =$ "<a href='#' target='_blank' title=''></a>"
    @$el.append(@$link)

    @$input =$ "<input type='file' name='#{ @name }' id='#{ @name }'>"
    @$el.append @$input

    @_add_clear_button()
    @_add_remove_checkbox()

  _add_clear_button: ->
    @$clearButton =$ "<a href='#' class='input-file-clear'></a>"
    @$input.after @$clearButton
    @$clearButton.hide()

    @$clearButton.on 'click', (e) =>
      # clear file input:
      # http://stackoverflow.com/questions/1043957/clearing-input-type-file-using-jquery
      @$input.replaceWith(@$input = @$input.clone(true))
      @$clearButton.hide()
      e.preventDefault()

    @$input.on 'change', (e) =>
      @$clearButton.show()

  _add_remove_checkbox: ->
    removeInputName     = @removeName()
    @$removeLabel       =$ "<label for='#{ removeInputName }'>Remove</label>"
    @$hiddenRemoveInput =$ "<input type='hidden' name='#{ removeInputName }' value='false'>"
    @$removeInput       =$ "<input type='checkbox' name='#{ removeInputName }' id='#{ removeInputName }' value='true'>"
    @$link.after(@$removeLabel)
    @$link.after(@$removeInput)
    @$link.after(@$hiddenRemoveInput)

  _update_inputs: ->
    @$link.html(@filename).attr('title', @filename).attr('href', @value.url)

  _update_state: (@filename=null) ->
    @$input.val('')
    @$removeInput.prop('checked', false)

    if @value.url
      @filename = _last(@value.url.split('/'))
      if @filename == '_old_' then @filename = null # carrierwave filename workaround

    if @filename
      @$el.removeClass('empty')
      @_update_inputs()

    else
      @$el.addClass('empty')
      @$clearButton.hide()

  # PUBLIC ====================================================================

  # when no file uploaded and no file selected, send remove flag so
  # carrierwave does not catch _old_ value
  isEmpty: ->
    ( ! @$input.get()[0].files[0] && ! @filename )

  removeName: ->
    @name.reverse().replace('[', '[remove_'.reverse()).reverse()

  updateValue: (@value, @object) ->
    @_update_state()

  hash: (hash={})->
    # @TODO: file input type does not support caching and versioning as of now
    return hash

chr.formInputs['file'] = InputFile
