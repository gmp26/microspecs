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
  tag = ""
  timeUnits = <[second minute hour day week month year]>
  distanceUnits = <[foot yard furlong mile]>

  $scope.selectRow = (row, index) ->
    console.log row.deathFrom
    $scope.rows[selectedIndex].selected = ""
    selectedIndex := index
    row.selected = "active"
    $scope.selectedRow = row

  $scope.selected = (row) -> row.selected

  # read and validate a row of data
  readAndValidate = (row) ->
    mumorts = parseFloat (row.micromorts.split ',') * ''
    units = parseFloat row.units
    row.valid = row.deathFrom != "" and
                row.unit != "" and
                !isNaN mumorts and
                !isNaN units

    # ignore empty lines, but use lines with sole content in column A (deathFrom) as group titles 
    if row.units == "" and
    row.unit == "" and
    row.context == "" and
    row.micromorts == "" and
    row.period == "" and
    row.deaths == "" and
    row.population == "" and
    row.ref == ""
      if row.deathFrom != ""
        tag := row.deathFrom
      row.ignore = true
      row.displayedUnits = ""
    else
      row.units = 1
      row.displayedUnits = "#{row.units} #{row.unit}"
      row.ignore = false

    row.tag = tag
    if row.valid
      row.micromorts = mumorts
    else
      console.debug row
    return row

  # Read in and parse data
  d3.csv csvFile
  .row readAndValidate
  .get (err, rows) ->
    if !err
      $scope.rows = rows.filter (row, index)->!row.ignore
      # $scope.selectedRow = $scope.rows[selectedIndex]
      $scope.$digest!
      console.log $scope.rows
    else
      console.log "Error #{err} reading #{csvFile}"