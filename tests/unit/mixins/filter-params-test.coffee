`import Ember from 'ember'`
`import FilterParamsMixin from '../../../mixins/filter-params'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | filter params'

# Replace this with your real tests.
test 'it works', (assert) ->
  FilterParamsObject = Ember.Object.extend FilterParamsMixin
  subject = FilterParamsObject.create()
  assert.ok subject
