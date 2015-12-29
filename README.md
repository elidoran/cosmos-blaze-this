# Cosmos Blaze This

Provides a consistent `this` to all *cosmos:blaze-profiles* functions.

## Install

```
meteor add cosmos:blaze-this
```

## This

The `this` always has:

1. `template` - the template instance, `Blaze.TemplateInstance`
2. `data` - the current **non-reactive** data object
3. `getData` - **reactive** access to current data and parent data contexts
4. `Template` - the `Blaze.Template` object, for example: `Template.theName`

Conditionally has:

1. `event` - when it's an event listener
2. `args` - when it's a helper, event listener, or a `functions` function receiving arguments
3. `hash` - when it's a helper and an object is provided to the helper. The `hash` property is extracted from the `Spacebars.kw` argument and provided in the `this`; the `Spacebars.kw` object is removed from the args
3. `subscribe` - when it's a lifecycle listener (created and rendered)
4. `autorun` - when it's a lifecycle listener (created and rendered)


## The Standard This (without blaze-this)

Traditionally the `this` and other objects are done differently for different types. Describe:

1. Events:

    * this = the current `Blaze.TemplateInstance` **data** context
    * event - the first function arg
    * template - the second function arg
    * data (non-reactive) = `this`
    * data (reactive) = `Template.currentData()` and `Template.parentData()`
    * Template - template.view.template is the `Blaze.Template`

2. Helpers:

    * this = the current `Blaze.TemplateInstance` **data** context
    * template = `Template.instance()`
    * data (non-reactive) = the `this`
    * data (reactive) = `Template.currentData()` and `Template.parentData()`
    * Template - `Template.instance().view.template` is the `Blaze.Template`

3. Lifecycle handlers:

    * this = the current `Blaze.TemplateInstance`
    * template = `this`
    * data (non-reactive) = `this.data`
    * data (reactive) = `Template.currentData()` and `Template.parentData()`
    * Template - `this.view.template` is the `Blaze.Template`

## API

There is no additional API. It alters the inner workings of `cosmos:blaze-profiles` to call functions with the `this` described above.

Well, there's one function to explain which is available in the `this`:

### getData(number)

To reactively get data contexts we normally use `Template.currentData()` and `Template.parentData(number)`.

Those two functionalities are combined via `getData(number)`. It calls `Template.parentData` with a default number of zero.

So:

* `getData(0)` = `Template.currentData()`
* `getData(1)` = `Template.parentData()` and `Template.parentData(1)`
* `getData(2)` = `Template.parentData(2)`
* `getData(3)` = `Template.parentData(3)`
* and so on...


## MIT License
