'use strict'

###
# filters
#
#
###
angular.module('datatable.filters', [])
  .filter 'i18n', ->
    return (text) ->
      if typeof text == "string"
        return _(text)
      return text
  .filter 'unitSwitch', ->
    return (number, withUnit) ->
      switched = ''
      unit = 'MB'
      if number < 1024
        switched = number / 1024
        unit = 'GB'
      else if number < 1024 ** 2
        switched = number / 1024
        unit = 'GB'
      else if number < 1024 ** 3
        switched = number / 1024 ** 2
        unit = 'TB'
      else if number < 1024 ** 4
        switched = number / 1024 ** 3
        unit = 'PB'

      if switched % 1 != 0
        switched = switched.toFixed(1)

      if withUnit
        switched = "#{switched} #{unit}"

      return switched
  .filter 'dateLocalize', ->
    return (utcDate) ->
      if !utcDate
        return
      if utcDate.indexOf('Z') > 0
        dt = new Date(utcDate).getTime()
      else
        dt = new Date(utcDate + 'Z').getTime()
      return dt
  .filter 'parseNull', ->
    return (str) ->
      free = "None"
      if str
        if str == '' or str == 'null'
          return "<#{free}>"
        return str
      else
        return "<#{free}>"
