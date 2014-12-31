ModalInstanceCtrl = ($scope, $modalInstance, action, items,
slug, addition, tips) ->
  names = []
  for item in items
    if item.name
      names.push(item.name)
    else if item.display_name
      names.push(item.display_name)
    else if item.label
      names.push(item.label)
    else if item.ip
      names.push(item.ip)
    else
      names.push(item.id)
  actionLower = action.toLowerCase()
  $scope.note =
    title: _("#{actionLower}") + _("action")
  nameStr = if names.length then ": #{names.join(', ')}" else ''
  slug = if slug then _("#{slug}") else ''
  $scope.message = _("Are you sure to ") +
                   _("#{actionLower}") +
                   "#{slug}#{nameStr}?"
  if tips
    $scope.message = tips
  if addition
    $scope.addition = true
    $scope.addition_message = addition.message
    $scope.addition_choice = addition.default

  $scope.cancelBtn = _ "Cancel"
  $scope.action = action
  $scope.ok = () ->
    $modalInstance.addition_choice = $scope.addition_choice
    $modalInstance.close()

  $scope.cancel = () ->
    $modalInstance.dismiss('cancel')

  $scope.additionChange = () ->
    if $scope.addition_choice == true
      $scope.addition_choice = false
    else
      $scope.addition_choice = true


tableApp = angular.module("datatable", [])

tableApp.directive 'datatable', () ->
  return {
    restrict: 'A'
    replace: true
    transclude: true
    scope: {
      'datatable': '='
    }
    templateUrl: '../views/table/table.html'
    controller: ($scope) ->
      scope = $scope
      scope.judgePages = (opts) ->
        if opts.pageMax
          scope.maxCounts = opts.pageMax
        currentPage = opts.pagingOptions.currentPage || 1
        if opts.pageCounts
          scope.pageCounts = opts.pageCounts
        else
          scope.pageCounts = 0
          scope.showFooter = false
        scope.showPages = scope.getPageCountList currentPage,
                          scope.pageCounts, scope.maxCounts
        if currentPage == 1 and scope.showPages.length > 1
          scope.unFristPage = false
          scope.showPageCode = true
          scope.unLastPage = true
        else if currentPage == 1 and scope.showPages.length == 1
          scope.showPageCode = false
        else
          scope.unFristPage = true
          scope.showPageCode = true
          if currentPage == scope.pageCounts
            scope.unLastPage = false
          else
            scope.unLastPage = true

      scope.gotoPage = (index) ->
        if typeof(index) is 'number'
          scope.pagingOptions.currentPage = \
            scope.showPages[index] + 1
        else if index == 'next'
          scope.pagingOptions.currentPage = \
            scope.pagingOptions.currentPage + 1
        else if index == 'pre'
          scope.pagingOptions.currentPage = \
            scope.pagingOptions.currentPage - 1
        else if index == 'frist'
          scope.pagingOptions.currentPage = 1
        else if index == 'last'
          scope.pagingOptions.currentPage = scope.pageCounts

        scope.judgePages scope.datatableOpts

      scope.getPageCountList = (currentPage, pageCount, maxCounts) ->
          __LIST_MAX__ = maxCounts
          list = []
          if pageCount <= __LIST_MAX__
            index = 0

            while index < pageCount
              list[index] = index
              index++
          else
            start = currentPage - Math.ceil(__LIST_MAX__ / 2)
            start = (if start < 0 then 0 else start)
            start = (if start + __LIST_MAX__ >= pageCount\
                      then pageCount - __LIST_MAX__ else start)
            index = 0

            while index < __LIST_MAX__
              list[index] = start + index
              index++
          return list
    link: (scope, ele, attr) ->
      init = () ->
        scope.showPageCode = false
        scope.loging = true
        scope.maxCounts = 5
        scope.sort = {
          sortingOrder: 'name'
          reverse: false
        }
        scope.showPages = []
        scope.showHeader = true
        scope.showFooter = false

      init()
      scope.$watch 'datatable', (datatableOpts) ->
        if !datatableOpts
          return
        if datatableOpts.data
          scope.loading = false
        else
          scope.loading = true
        scope.addition = datatableOpts.addition
        scope.filterAction = datatableOpts.filterAction
        scope.filters = datatableOpts.filters
        scope.datatableOpts = datatableOpts
        scope.pagingOptions = datatableOpts.pagingOptions
        scope.source = datatableOpts.data
        if datatableOpts.sort
          scope.sort = datatableOpts.sort
        if datatableOpts.filters
          scope.filters = datatableOpts.filters
        if datatableOpts.slug
          scope.nullTips = _("Temporarily none ") + _(datatableOpts.slug)
        if scope.pagingOptions.showFooter == false
          scope.showFooter = false
        else
          if scope.source and scope.source.length == 0
            scope.showFooter = false
          else
            scope.showFooter = true
        scope.judgePages datatableOpts
      , true
  }
