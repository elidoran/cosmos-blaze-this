# reactively get a data context, current=0, parent=1+
getData = (count = 0) -> Template.parentData count

# build the new `this` based on the usual stuff and the options
createThis = (options) ->
  that =
    template: options?.template ? Template.instance()
    data    : options?.data ? Template.instance().data
    getData : getData
  that.Template = that.template.view.template

  if options?.autosub
    that.autorun = (fn) -> that.template.autorun fn
    that.subscribe = (args...) -> that.template.subscribe args...

  return that

# create a new function which wraps the specified one and uses the special this
wrap = (fn, options) ->
  wrapped = (args...) ->
    that = createThis options

    if options?.event then that.event = args?[0]

    # put args in `this` if they exist, and, check for Spacebars.kw()
    if args.length > 0
      that.args = args
      lastArg = args[args.length - 1]
      if lastArg?.hash?
        that.hash = lastArg.hash
        args.pop() # remove the hash from the args array

    fn.apply that, that.args

  wrapped.isWrapped = true
  return wrapped

# hold the original functions from prototype so we can call them
replaceReferences = Template.profiles.$replaceReferences
originals =
  profiles   : Template.profiles
  helpers    : Template::helpers
  functions  : Template::functions
  onCreated  : Template::onCreated
  onRendered : Template::onRendered
  onDestroyed: Template::onDestroyed

# wraps functions in object and then pass to previous implementation
wrapFns = (which, options) ->
  fn = (fns) ->
    for own name,fn of fns when typeof(fn) is 'function'
      fns[name] = wrap fn, options unless fn?.isWrapped
    originals[which].call this, fns
  return fn

# wrap a function and then call the previous implementation
wrapFn = (which, options) ->
  return (fn) ->
    fn = wrap fn, options if typeof(fn) is 'function' and not fn.isWrapped
    originals[which].call this, fn
    return

# wrap functions when they are added to the profile, except event handlers:
# instead, events are wrapped as they are added to a template instance,
# because it completely overrides the Template::events function,
# because that function does its own wrapping, so, instead of wrapping a
# function to provide to Meteor which will then wrap it,
# we're overriding it completely to wrap it the way we want,
# then, there's only one wrapping
Template.profiles = (newProfiles) ->
  for own profileName,profile of newProfiles
    for own groupType,group of profile
      options = if groupType in ['onCreated', 'onRendered'] then autosub:true else undefined

      unless groupType is 'events'
        for own name,fn of group
          if typeof(fn) is 'function' and not fn.isWrapped
            group[name] = wrap fn, options

  originals.profiles.call this, newProfiles

# we're clobbering Template.profiles, so, best maintain its hidden properties
Template.profiles.$ = originals.profiles.$
Template.profiles.$replaceReferences = originals.profiles.$replaceReferences

# new instance functions which wrap things before calling the other implementations
Template::helpers     = wrapFns 'helpers'
Template::functions   = wrapFns 'functions'
Template::onCreated   = wrapFn 'onCreated', autosub:true
Template::onRendered  = wrapFn 'onRendered', autosub:true
Template::onDestroyed = wrapFn 'onDestroyed'

# completely replace the function `events`. why have them do all this work to
# call it with a different `this` then desired
Template::events = (object) ->
  object = replaceReferences 'events', object
  eventMap = {}

  for own key, fn of object
    eventMap[key] = do (fn) ->
      wrapped = (args...) ->
        template = this.templateInstance()
        data = Blaze.getData(args[0].currentTarget) ? {}
        args.splice 1, 0, template
        templateGetter = this.templateInstance.bind this
        Template._withTemplateInstanceFunc templateGetter, ->
          # instead of using `data` as the this, use our `that`
          that = createThis template:template, data:data
          that.event = args?[0]
          that.args  = args
          fn.apply that, that.args
      wrapped.isWrapped = true
      return wrapped

  @__eventMaps.push eventMap
