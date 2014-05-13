'use strict'

{} = require 'prelude-ls'

angular.module 'microspecs' <[ui.router ui.bootstrap templates]>

.config <[$stateProvider]> ++ ($stateProvider) ->
  $stateProvider
  .state "home" do
    url: ""
    templateUrl: 'views/home.html'
    controller: 'microControl'

.controller 'microControl', <[$scope $http]> ++ ($scope, $http) ->
  csvFile = 'mumorts.csv'

  selectedIndex = 0

  $scope.selectRow = (row, index) ->
    console.log row.Event
    if selectedIndex >= 0
      $scope.rows[selectedIndex].selected = ""
    selectedIndex := index
    row.selected = "active"
    $scope.selectedRow = row

  $scope.selected = (row) -> row.selected

  # read and validate a row of data
  readAndValidate = (row) ->
    mumorts = parseFloat (row.Micromorts.split ',') * ''
    row.valid = row.Event != "" and
                row.Tags != "" and
                row.Unit != "" and
                !isNaN mumorts
    if row.valid
      row.Micromorts = mumorts
    else
      console.debug row
    return row

  # Read in and parse data
  d3.csv csvFile
  .row readAndValidate
  .get (err, rows) ->
    if !err
      $scope.rows = rows.filter (row, index)->row.valid
      $scope.selectedRow = $scope.rows[selectedIndex]
      $scope.$digest!
      console.log $scope.rows
    else
      console.log "Error #{err} reading #{csvFile}"