.directive "selectAllCheckbox", ->
  return {
    replace: true
    restrict: 'E'
    scope: {
      checkboxes: '='
      allselected: '=allSelected'
      allclear: '=allClear'
    }
    template: '<input type="checkbox" ng-model="master" ng-change="masterChange(); selectChange()">'
    controller: ($scope, $element) ->
      $scope.masterChange = () ->
        if $scope.master
          angular.forEach $scope.checkboxes, (cb, index) ->
            cb.isSelected = true
        else
          angular.forEach $scope.checkboxes, (cb, index) ->
            cb.isSelected = false

    link: ($scope, $ele, $attr) ->
      $scope.$watch('checkboxes', () ->
        allSet = true
        allClear = true
        if !$scope.checkboxes
          allSet = false
        if $scope.checkboxes and $scope.checkboxes.length == 0
          allSet = false
        angular.forEach $scope.checkboxes, (cb, index) ->
          if cb.isSelected
            allClear = false
          else
            allSet = false

        if $scope.allselected != undefined
          $scope.allselected = allSet
        if $scope.allclear != undefined
          $scope.allclear = allClear

        if allSet
          $scope.master = true
        else if allClear
          $scope.master = false
        else
          $scope.master = false
      , true)
  }
.directive 'dynamic', ($compile) ->
  return {
    restrict: 'A',
    replace: true,
    scope: true,
    link: (scope, ele, attrs) ->
      scope.$watch attrs.dynamic, (html) ->
        ele.html(html)
        $compile(ele.contents())(scope)
  }
.directive "customSort", () ->
  return {
    restrict: 'A',
    transclude: true,
    scope: {
      order: '=',
      sort: '=',
    },
    templateUrl: '../views/table/_table_sort.html'
    link: (scope) ->
      scope.sort_by = (newSortingOrder) ->
        sort = scope.sort
        if sort.sortingOrder == newSortingOrder
          sort.reverse = !sort.reverse

        sort.sortingOrder = newSortingOrder

      if scope.sort
        scope.sort_by(scope.sort.sortingOrder)

      scope.selectedCls = (column) ->
        if column == scope.sort.sortingOrder
          if scope.sort.reverse
            return 'icon-chevron-down'
          else
            return 'icon-chevron-up'
        else
          return 'iocon-sort'
  }
.directive 'submitConfirm', ['$modal', '$templateCache', ($modal, $templateCache) ->
  return {
    restrict: 'A',
    scope: {
      submitConfirm: '&'
      items: '='
      addition: '='
      alarm: '='
      actionEnabled: '='
    },
    link: (scope, element, attrs) ->
      modalCall = ->
        modalInstance = $modal.open {
          templateUrl: '../views/table/_confirm_footer.html'
          controller: ["$scope",
            "$modalInstance",
            "action",
            "items",
            "slug",
            "addition",
            "tips",
            ModalInstanceCtrl]
          resolve: {
            action: ->
              attrs.submitConfirmAction || _('Confirm')
            items: ->
              scope.items || []
            slug: ->
              attrs.slug
            addition: ->
              scope.addition
            tips: ->
              attrs.tips
          }
        }

        modalInstance.result.then( () ->
          if scope.addition
            scope.addition.default = modalInstance.addition_choice
          scope.submitConfirm({
            items: scope.items
            addition: modalInstance.addition_choice
          })
        )

      scope.$watch 'items', (items) ->
        if scope.alarm
          element.unbind()
          element.bind 'click', scope.submitConfirm
        else
          enabledStatus = ['btn-enable', 'enabled']
          if !items and not attrs.allowEmptyItems
            element.unbind 'click'
            return
          else if attrs.allowEmptyItems
            element.unbind()
            element.bind 'click', modalCall
            return

          if items.length > 0 and \
          scope.actionEnabled in enabledStatus
            element.unbind()
            element.bind 'click', modalCall
          else
            element.unbind 'click', modalCall

          if !scope.actionEnabled
            if items.length > 0 and \
            attrs.actionEnable in enabledStatus
              element.unbind()
              element.bind 'click', modalCall
            else
              element.unbind 'click', modalCall
      , true
  }
]
.directive "filterintable", () ->
  return {
    restrict: 'A',
    scope: {
      items: '='
      action: '&'
    },
    templateUrl: '../views/table/table_filter.html',
    link: (scope, element, attrs) ->
      scope.filterItems = []
      scope.filterOpts = {key: scope.items.key}
      if scope.items
        angular.forEach scope.items.values, (item, index) ->
          pro = {
            code: index
            name: item.verbose
          }
          scope.filterItems.push pro

      scope.update = (item) ->
        scope.selectedItem = item.name
        value = scope.items.values[item.code].value
        for option, index in scope.items.values
          if index == item.code
            option.selected = true
          else
            option.selected = false
        scope.filterOpts.value = value
        scope.action()
  }
.directive "actionButton", () ->
  return {
    restrict: 'A'
    transclude: true
    scope: {
      'buttons': '='
      'items': '='
    }
    templateUrl: '../views/table/action_buttons.html'
    link: (scope, ele, attr) ->
      scope.more = _ 'More Action'
      scope.fresh = _ 'Refresh'
      if !scope.buttons
        return
      if scope.buttons.hasMore
        scope.moreAction = scope.buttons.buttonGroup
      if scope.buttons.searchOpts
        scope.searchOpts = scope.buttons.searchOpts
        scope.search = () ->
          scope.searchOpts.searchAction(scope.searchOpts.searchKey,
          scope.searchOpts.val)
      scope.actions = scope.buttons.buttons
      scope.$watch 'actions', (newVal) ->
        for action in scope.actions
          if action.enable
            action.action_enable = 'enabled'
          else
            action.action_enable = 'btn-disable'
      , true
      if !scope.moreAction
        return
      scope.$watch 'moreAction', (newVal) ->
        for action in scope.moreAction
          if action.enable
            action.action_enable = 'enabled'
          else
            action.action_enable = 'btn-disable'
      , true
  }
