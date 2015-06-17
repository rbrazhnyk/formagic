# -----------------------------------------------------------------------------
# Author: Alexander Kravets <alex@slatestudio.com>,
#         Slate Studio (http://www.slatestudio.com)
#
# Coding Guide:
#   https://github.com/thoughtbot/guides/tree/master/style/coffeescript
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# INPUT HTML
# -----------------------------------------------------------------------------
#
# Config options:
#   label      - Input label
#   aceOptions - Custom options for overriding default ones
#
# Input config example:
#   body_html: { type: 'html', label: 'Article' }
#
# Dependencies:
#= require vendor/ace
#= require vendor/mode-html
#
# -----------------------------------------------------------------------------

class @InputHtml extends InputString

  # PRIVATE ===============================================

  _add_input: ->
    @$input =$ "<input type='hidden' name='#{ @name }' value='#{ @_safe_value() }' />"
    @$el.append @$input

    @$editor =$ "<div></div>"
    @$el.append @$editor


  _update_inputs: ->
    @value = @editor.getSession().getValue()
    @$input.val(@value)
    @$input.trigger('change')


  # PUBLIC ================================================

  initialize: ->
    @config.beforeInitialize?(this)

    @editor = ace.edit(@$editor.get(0))
    @editor.$blockScrolling = Infinity

    @session = @editor.getSession()
    @session.setValue(@$input.val())
    @session.setUseWrapMode(true)
    @session.setMode("ace/mode/html")

    # ace options: https://github.com/ajaxorg/ace/wiki/Configuring-Ace
    @editor.setOptions
      autoScrollEditorIntoView: true
      minLines:                 5
      maxLines:                 Infinity
      showLineNumbers:          false
      showGutter:               false
      highlightActiveLine:      false
      showPrintMargin:          false

    @session.on 'change', (e) => @_update_inputs()

    @config.onInitialize?(this)


  updateValue: (@value) ->
    @editor.getSession().setValue(@value)
    @$input.val(@value)


chr.formInputs['html'] = InputHtml




