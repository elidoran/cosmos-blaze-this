
Tinytest.addAsync 'functions wrapped for special `this`', (test, done) ->
  ran = {}
  Template.profiles
    $options: this:true
    profileThis1:
      helpers:
        helper1: ->
          ran.helper = this
          this.template.$blah.call this
          'helper1!'
      events:
        'click p': -> console.log 'click p!' ; ran.event = this
      onCreated:
        blah: -> ran.created = this
      onRendered:
        blah: -> ran.rendered = this
      onDestroyed:
        blah: -> ran.destroyed = this
      functions:
        $blah: () -> ran.function = this

  Template.testthis.profiles ['profileThis1']

  # ensure they were all wrapped
  profile = Template._profiles.profileThis1
  test.isTrue profile.helpers.helper1.isWrapped
  test.isTrue profile.onCreated.blah?.isWrapped
  test.isTrue profile.onRendered.blah?.isWrapped
  test.isTrue profile.onDestroyed.blah?.isWrapped

  # functions/events are wrapped when called in the individual functions.
  test.isFalse profile.functions.$blah?.isWrapped
  test.isTrue Template.testthis._thisFunctions.$blah.isWrapped

  test.isFalse profile.events['click p']?.isWrapped
  test.isTrue Template.testthis.__eventMaps[0]['click p'].isWrapped

  # # Add some directly instead of from a profile
  Template.testthis.helpers
    $options: this:true
    helper2: ->
      ran.helper2 = this
      this.template.$blah2.call this
      'helper2'

  Template.testthis.events
    $options: this:true
    'click p': -> console.log 'click p 2!' ; ran.event2 = this

  Template.testthis.onCreated this:true, fn: -> ran.created2 = this
  Template.testthis.onRendered this:true, fn: -> ran.rendered2 = this
  Template.testthis.onDestroyed this:true, fn: -> ran.destroyed2 = this
  Template.testthis.functions this:true, $blah2: -> ran.function2 = this

  # # Add some *without* wrapping

  Template.testthis.helpers
    helper3: -> ran.helper3 = this ; 'helper3'

  Template.testthis.events
    'click p': -> console.log 'click p 3!' ; ran.event3 = this

  Template.testthis.onCreated -> ran.created3 = this
  Template.testthis.onRendered -> ran.rendered3 = this
  Template.testthis.onDestroyed -> ran.destroyed3 = this
  Template.testthis.functions $blah3: -> ran.function3 = this # this won't run...


  test.equal Object.keys(ran).length, 0, 'ran should be empty before template is rendered'

  testRan = ->
    test.equal ran.helper.data.id, 'theId'
    test.isNotUndefined ran.helper.getData
    test.isTrue(ran.helper.template instanceof Blaze.TemplateInstance)

    test.equal ran.event.data.id, 'theId'
    test.isNotUndefined ran.event.getData
    test.isTrue(ran.event.template instanceof Blaze.TemplateInstance)

    test.equal ran.created.data.id, 'theId'
    test.isNotUndefined ran.created.getData
    test.isNotUndefined ran.created.autorun
    test.isNotUndefined ran.created.subscribe
    test.isTrue(ran.created.template instanceof Blaze.TemplateInstance)

    test.equal ran.rendered.data.id, 'theId'
    test.isNotUndefined ran.rendered.getData
    test.isNotUndefined ran.rendered.autorun
    test.isNotUndefined ran.rendered.subscribe
    test.isTrue(ran.rendered.template instanceof Blaze.TemplateInstance)

    test.equal ran.destroyed.data.id, 'theId'
    test.isNotUndefined ran.destroyed.getData
    test.isTrue(ran.destroyed.template instanceof Blaze.TemplateInstance)

    test.equal ran.function.data.id, 'theId'
    test.isNotUndefined ran.function.getData
    test.isTrue(ran.function.template instanceof Blaze.TemplateInstance)

    # # round 2 for the direct adds

    test.equal ran.helper2.data.id, 'theId'
    test.isNotUndefined ran.helper2.getData
    test.isTrue(ran.helper.template instanceof Blaze.TemplateInstance)

    test.equal ran.event2.data.id, 'theId'
    test.isNotUndefined ran.event2.getData
    test.isTrue(ran.event2.template instanceof Blaze.TemplateInstance)

    test.equal ran.created2.data.id, 'theId'
    test.isNotUndefined ran.created2.getData
    test.isNotUndefined ran.created2.autorun
    test.isNotUndefined ran.created2.subscribe
    test.isTrue(ran.created2.template instanceof Blaze.TemplateInstance)

    test.equal ran.rendered2.data.id, 'theId'
    test.isNotUndefined ran.rendered2.getData
    test.isNotUndefined ran.rendered2.autorun
    test.isNotUndefined ran.rendered2.subscribe
    test.isTrue(ran.rendered2.template instanceof Blaze.TemplateInstance)

    test.equal ran.destroyed2.data.id, 'theId'
    test.isNotUndefined ran.destroyed2.getData
    test.isTrue(ran.destroyed2.template instanceof Blaze.TemplateInstance)

    test.equal ran.function2.data.id, 'theId'
    test.isNotUndefined ran.function2.getData
    test.isTrue(ran.function2.template instanceof Blaze.TemplateInstance)

    # # round 3 for the unwrapped

    test.equal ran.helper3.id, 'theId'
    test.isUndefined ran.helper3.getData
    test.isUndefined ran.helper3.template

    test.equal ran.event3.id, 'theId'
    test.isUndefined ran.event3.getData
    test.isUndefined ran.event3.template

    test.isNotUndefined ran.created3, 'ran.created3 should exist'
    test.equal ran.created3.data.id, 'theId'
    test.isUndefined ran.created3.getData
    test.isUndefined ran.created3.template

    test.isNotUndefined ran.rendered3, 'ran.rendered3 should exist'
    test.equal ran.rendered3.data.id, 'theId'
    test.isUndefined ran.rendered3.getData
    test.isUndefined ran.rendered3.template

    test.isNotUndefined ran.destroyed3, 'ran.destroyed3 should exist'
    test.equal ran.destroyed3.data.id, 'theId'
    test.isUndefined ran.destroyed3.getData
    test.isUndefined ran.destroyed3.template

    # no way to run it without the this stuff
    test.isUndefined ran.function3

  # cause the template to be created/rendered
  Template.TestTemplate.$TheName.set 'testthis'

  setTimeout (->
    $('#theId').click()
    # cause the template to be destroyed
    Template.TestTemplate.$TheName.set null
    setTimeout (->
      console.log 'the ran:',ran
      try
        testRan()
      catch error
        console.log 'Error processing testRan() :',error.stack
      done()
    ), 100
  ), 100

