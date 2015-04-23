'use strict'

angular.module("datatable.directives", [])
  .directive "inInput", [() ->
    ###
    # Component for ip input.
    # usage of ip input
    #
    # Define the set of ips, like:
    # ipaddress = {
    #   passages: [
    #     {
    #       default: 192
    #       disable: true
    #     }, {
    #       default: 168
    #       disable: true
    #     }, {
    #       range: {
    #         min: 0
    #         max: 255
    #       }
    #       default: 0
    #       disable: false
    #       tip: "0~255"
    #     }, {
    #       default: 0
    #       disable: true
    #     }
    #   ]
    #   thowCidr: true
    #   cidr: {
    #     disable: true
    #     default: 24
    #     tip: "8~30"
    #   }
    # }
    #
    ###
    return {
      restrict: 'A'
      templateUrl: '../views/common/ip_input.html',
      replace: true
      scope: {
        address: '='
      }
      controller: ($scope) ->
        int = /^[0-9]*$/
        $scope.checkValue = (type, index) ->
          $scope.init()
          if type == 'passage'
            passage = $scope.address.passages[index]
            value = passage.default
            if int.test(value)
              passage.invalidate = false
            else
              passage.invalidate = true
      link: (scope, ele, attr) ->
        scope.init = () ->
          address = scope.address
          value = ''
          for pass, index in address.passages
            if pass.default != undefined
              if index != 3
                value = value + pass.default + '.'
              else
                value = value + pass.default
            else
              if index != 3
                value = value + '.'
          if address.showCidr
            value = value + '/' + address.cidr.default
          address.value = value
        scope.init()
    }
  ]
  .directive "tooltip", () ->
    # Custome the tooltip from bootstrap
    return {
      restrict: 'A'
      scope:
        content: '='
      link: (scope, element, attr) ->
        if !scope.content
          return
        if scope.content.length == 0
          return
        $(element).hover( () ->
          $(element).tooltip({
            html: true
            title: () ->
              return "<div class='tips'>" + scope.content + "</div>"
          })
          $(element).tooltip('show')
        )
    }
