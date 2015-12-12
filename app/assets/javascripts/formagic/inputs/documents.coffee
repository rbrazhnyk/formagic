# -----------------------------------------------------------------------------
# Author: Alexander Kravets <alex@slatestudio.com>,
#         Slate Studio (http://www.slatestudio.com)
# -----------------------------------------------------------------------------
# INPUT "NESTED" FORM
# -----------------------------------------------------------------------------
# Name for this input comes from the Rails gem 'nested_forms'.
#
# Public methods:
#   initialize()
#   hash(hash)
#   updateValue(@value)
#   showErrorMessage(message)
#   hideErrorMessage()
#   addNewForm(object)
#
# Dependencies:
#= require ./documents_reorder
# -----------------------------------------------------------------------------
class @InputForm
  constructor: (@name, @nestedObjects, @config, @object) ->
    @forms = []

    @config.namePrefix         ||= name
    @config.removeButton         = if @config.disableRemoveDocuments then false else true
    @config.ignoreOnSubmission ||= false

    @reorderContainerClass = "nested-forms-#{@config.klassName}"

    if @config.ignoreOnSubmission
      for key, inputConfig of @config.formSchema
        inputConfig.ignoreOnSubmission = true

    @_create_el()

    @_add_label()
    @_add_forms()
    @_add_new_button()

    return this

  # PRIVATE ===================================================================

  _create_el: ->
    @$el =$ "<div class='form-input nested-forms input-#{ @config.klassName }'>"

  _add_label: ->
    @$label =$ "<span class='label'></span>"
    @$labelTitle =$ "<span class='label-title'>#{ @config.label }</span>"
    @$errorMessage =$ "<span class='error-message'></span>"
    @$label.append @$labelTitle
    @$label.append @$errorMessage
    @$el.append @$label

  _extend_schema_with: (name, config) ->
    schemaConfig = {}
    schemaConfig[name] = config
    @config.formSchema = $.extend(schemaConfig, @config.formSchema)

  _add_forms: ->
    # add id to schema
    # @NOTE: here we use _id, cause mongosteen returns objects _id, but we should send id for nested documents
    @_extend_schema_with('_id', { type: 'hidden', name: 'id', ignoreOnSubmission: @config.ignoreOnSubmission })

    # add position to schema
    if @config.sortBy
      @_extend_schema_with(@config.sortBy, { type: 'hidden', ignoreOnSubmission: @config.ignoreOnSubmission })

    @$forms =$ "<ul>"
    @$label.after @$forms

    # if not default value which means no objects
    if @nestedObjects != ''
      @_sort_nested_objects()

      for i, object of @nestedObjects
        namePrefix = "#{ @config.namePrefix }[#{ i }]"
        @forms.push @_render_form(object, namePrefix, @config)

      @_bind_forms_reorder()

  _sort_nested_objects: ->
    if @config.sortBy
      if @nestedObjects
        # this is not required but make things a bit easier on the backend
        # as object don't have to be in a specific order.
        @nestedObjects.sort (a, b) => parseFloat(a[@config.sortBy]) - parseFloat(b[@config.sortBy])
        # normalizes nested objects positions
        (o[@config.sortBy] = parseInt(i) + 1) for i, o of @nestedObjects

  _render_form: (object, namePrefix, config) ->
    formConfig = $.extend {}, config,
      namePrefix: namePrefix
      rootEl:     "<li>"

    form = new Form(object, formConfig)
    @$forms.append form.$el

    return form

  _add_new_button: ->
    if ! @config.disableNewDocuments
      label = @config.newButtonLabel || "Add"

      @$newButton =$ """<a href='#' class='nested-form-new'>#{ label }</a>"""
      @$el.append @$newButton

      @$newButton.on 'click', (e) => e.preventDefault() ; @addNewForm()

  # PUBLIC ====================================================================

  initialize: ->
    @config.beforeInitialize?(this)

    for nestedForm in @forms
      nestedForm.initializePlugins()

    @config.onInitialize?(this)

  hash: (hash={}) ->
    objects = []
    objects.push(form.hash()) for form in @forms
    hash[@config.fieldName] = objects
    return hash

  showErrorMessage: (message) ->
    @$el.addClass 'error'
    @$errorMessage.html(message)

  hideErrorMessage: ->
    @$el.removeClass 'error'
    @$errorMessage.html('')

  addNewForm: (object=null) ->
    namePrefix    = "#{ @config.namePrefix }[#{ Date.now() }]"
    newFormConfig = $.extend({}, @config)

    delete newFormConfig.formSchema._id

    form = @_render_form(object, namePrefix, newFormConfig)
    form.initializePlugins()

    if @config.sortBy
      @_add_form_reorder_button(form)
      prevForm = _last(@forms)
      position = if prevForm then prevForm.inputs[@config.sortBy].value + 1 else 1

      # Had a problem here for new documents, but now seems to be resolved by adding
      # _position to schema in constructor (to be removed when stable).

      form.inputs[@config.sortBy].updateValue(position)

    @forms.push(form)

    @config.onNew?(form)

    return form

  updateValue: (@nestedObjects, @object) ->
    # New document should update id, also after uploading images form for existing
    # document might change, so we reset all nested forms to reflect these updates.
    # This implementation has some problems with jumping screen when using plugins
    # also it requires complex implementation for data local storage caching.
    @$forms.remove()
    @forms = []
    @_add_forms()

    # Initialize input plugins after update
    for nestedForm in @forms
      nestedForm.initializePlugins()

include(InputForm, inputFormReorder)

chr.formInputs['form']      = InputForm
chr.formInputs['documents'] = InputForm
