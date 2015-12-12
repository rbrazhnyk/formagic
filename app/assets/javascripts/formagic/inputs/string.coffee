# -----------------------------------------------------------------------------
# Author: Alexander Kravets <alex@slatestudio.com>,
#         Slate Studio (http://www.slatestudio.com)
# -----------------------------------------------------------------------------
# INPUT STRING
# -----------------------------------------------------------------------------
# Basic string input implementation, this is base class for many chr inputs.
# This input also serves as a demo for implementing other input types.
#
# Public methods:
#   initialize()              - run input plugin initializations if any
#   hash(hash)                - update hash with inputs: hash[name] = value
#   updateValue(@value)       - update inputs value
#   showErrorMessage(message) - show error (validation) message for input
#   hideErrorMessage()        - hide error message
#
# Dependencies:
#= require vendor/jquery.typeahead
# -----------------------------------------------------------------------------
class @InputString
  constructor: (@name, @value, @config, @object) ->
    @_create_el()
    @_add_label()
    @_add_input()
    @_add_placeholder()
    @_add_disabled()
    @_add_required()
    @_add_limit()

    return this

  # PRIVATE ===================================================================

  _safe_value: ->
    if typeof(@value) == 'object'
      return JSON.stringify(@value)
    else
      return _escapeHtml(@value)

  _create_el: ->
    @$el =$ "<label for='#{ @name }' class='#{ @config.klass } input-#{ @config.type } input-#{ @config.klassName }'>"

  _add_label: ->
    @$label =$ "<span class='label'>"
    @$labelTitle =$ "<span class='label-title'>#{ @config.label }</span>"
    @$errorMessage =$ "<span class='error-message'></span>"
    @$label.append(@$labelTitle)
    @$label.append(@$errorMessage)
    @$el.append(@$label)

    if @config.label == false
      @$label.hide()

  _add_input: ->
    @$input =$ """
      <input type='text' id='#{ @name }' name='#{ @name }' value='#{ @_safe_value() }' />
    """
    # trigger change event on keyup so value is cached while typing
    @$input.on 'keyup', (e) => @$input.trigger('change')
    @$el.append @$input

    if @config.options and $.isArray(@config.options)
      data = new Bloodhound
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
        queryTokenizer: Bloodhound.tokenizers.whitespace
        local:          $.map @config.options, (opt) -> { value: opt }

      data.initialize()

      @$input.typeahead({
        hint:      true
        highlight: true
        minLength: 1
      },
      {
        name:       'options'
        displayKey: 'value'
        source:     data.ttAdapter()
      })

  _add_placeholder: ->
    @$input.attr 'placeholder', @config.type

    if @config.placeholder
      @$input.attr 'placeholder', @config.placeholder

  _add_disabled: ->
    if @config.disabled
      @$input.prop('disabled', true)
      @$el.addClass('input-disabled')

  _add_required: ->
    if @config.required
      @$el.addClass('input-required')

  _add_limit: ->
    if @config.limit
      @$charCounter =$ "<span class='input-character-counter'></span>"
      @$errorMessage.before @$charCounter
      @$input.on 'keyup', =>
        @_update_character_counter()
      @_update_character_counter()

  _update_character_counter: ->
    characters = @$input.val().length
    left       = @config.limit - characters

    if left >= 0
      @$charCounter.html("(#{ left } left)")

    else
      @$charCounter.html("(#{ left })")

    if characters > @config.limit
      @$charCounter.addClass('exceeds')
    else
      @$charCounter.removeClass('exceeds')

  # PUBLIC ====================================================================

  initialize: ->
    @config.onInitialize?(this)

  hash: (hash={}) ->
    hash[@config.klassName] = @$input.val()
    return hash

  updateValue: (@value) ->
    @$input.val(@value)

  showErrorMessage: (message) ->
    @$el.addClass('error')
    @$errorMessage.html(message)

  hideErrorMessage: ->
    @$el.removeClass('error')
    @$errorMessage.html('')

chr.formInputs['string'] = InputString
