Bedrock Utils
=============

Set of utilities to be used in Bedrock Projects

Methods
=======

Config
------

Config allows a user to read in objects from a variety of files, merge configruations, and specify properties based on the environment. Configurations come back as a single object, with keys corresponding to the basename of the matched file, and the values a nested merge of the files contents.

### Simple Usage
With the following files:

#### `config/foo.json`:
```json
{
  "name": "foo"
}
```

#### `config/bar.json`:
```json
{
  "name": "bar"
}
```

Calling the initialize method and passing in a glob query:

```coffee
{config} = require 'bedrock-utils'
config.initialize 'config/**.json'

console.log config
# foo:
#   name: 'foo'
# bar
#   name: 'bar'
```

### Complex Useage
It is possible to also provide overrides for files and merge from many different queries. The order in which glob strings are declared in the `queries` parameter are the order of prescendence when the values from same-name files are merged.

Add a third file, named `/srv/foo.json`:

#### `/srv/config/foo.json`
```json
{
  "name": "top foo",
  "status": "active",
  "environments": {
    "test": {
      "status": "testing"
    }
  }
}
```

Config will merge the values from the various files together, and pick specific attributes based on the environment as follows:

```coffee
{config} = require 'bedrock-utils'
config.initialize ['config/*.json', '/srv/config/*.json'], env: 'test'

console.log config
# foo:
#   name: 'foo'
#   status: 'testing'
# bar:
#   name: 'bar'
```

### Arguments

`config.initialize` receives 2 arguments - queries and options.

* queries **(String|Array)**
    This can either be a single glob query string or an array of glob query strings. If the argument is an array, the order in which the queries are passed in will be the order in which they configs override each other when the contents of the files are merged.
* options **(Object)**
    The options are used to change the behavior of the initialize method. They are augmented by the defaults listed below.

### Defaults

** Any of these defaults can be overriden by passing in a value to options **

* env **(process.env.NODE_ENV or 'development')**
    The current environment. This is used to pick configurations that are conditionalized by environment.
* freeze **(true)**
    Whether or not to use a deep version of Object.freeze on the final configurations
* inMemory **(true)**
    Whether to augment the config object in memory or return a new object
* cwd **(process.cwd())**
    The working directory to use when matching the glob queries
* root **(path.resolve options.cwd, '/')**
    The root directory to use when matching the glob queries
