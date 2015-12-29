
Tinytest.addAsync 'functions wrapped for special `this`', (test, done) ->
  ran = {}
  Template.profiles
    profileThis1:
      helpers:
        helper1: ->
          ran.helper = this
          this.template.$blah()
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
  profile = Template.profiles.$.profileThis1
  test.isTrue profile.helpers.helper1.isWrapped
  test.isTrue profile.onCreated.blah?.isWrapped
  test.isTrue profile.onRendered.blah?.isWrapped
  test.isTrue profile.onDestroyed.blah?.isWrapped
  test.isTrue profile.functions.$blah?.isWrapped

  # events are wrapped as they are added to a template instance
  # because it completely overrides the Template::events function
  # because that function does its own wrapping, so, instead of wrapping a
  # function to provide to Meteor which will then wrap it,
  # we're overriding it completely to wrap it the way we want, there's only
  # one wrapping
  test.isFalse profile.events['click p']?.isWrapped
  test.isTrue Template.testthis.__eventMaps[0]['click p'].isWrapped

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

  Template.TestTemplate.$TheName.set 'testthis'

  setTimeout (->
    $('#theId').click()
    Template.TestTemplate.$TheName.set null
    setTimeout (->
      console.log 'the ran:',ran
      testRan()
      done()
    ), 100
  ), 100
