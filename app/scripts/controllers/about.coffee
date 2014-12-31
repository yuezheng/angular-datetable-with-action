'use strict'

###*
 # @ngdoc function
 # @name testApp.controller:AboutCtrl
 # @description
 # # AboutCtrl
 # Controller of the testApp
###
angular.module('testApp')
  .controller 'AboutCtrl', ($scope, $http, $window) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
      'Test'
    ]
    instanceTable = new InstanceTable($scope)
    instanceTable.init($scope, {
      $http: $http
      $window: $window
    })


class InstanceTable extends window.TableView
  slug: 'instances'
  columnDefs: [
    {
      field: "name",
      displayName: "Name",
      cellTemplate: '<div class="ngCellText enableClick" ng-click="detailShow(item.id)" data-toggle="tooltip" data-placement="top" title="{{item.name}}"><a ui-sref="dashboard.instance.instanceId.overview({ instanceId:item.id })" ng-bind="item[col.field]"></a></div>'
    }
    {
      field: "fixed",
      displayName: "FixedIP",
      cellTemplate: '<div class="ngCellText" ng-click="test(col)"><li ng-repeat="ip in item.fixed">{{ip | parseNull}}</li></div>'
    }
    {
      field: "floating",
      displayName: "FloatingIP",
      cellTemplate: '<div class=ngCellText ng-click="test(row, col, $event)"><li ng-repeat="ip in item.floating">{{ip}}</li><li ng-if="item.floating.length==0">{{null | parseNull}}</li></div>'
    }
    {
      field: "image_name",
      displayName: "Image",
      cellTemplate: '<div class=ngCellText>{{ item.image_name | parseNull}}</div>'
    }
    {
      field: "vcpus",
      displayName: "CPU",
      cellTemplate: '<div ng-bind="item[col.field]"></div>'
    }
    {
      field: "ram",
      displayName: "RAM (GB)",
      cellTemplate: '<div ng-bind="item[col.field] | unitSwitch"></div>'
    }
    {
      field: "created",
      displayName: "Create At",
      cellTemplate: '<div>{{item[col.field] | dateLocalize | date:"yyyy-M-dd H:mm" }}</div>'
    }
    {
      field: "status",
      displayName: "Status",
      cellTemplate: '<div class="ngCellText status" ng-class="item.labileStatus"><i></i>{{item.status}}</div>'
    }
  ]
  listData: ($scope, options, dataQueryOpts, callback) ->
    $http = options.$http
