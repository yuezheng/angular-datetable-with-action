class TableView
  REFRESH_ROW_TIMEOUT: 5000
  items: []
  itemTotal: 0
  singleSelectedItems: []
  selectedItems: []
  unFristPage: false
  unLastPage: false
  pageCounts: 0
  paging: true
  labileStatus: []
  abnormalStatus: []
  showCheckbox: true
  pageMax: 5
  slug: 'item'
  columnDefs: []
  additionQueryOpts: {}
  pagingOptions: {
    pageSizes: [15, 25, 50]
    pageSize: 15
    currentPage: 1
    showFooter: true
  }

  itemTableOpts: {
  }

  setPagingData: (pagedData, total, scope, options) ->
    obj = options.$this
    obj.items = pagedData
    obj.itemTotal = total
    tableOpts = "#{obj.slug}Opts"
    obj.pageCounts = Math.ceil(total / obj.pagingOptions.pageSize)
    scope.items = obj.items
    if obj.sortOpts
      scope[tableOpts].sort = obj.sortOpts
    scope[tableOpts].pageCounts = obj.pageCounts
    scope[tableOpts].pagingOptions = obj.pagingOptions
    scope[tableOpts].data = obj.items
    scope[tableOpts].filterAction = obj.filterAction
    for item in obj.items
      obj.judgeStatus scope, item, options

  @getPagedDataAsync: (pageSize, currentPage, $scope, options) ->
    obj = options.$this
    setTimeout(() ->
      currentPage = currentPage - 1
      dataQueryOpts = {}
      if obj.paging
        dataQueryOpts =
          dataFrom: parseInt(pageSize) * parseInt(currentPage)
          dataTo: parseInt(pageSize) * parseInt(currentPage) + parseInt(pageSize)
      if obj.additionQueryOpts
        for key, value of obj.additionQueryOpts
          dataQueryOpts[key] = value
      obj.listData $scope, options, dataQueryOpts,
      (items, total) ->
        obj.setPagingData items, total, $scope, options
    , 300)

  init: ($scope, options) ->
    obj = @
    obj.$scope = $scope
    obj.additionQueryOpts = @additionQueryOpts
    $scope.pagingOptions = @pagingOptions
    $scope.selectedItems = []
    tableOpts = "#{obj.slug}Opts"
    if @columnDefs.length == 0
      @columnDefs = $scope.columnDefs
    $scope[tableOpts] = {
      showCheckbox: @showCheckbox
      pageMax: @pageMax
      slug: @slug
      columnDefs: @columnDefs
      pagingOptions: @pagingOptions
    }
    options.$this = obj
    # Get specific data and draw table
    TableView.getPagedDataAsync @pagingOptions.pageSize,
              @pagingOptions.currentPage, $scope, options

    pageChange = (newVal, oldVal) ->
      if not $scope[tableOpts]
        return
      $interval = options.$interval
      if $.intervalList
        angular.forEach $.intervalList, (task, index) ->
          if $interval
            $interval.cancel task
      $scope[tableOpts].data = null
      if newVal != oldVal and newVal.currentPage != oldVal.currentPage
        TableView.getPagedDataAsync newVal.pageSize,
        newVal.currentPage, $scope, options

    $scope.$watch 'pagingOptions', pageChange, true
    $scope.$watch 'items', (newVal, oldVal) ->
      obj.itemChange newVal, oldVal, $scope, options
    , true
    obj.subPageOpen($scope)
    obj.initialAction $scope, options
    obj.clearInterval($scope, options)

  _itemChange: (newVal, oldVal, $scope, options) ->
    obj = options.$this
    labileStatus = obj.labileStatus || []
    selectedItems = []
    for item in newVal
      if item.status and item.status in labileStatus
        obj.getLabileData $scope, item.id, options
      if item.isSelected == true
        selectedItems.push item
      if $scope.selectedItemId
        if typeof(item.id) == 'number'
          item.id = String item.id
        if item.id == $scope.selectedItemId
          item.isSelected = true
          $scope.selectedItemId = undefined
    return selectedItems

  itemChange: (newVal, oldVal, $scope, options) ->
    if not newVal
      return
    obj = options.$this
    selectedItems = obj._itemChange newVal, oldVal, $scope, options
    $scope.selectedItems = selectedItems
    if selectedItems.length == 1
      $scope.NoSelectedItems = false
      $scope.batchActionEnableClass = 'btn-enable'
      $scope.singleSelectedItem = $scope.selectedItems[0]
      $scope.singleEnableClass = 'btn-enable'
    else if selectedItems.length > 1
      $scope.NoSelectedItems = false
      $scope.batchActionEnableClass = 'btn-enable'
      $scope.singleEnableClass = 'btn-disable'
    else
      $scope.NoSelectedItems = true
      $scope.batchActionEnableClass = 'btn-disable'
      $scope.singleSelectedItem = {}
      $scope.singleEnableClass = 'btn-disable'
    return true

  judgeStatus: ($scope, item, options) ->
    obj = options.$this
    abnormalStatus = obj.abnormalStatus || []
    labileStatus = obj.labileStatus || []
    if item.status in labileStatus
      item.labileStatus = 'unknwon'
    else if item.status in abnormalStatus
      item.labileStatus = 'abnormal'
    else
      item.labileStatus = 'active'
    item.STATUS = _(item.status)

  subPageOpen: ($scope) ->
    $scope.$on('selected', (event, detail) ->
      if $scope.items
        if $scope.items.length > 0
          for item, index in $scope.items
            if item.id == detail
              $scope.items[index].isSelected = true
            else
              $scope.items[index].isSelected = false
      else
        $scope.selectedItemId = detail
    )
    $scope.$on('detail', (event, detail) ->
      if $scope.items
        for item, index in $scope.items
          if typeof(item.id) == 'number'
            item.id = String item.id
          if item.id == detail
            item.isSelected = true
          else
            item.isSelected = false
      else
        $scope.selectedItem = detail
      $scope.detail_show = "detail_show"
    )

  clearInterval: ($scope, options) ->
    $interval = options.$interval
    $scope.$on('$destroy', () ->
      if $.intervalList
        angular.forEach $.intervalList, (task, index) ->
          if $interval
            $interval.cancel task
    )

  # Item get handle.
  itemGet: (itemId, options, callback) ->
    callback {}
    return true
  # Items list handle.
  listData: (options, dataQueryOpts, callback) ->
    callback [], 0

  updateRow: ($scope, item, oldItem, options) ->
    obj = options.$this
    obj.judgeStatus $scope, item, options
    return oldItem

  # periodic get volume data which status is 'processing'
  getLabileData: ($scope, itemId, options) ->
    obj = options.$this
    $interval = options.$interval
    labileStatus = obj.labileStatus || []
    freshData = $interval(() ->
      obj.itemGet itemId, options, (item) ->
        if item
          if not obj.labileStatus.length
            $interval.cancel(freshData)
            return
          if not item.status
            $interval.cancel(freshData)
            return
          if item.status not in obj.labileStatus
            $interval.cancel(freshData)
            return

          angular.forEach $scope.items, (row, index) ->
            if row.id == item.id
              row = obj.updateRow($scope, item, row, options)
              $scope.items[index] = row
              if item.status == 'DELETED'
                $scope.items.splice(index, 1)
        else
          $interval.cancel(freshData)
          angular.forEach $scope.items, (row, index) ->
            if row.id == itemId
              $scope.items.splice(index, 1)
              return false
    , obj.REFRESH_ROW_TIMEOUT)

  initialAction: ($scope, options) ->
    obj = options.$this
    tableOpts = "#{obj.slug}Opts"
    $scope.fresh = () ->
      $scope[tableOpts].data = null
      TableView.getPagedDataAsync $scope.pagingOptions.pageSize,
      $scope.pagingOptions.currentPage, $scope, options

  action: ($scope, options, actionCall) ->
    selectedItems = $scope.selectedItems || []
    if not selectedItems.length
      return
    angular.forEach selectedItems, (item, index) ->
      actionCall item, index

  filterAction: (key, values) ->
    return true

window.TableView = TableView
