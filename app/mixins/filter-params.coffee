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
      @set(multiFilter,null)
      @setupMultiFilter(multiFilter)

    return

  setupMultiFilter: (key) ->
    Ember.run.next(@,->
      multiFilter = key
      multiFilterSelected = Ember.A([])
      filterParam = @get(multiFilter)

      filterParams = filterParam?.split(',') || []
      @_allFilters(multiFilter).then((multiFilters) =>
        multiFilters.forEach (filter) =>
          filter.set('isFiltering',filterParams?.contains(filter.get('id')))
      ).finally =>
        @set("#{multiFilter}Selected",Ember.computed("#{@get('multiFilters')[multiFilter]}.@each.isFiltering",@multiFilterSelected))
        @set("#{multiFilter}AllSelected",Ember.computed("#{@get('multiFilters')[multiFilter]}.@each.isFiltering",@multiFilterAllSelected))
        @addObserver("#{multiFilter}Selected.@each.id",@,'multiFilterSelectedObserver')
        @removeObserver(multiFilter)
        @addObserver(multiFilter,@,'multiFilterObserver')
    )

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

  multiFilterSelected: (key,value,prevValue) ->
    key = key.replace('Selected','')
    @_allFilters(key).filterBy('isFiltering')

  multiFilterObserver: (sender, multiFilter) ->
    @_allFilters(multiFilter).setEach('isFiltering',false) unless @get(multiFilter)

  multiFilterSelectedObserver: (sender, key) ->
    key = key.replace('.@each.id','')
    multiFilterSelected = @get(key)
    key = key.replace('Selected','')
    newValue = multiFilterSelected.mapBy('id').toString()
    newValue = if newValue.length then newValue else null
    @set(key,newValue)

  multiFilterAllSelected: (key,value,prevValue) ->
    key = key.replace('AllSelected','')
    @_allFilters(key).isEvery('isFiltering')


  _allFilters: (filterName) ->
    @get(@get('multiFilters')[filterName])

  _selectMultiple: (filterName, filters) ->
    @_allFilters(filterName).setEach('isFiltering',false)
    filters.setEach('isFiltering',true)
    return

  _select: (filterName, filter) ->
    filter.set('isFiltering',!filter.get('isFiltering'))
    return

  actions:
    selectAll: (filterName) ->
      allFilters = @_allFilters(filterName)
      allSelected = @get("#{filterName}AllSelected")
      allFilters.setEach('isFiltering',!allSelected)
    select: (filterName, filters) ->
      if Ember.isArray(filters)
        @_selectMultiple(filterName, filters)
      else
        @_select(filterName, filters)
)

`export default FilterParamsMixin`
