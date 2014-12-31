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
    'datatable',
    'datatable.filters'
  ])
  .config ($routeProvider, $httpProvider, $sceDelegateProvider) ->
    $httpProvider.defaults.useXDomain = true
    delete $httpProvider.defaults.headers.common['X-Requested-With'];
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/about',
        templateUrl: 'views/about.html'
        controller: 'AboutCtrl'
      .when '/login',
        templateUrl: 'views/login.html'
        controller: 'LoginCtrl'
      .otherwise
        redirectTo: '/'
