# reactively get a data context, current=0, parent=1+
getData = (count = 0) -> Template.parentData count

# build the new `this` based on the usual stuff and the options
createThis = (options) ->
  that =
    template: options?.template ? Template.instance()
    data    : options?.data ? Template.instance().data
    getData : getData
    __isThat: true
  that.Template = that.template.view.template

  if options?.autosub
    that.autorun = (fn) -> that.template.autorun fn
    that.subscribe = (args...) -> that.template.subscribe args...

  return that

# create a new function which wraps the specified one and uses the special this
wrap = (fn, options) ->
  # was using (args...), but, I ran into trouble with a library which did not
  # provide the arguments to the function when its length was zero (no args)
  # using a splat means there are no args and the length is zero, so, I wasn't
  # getting the args I need.
  # So, instead, i'll put an arg there, and then grab the args to put into an
  # array manually...
  wrapped = (_) ->

    # if we're already in the "that" `this` then use it
    that = if this.__isThat then this else createThis options

    args = []
    args.push arguments[index] for index in [0...arguments.length]
    that.args = args

    if options?.event then that.event = _ # our args[0]

    # put args in `this` if they exist, and, check for Spacebars.kw()
    if args.length > 0
      lastArg = args[args.length - 1]
      if lastArg?.hash?
        that.hash = lastArg.hash
        args.pop() # remove the hash from the args array

    fn.apply that, that.args

  wrapped.isWrapped = true
  return wrapped

# hold the original functions from prototype so we can call them
originals =
  profiles   : Template.profiles
  helpers    : Template::helpers
  events     : Template::events
  functions  : Template::functions
  onCreated  : Template::onCreated
  onRendered : Template::onRendered
  onDestroyed: Template::onDestroyed

# wraps functions in object and then pass to previous implementation
wrapFns = (which, wrapOptions) ->
  fn = (fns) ->
    if fns.$options?.this # only wrap when told to
      for own name,fn of fns when typeof(fn) is 'function'
        fns[name] = wrap fn, wrapOptions unless fn?.isWrapped
    originals[which].call this, fns
  return fn

# wrap a function and then call the previous implementation
wrapFn = (which, wrapOptions) ->
  return (fn) ->
    if typeof(fn) isnt 'function' and fn?.fn?
      options = fn
      fn = options.fn

    if not fn.isWrapped and typeof(fn) is 'function' and options?.this
      fn = wrap fn, wrapOptions
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
  if newProfiles?.$options?.this
    for own profileName,profile of newProfiles when profileName isnt '$options'
      for own groupType,group of profile
        options = if groupType in ['onCreated', 'onRendered'] then autosub:true else undefined
        for own name,fn of group
          if typeof(fn) is 'function' and not fn.isWrapped
            if groupType is 'events'
              fn.__wrapThis = true
            else
              group[name] = wrap fn, options
  originals.profiles.call this, newProfiles

# new instance functions which wrap things before calling the other implementations
Template::helpers     = wrapFns 'helpers'
Template::functions   = wrapFns 'functions'
Template::onCreated   = wrapFn 'onCreated', autosub:true
Template::onRendered  = wrapFn 'onRendered', autosub:true
Template::onDestroyed = wrapFn 'onDestroyed'

# completely replace the function `events`. why have them do all this work to
# call it with a different `this` then desired
Template::events = (fns) ->
  if fns.$options? then options = fns.$options
  fns = Template._replaceReferences 'events', fns
  eventMap = {}
  unwrapped = {}

  for own key,fn of fns when key isnt '$options'
    if options?.this or fn.__wrapThis
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

    else
      unwrapped[key] = fn

  if Object.keys(eventMap).length > 0 then @__eventMaps.push eventMap

  if Object.keys(unwrapped).length > 0 then originals.events.call this, unwrapped

  return
