'use strict'

###*
 # @ngdoc function
 # @name testApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the testApp
###
angular.module('testApp')
  .controller 'MainCtrl', ($scope, $state, $http) ->
    $scope.awesomeThings = [
      'HTML5 Boilerplate'
      'AngularJS'
      'Karma'
    ]
    console.log('DDDDD')
    console.log $state.current
    $http.get("./scripts/controllers/testdata.json")
      .success (data) ->
        console.log data
    $http.get('./scripts/controllers/test.js')
      .success (data) ->
        console.log data
