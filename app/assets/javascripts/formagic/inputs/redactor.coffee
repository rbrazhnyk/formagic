# -----------------------------------------------------------------------------
# Author: Alexander Kravets <alex@slatestudio.com>,
#         Slate Studio (http://www.slatestudio.com)
# -----------------------------------------------------------------------------
# INPUT REDACTOR
# -----------------------------------------------------------------------------
# Dependencies:
#= require vendor/redactor.table
#= require vendor/redactor.fixedtoolbar
#= require ./redactor_character
# -----------------------------------------------------------------------------
class @InputRedactor extends InputString
  # PRIVATE ===================================================================

  _add_input: ->
    @$el.css('opacity', 0)
    @$input =$ "<textarea class='redactor' name='#{ @name }' rows=1>#{ @_safe_value() }</textarea>"
    @$el.append @$input

  # PUBLIC ====================================================================

  initialize: ->
    @config.beforeInitialize?(this)

    @$input.redactor(@_redactor_options())

    @$el.css('opacity', 1)

    @config.onInitialize?(this)

  updateValue: (@value) ->
    @_trigger_change = false
    @$input.redactor('code.set', @value)

include(InputRedactor, redactorCharacter)

chr.formInputs['redactor'] = InputRedactor
