
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
  test.isTrue profile.functions.$blah?.isWrapped

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

  Template.TestTemplate.$TheName.set 'testthis'

  setTimeout (->
    $('#theId').click()
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
