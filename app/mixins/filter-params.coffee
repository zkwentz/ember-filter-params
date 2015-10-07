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
      @_allFilters(multiFilter).then((multiFilters) =>
        filterParams = if Ember.isArray(filterParam) then filterParam else filterParam.split(',')
        filterParams.forEach (fp) =>
          multiFilterSelected.pushObject(multiFilters.findBy('id',fp))
      ).finally =>
        @removeObserver(multiFilter)
        @set("all#{filterParam.capitalize()}Selected",@_allSelected(filterParam))
        @set("#{multiFilter}Selected",multiFilterSelected)

  multiFilterSelectedObserver: (sender,key) ->
    filterParam = key.replace('Selected.@each','')
    filterSelected = @get(key.replace('.@each',''))

    @set("all#{filterParam.capitalize()}Selected",@_allSelected(filterParam))

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

    filterId = @get(key)

    if !!filterId
      key = @get('filters')[key]
      @get(key).then (filters) =>
        filters.findBy('id',filterId)

  _allSelected: (filterParam) ->
    @_allFilters(filterParam).isEvery('isFiltering')

  _allFilters: (filterName) ->
    @get(@get('multiFilters')[filterName])

  _selectMultiple: (filterName, filters) ->
    @_allFilters(filterName).setEach('isFiltering',false)
    filters.setEach('isFiltering',true)
    @set("#{filterName}Selected",filters)
    return

  _select: (filterName, filter) ->
    filter.set('isFiltering',!filter.get('isFiltering'))
    filters = @get("#{filterName}Selected")
    if !!filters
      if filter.get('isFiltering')
        filters.pushObject(filter)
      else
        filters.removeObject(filter)
    return

  actions:
    selectAll: (filterName) ->
      allFilters = @_allFilters(filterName)
      allSelected = @_allSelected(filterName)
      allFilters.setEach('isFiltering',!allSelected)
      if allSelected
        @set("#{filterName}Selected",[])
      else
        @set("#{filterName}Selected",allFilters.get('content'))
    select: (filterName, filters) ->
      if Ember.isArray(filters)
        @_selectMultiple(filterName, filters)
      else
        @_select(filterName, filters)
)

`export default FilterParamsMixin`
