'use strict'

{} = require 'prelude-ls'

angular.module 'microspecs' <[ui.router ui.bootstrap templates]>
.config <[$stateProvider]> ++ ($stateProvider) ->
  console.log 'Ho there'
  $stateProvider
  .state "home" do
    url: ""
    templateUrl: 'views/home.html'
    controller: 'microControl'
.controller 'microControl', <[$scope $http]> ++ ($scope, $http) ->
  console.log 'Hi there'
  $scope.foo = "World"
  $http.get 'data.json'
  .then (json) !-> 
    $scope.lines = json.data
  , ->
    console.log 'http error'