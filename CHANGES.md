0.3.0 - Released 2015/01/15

1. avoid assigning functions to the `this` which overwrite core functions
2. enhanced `functions` to be on the `this` object instead of the `Blaze.TemplateInstance` so we can do `this.someFunction()` instead of `this.template.someFunction()`
3. with the functions on the special `this` we maintain that `this` with `this.someFunction()` instead of doing `this.template.someFunction.call(this)`


0.2.0 - Released 2015/01/15

1. upgrade to cosmos:blaze-profiles@0.2.0 to fix/improve refs
2. allows options to all functions
3. must specify `this:true` in options to have them called with the special `this`
4. specifies an arg in the wrapper function so its length isn't zero which caused some issues


0.1.0 - Released 2015/12/29

1. initial working version with tests
