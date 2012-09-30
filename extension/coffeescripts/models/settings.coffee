class BH.Models.Settings extends BH.Models.Base
  storeName: 'settings'

  defaults: ->
    timeGrouping: 15
    domainGrouping: true
    timeFormat: parseInt @chromeAPI.i18n.getMessage('default_time_format'), 10
    searchByDomain: true
    searchBySelection: true
    openLocation: 'last_visit'
    startingWeekDay: 'Monday'

  toTemplate: ->
    properties =
      startingWeekDays: []
      openLocations: []
      timeGroupings: []
      timeFormats: []
      searchBySelection: @get 'searchBySelection'
      searchByDomain: @get 'searchByDomain'
      domainGrouping: @get 'domainGrouping'

    _(['monday', 'tuesday', 'wednesday',
      'thursday', 'friday', 'saturday', 'sunday']).each (day) =>
      properties.startingWeekDays.push
        text: @chromeAPI.i18n.getMessage day
        value: day

    _(['last_visit', 'current_day', 'current_week']).each (location) =>
      properties.openLocations.push
        text: @chromeAPI.i18n.getMessage location
        value: location

    _([15, 30, 60]).each (timeGrouping) =>
      properties.timeGroupings.push
        text: @chromeAPI.i18n.getMessage "#{timeGrouping}_minutes_option"
        value: timeGrouping

    _([12, 24]).each (timeFormat) =>
      properties.timeFormats.push
        text: @chromeAPI.i18n.getMessage "#{timeFormat}_hours_option"
        value: timeFormat

    properties

  timeGrouping: ->
    parseInt @get('timeGrouping'), 10

  timeFormat: ->
    parseInt @get('timeFormat'), 10

  parse: (data) ->
    JSON.parse data
