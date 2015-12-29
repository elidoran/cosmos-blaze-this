
Template.TestTemplate.$TheName = new ReactiveVar
Template.TestTemplate.helpers

  theName: -> Template.TestTemplate.$TheName.get()
  theData: -> id:'theId'
