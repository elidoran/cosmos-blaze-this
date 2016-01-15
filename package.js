Package.describe({
  name: 'cosmos:blaze-this',
  version: '0.3.0',
  summary: 'Provide consistent this for all profile functions',
  git: 'http://github.com/elidoran/cosmos-blaze-this',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2');

  uses(api);

});

Package.onTest(function(api) {

  uses(api);

  api.use(['tinytest', 'reactive-var', 'jquery'], 'client');

  api.addFiles([
    , 'test/templates.html'
    , 'test/templates.coffee'
    , 'test/tests.coffee'
  ], 'client');

  api.export('Template', 'client');
});

function uses(api) {
  api.use(['coffeescript', 'templating', 'cosmos:blaze-profiles@0.3.0'], 'client')

  api.addFiles('client/blaze-this.coffee', 'client');

}
