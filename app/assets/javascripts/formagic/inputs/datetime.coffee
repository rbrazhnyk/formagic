# -----------------------------------------------------------------------------
# Author: Alexander Kravets <alex@slatestudio.com>,
#         Slate Studio (http://www.slatestudio.com)
#
# Coding Guide:
#   https://github.com/thoughtbot/guides/tree/master/style/coffeescript
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# INPUT DATE
# -----------------------------------------------------------------------------
#
# Dependencies:
#= require vendor/datedropper
#= require vendor/moment
#
# -----------------------------------------------------------------------------
class @InputDatetime extends InputDate

  # PRIVATE ===============================================

  _update_value: ->
    mt = moment(@$inputTime.val(), 'LT')

    if @$inputDate.val() == '' && ! mt.isValid()
      @$input.val('')
      return

    if ! mt.isValid()
      mt = moment('1:00 pm', 'LT')

    time_string = mt.utcOffset(@tzOffset).format().split('T')[1]
    date_string = @$inputDate.val()

    value = [ date_string, time_string ].join('T')

    @$input.val(value)


  _update_date_input: ->
    m = moment(@$input.val()).utcOffset(@tzOffset)
    @$inputDate.val ( if m.isValid() then m.format('YYYY-MM-DD') else '' )


  _update_time_input: ->
    m = moment(@$input.val()).utcOffset(@tzOffset)
    @$inputTime.val ( if m.isValid() then m.format('h:mm a') else '' )


  _update_date_label: ->
    m = moment(@$inputDate.val()).utcOffset(@tzOffset)
    label = if m.isValid() then m.format('dddd, MMM D, YYYY') else "<span class='placeholder'>Pick a date</span>"
    @$dateLabel.html label


  _normalized_value: ->
    # -- use local timezone to represent time
    @tzOffset  = @config.timezoneOffset
    @tzOffset ?= (new Date()).getTimezoneOffset() * -1

    m = moment(@value).utcOffset(@tzOffset)
    @value = if m.isValid() then m.format() else ''


  _add_input: ->
    @_normalized_value()

    # -- hidden
    @$input =$ "<input type='hidden' name='#{ @name }' value='#{ @value }' />"
    @$el.append @$input

    # -- date
    @$inputDate =$ "<input type='text' class='input-datetime-date' />"
    @$el.append @$inputDate
    @$inputDate.on 'change', (e) =>
      @_update_date_label()
      @_update_value()

    @_update_date_input()

    # -- date label
    @$dateLabel =$ "<div class='input-date-label'>"
    @$el.append @$dateLabel
    @$dateLabel.on 'click', (e) => @$inputDate.trigger 'click'

    @_update_date_label()

    # -- @
    @$el.append "<span class='input-timedate-at'>@</span>"

    # -- time
    @$inputTime =$ "<input type='text' class='input-datetime-time' placeholder='1:00 pm' />"
    @$el.append @$inputTime
    @$inputTime.on 'change, keyup', (e) => @_update_value() ; @$input.trigger('change')

    @_update_time_input()

    @_add_actions()


  _add_actions: ->
    @$actions =$ "<span class='input-actions'></span>"
    @$label.append @$actions

    @_add_remove_button()


  _add_remove_button: ->
    @$removeBtn =$ "<a href='#' class='remove'>Remove</a>"
    @$actions.append @$removeBtn

    @$removeBtn.on 'click', (e) =>
      e.preventDefault()
      @$inputTime.val('')
      @$inputDate.val('')
      @_update_date_label()
      @_update_value()


  # PUBLIC ================================================

  initialize: ->
    @config.beforeInitialize?(this)

    # http://felicegattuso.com/projects/datedropper/
    @config.pluginConfig ?= {}

    config =
      animation:       'fadein'
      format:          'Y-m-d'
      animate_current: false
      textColor:       '#333'
      borderColor:     '#f6f6f6'
      boxShadow:       '0 0 2px rgba(0, 0, 0, 0.2)'
      borderRadius:    4
      maxYear:         2020

    $.extend(config, @config.pluginConfig)

    @$inputDate.dateDropper(config)

    @config.onInitialize?(this)


  updateValue: (@value) ->
    @_normalized_value()
    @$input.val(@value)

    @_update_date_input()
    @_update_date_label()
    @_update_time_input()


chr.formInputs['datetime'] = InputDatetime




