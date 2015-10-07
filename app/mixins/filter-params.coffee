`import Ember from 'ember'`

FilterParamsMixin = Ember.Mixin.create(
  filters: Ember.computed(->
    []
  )

  multiFilters: Ember.computed(->
    []
  )

  _filters: (->
    Ember.keys(@get('filters'))
  ).property('filters')

  _multiFilters: (->
    Ember.keys(@get('multiFilters'))
  ).property('multiFilters')

  init: ->
    @_super()

    @get('_filters').forEach (filter) =>
      filterName = "#{filter}Selected"
      filterValue = Ember.computed(filter,@filterSelected)
      @set(filterName,filterValue)

    @get('_multiFilters').forEach (multiFilter) =>
      @set("#{multiFilter}Selected",Ember.A([]))
      @addObserver(multiFilter,@,'multiFilterParamObserver')
      @addObserver("#{multiFilter}Selected.@each",@,'multiFilterSelectedObserver')

    return

  multiFilterParamObserver: (sender, key) ->
    multiFilter = key
    multiFilterSelected = Ember.A([])
    filterParam = @get(multiFilter)

    if !!filterParam
      filterParams = if Ember.isArray(filterParam) then filterParam else filterParam.split(',')
      filterParams.forEach (fp) =>
        multiFilterKey = @get('multiFilters')[multiFilter]
        multiFilterRecord = @store.find(multiFilterKey,fp)
        multiFilterSelected.pushObject(multiFilterRecord)

    Ember.RSVP.all(multiFilterSelected).then((resolvedMultiFilters) =>
      multiFilterSelected = resolvedMultiFilters
    ).finally =>
      @removeObserver(multiFilter)
      @set("#{multiFilter}Selected",multiFilterSelected)

  multiFilterSelectedObserver: (sender,key) ->
    filterParam = key.replace('Selected.@each','')
    filterSelected = @get(key.replace('@each',''))

    if !!filterSelected
      filterSelected.setEach('isFiltering',true)
      filter = filterSelected.mapBy('id')
      if filter.length is 0
        @set(filterParam,undefined)
      else
        @set(filterParam,filter)

  filterSelected: (key,value,prevValue) ->
    key = key.replace('Selected','')
    filter = null

    # setter
    if !!value
      @set(key,value.id)

    filterIds = @get(key)

    if !!filterIds
      key = @get('filters')[key]
      filter = @store.find(key,filterIds)

    filter

  _selectAll: (filterName, filters) ->
    filters.setEach('isFiltering',true)
    @set("#{filterName}Selected",filters)

  _select: (filterName, filter) ->
    filter.set('isFiltering',!filter.get('isFiltering'))
    filters = @get("#{filterName}Selected")
    if !!filters
      if filter.get('isFiltering')
        filters.pushObject(filter)
      else
        filters.removeObject(filter)

  actions:
    select: (filterName, filters) ->
      if Ember.isArray(filters)
        _selectAll(filterName, filters)
      else
        _select(filterName, filters)
)

`export default FilterParamsMixin`
