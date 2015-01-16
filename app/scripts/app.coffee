'use strict'

###*
 # @ngdoc overview
 # @name testApp
 # @description
 # # testApp
 #
 # Main module of the application.
###
angular
  .module('testApp', [
    'ngAnimate',
    'ngResource',
    'ngRoute',
    'ui.router',
    'datatable',
    'datatable.filters'
  ])
  .config ($routeProvider, $httpProvider, $sceDelegateProvider,
           $stateProvider) ->
    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With']
    $stateProvider
      .state 'main',
        url: '/'
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .state 'about',
        url: '/about'
        templateUrl: 'views/about.html'
        controller: 'AboutCtrl'
      .state 'login',
        url: '/login'
        templateUrl: 'views/login.html'
        controller: 'LoginCtrl'
  .run ($state) ->
    console.log $state.get()
