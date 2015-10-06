# Ember-filter-params

This README outlines the details of collaborating on this Ember addon.

## Installation

`npm install ember-filter-params --save-dev`

## Usage

This is meant to work like `queryParams` for a controller, adding to `filters` or
 `multiFilters`. It generates a property for each filter with the following convention:

```
  "#{filter}Selected"
```

so if you added a filter named 'status', the property you'd update is 'statusSelected'.

We use an object instead of an array, to allow for overrides. Say for example you have 
 two filters that are backed by the same model, this allows for an override. In a future version,
 I'd like this to be optional, but this is still in its infancy.

### Single Filters

**controller**
```
import Ember from 'ember';
import FilterParamsMixin from 'you-app-name/mixins/filter-params';

Controller = Ember.Controller.extend(
  FilterParamsMixin,
  {
    queryParams: ['status'],
    filters: {
      status: 'status'
    },
    ...
  }
)

export default Controller;
```

**template**
```
  {{ember-selectize selection=statusSelected content=allStatuses optionValuePath="content.id" optionLabelPath="content.name"}}
```

selecting a filter will update the `status` queryParam, which will generate the following url:

```
  http://localhost:4200/some-route?status=1
```


### Multi Filters

**controller**
```
import Ember from 'ember';
import FilterParamsMixin from 'you-app-name/mixins/filter-params';

Controller = Ember.Controller.extend(
  FilterParamsMixin,
  {
    queryParams: ['statuses'],
    multiFilters: {
      statuses: 'status'
    },
    ...
  }
)

export default Controller;
```

**template**
```
  {{ember-selectize multiple=true selection=statusSelected content=allStatuses optionValuePath="content.id" optionLabelPath="content.name"}}
```

adding a filter to your multi-select field, will update the `statuses` queryParam, which will generate the following url:

```
  http://localhost:4200/some-route?statuses=1,2
```

## TODO

* Allow for array of `multiFilters` and `filters`, not just object.
* Finish the TODO 