Tinytest.addAsync 'instance functions are bound to the this', (test, done) ->
  console.log '\n\n\n\n\n'
  ran = {}

  Template.profiles
    $options: this:true
    TestFunctions:
      helpers:
        helper: ->
          @$fn('some arg')
          ran.helper = this
          'helper1'
      functions:
        $fn: (arg) ->
          ran.fn =
            this: this
            arg : arg
        # disallowed names
        Template: ->
        template: ->
        data: ->
        getData: ->
        args: ->
        event: ->
        _isThat: ->
        hash: ->
        autorun: ->
        subscribe: ->

  template = Template.TestFunctions

  template.profiles [ 'TestFunctions' ]

  template.functions
    $options: this:true
    $fn2: (arg) ->
      ran.fn2 =
        this: this
        arg: arg

  template.helpers
    $options: this:true
    helper2: -> @$fn2('some arg') ; ran.helper2 = this ; 'helper2'

  template.functions
    # no options for this:true so it works as in blaze-profiles
    $fn3: (arg) ->
      ran.fn3 =
        this: this
        arg: arg

  template.helpers
    $options: this:true
    helper3: -> @template.$fn3('some arg') ; ran.helper3 = this ; 'helper3'

  Template.TestTemplate.$TheName.set 'TestFunctions'

  testRan = ->

    # fn3 is normal, no this
    test.isNotUndefined ran.fn3, 'ran should contain an `fn3`'
    test.equal ran.fn3.arg, 'some arg'
    test.isTrue (ran.fn3.this instanceof Blaze.TemplateInstance), 'fn3.this should be a template instance'
    test.equal typeof(ran.fn3.this.$fn3), 'function', '$fn3 should be on the template instance instead'

    test.isNotUndefined ran.fn, 'ran should contain an `fn`'
    test.isNotUndefined ran.fn.this.$fn, 'fn `this` should have $fn'
    test.isNotUndefined ran.fn.this.$fn2, 'fn `this` should have $fn2'
    test.isUndefined ran.fn.this.$fn3, 'fn `this` should NOT have $fn3'
    test.isNotUndefined ran.fn.this.template, 'fn `this` should have template'
    test.isNotUndefined ran.fn.this.Template, 'fn `this` should have Template'
    test.isNotUndefined ran.fn.this.args, 'fn `this` should have args'
    test.equal ran.fn.this.args[0], 'some arg'
    test.isNotUndefined ran.fn.this.data, 'fn `this` should have data'
    test.isNotUndefined ran.fn.this.getData, 'fn `this` should have getData'

    test.isNotUndefined ran.fn2, 'ran should contain an `fn2`'

  setTimeout (->
    # cause the template to be destroyed
    Template.TestTemplate.$TheName.set null
    setTimeout (->
      console.log 'the ran:',ran
      try
        testRan()
      catch error
        console.log 'Error processing testRan() :',error.stack
      done()
    ), 100
  ), 100
