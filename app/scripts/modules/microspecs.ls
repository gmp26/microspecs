'use strict'

{} = require 'prelude-ls'

angular.module 'microspecs' <[ui.router ui.bootstrap templates]>

.config <[$stateProvider]> ++ ($stateProvider) ->
  $stateProvider
  .state "home" do
    url: ""
    templateUrl: 'views/home.html'
    controller: 'microControl'

.controller 'microControl', <[$rootScope $scope $http]> ++ ($rootScope, $scope, $http) ->
  csvFile = 'MM-for-calculator.csv'
  selectedIndex = -1
  tag = ""
  timeUnits = <[second:60 minute:60 hour:24 day:7 week:4.33 month:12 year]>
  distanceUnits = <[foot:3 yard:220 furlong:8 mile]>

  $scope.norm = (unitsTable, units, unit) ->
    x = unitsTable.indexOf(unit)
    if x >= 0
      while x > 0 and units < 1
        x = x - 1
        [unit, f] = unitsTable[x].split ':'
        units = units * (+f)
      [units, unit]
    else
      null

  $scope.renormalise = (units, unit) ->
    if units >= 1
      [units, unit]
    else
      a = $scope.norm timeUnits, units, unit
      if !a
        a = $scope.norm distanceUnits, units, unit
      if a then a else [units, unit]

  $scope.selectRow = (row, index) ->
    if row.valid
      console.log row.deathFrom
      if($scope.selectedRow)
        $scope.selectedRow.selected = false
      selectedIndex := index
      row.selected = true
      $scope.selectedRow = row

  # $scope.selected = (row) -> row.selected
  # $scope.invalid = (row) -> !row.valid
  $scope.getClass = (row) -> do
    active: row.selected
    invalid: !row.valid
    groupTitle: row.groupTitle
    titles: row.titles

  # read and validate a row of data
  readAndValidate = (row) ->
    mumorts = parseFloat (row.micromorts.split ',') * ''

    # ignore empty lines, but use lines with sole content in column A (deathFrom) as group titles 
    if row.unit == "" and
    row.context == "" and
    row.micromorts == "" and
    row.period == "" and
    row.deaths == "" and
    row.population == "" and
    row.ref == ""
      if row.deathFrom != ""
        row.groupTitle = true
      else
        row.ignore = true
    else
      row.units = 1
      row.displayedUnits = "#{row.units} #{row.unit}"
      row.ignore = false

    # valid rows have a cause, unit, mumorts
    row.valid = row.deathFrom != "" and
                row.unit != "" and
                !isNaN mumorts 

    if row.valid
      row.micromorts = mumorts
      row.displayedUnits = ->
        if $scope.selectedRow
          units = $scope.selectedRow.micromorts/@micromorts
          unit = @unit
          if units < 1
            [units, unit] = $scope.renormalise units, unit
          "#{units.toFixed 0} #{unit}"
        else
          "1 #{@unit}"

      row.displayedMicromorts = ->
        if $scope.selectedRow
          $scope.selectedRow.micromorts
        else
          @micromorts

    else
      row.displayedUnits = -> ""
      console.debug row
    return row

  # Read in and parse data
  d3.csv csvFile
  .row readAndValidate
  .get (err, rows) ->
    if !err
      $scope.rows = rows.filter (row, index)->!row.ignore
      $scope.selectedRow = null
      $scope.row2 = $scope.rows[0]
      $scope.row2.titles = true
      $scope.$digest!
      console.log $scope.rows
    else
      console.log "Error #{err} reading #{csvFile}"