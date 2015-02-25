"use strict";

angular.module('WeekI.directives', [])

    .directive("slideBackground", function () {
        return {
            restrict: 'A',
            link: function (scope, element, attrs) {
                element.css('background-image', 'url("' + attrs.slideBackground + '")');
                element.css('background-size', 'cover');
            }
        };
    })

    .directive("fixedSize", function () {
        return {
            restrict: 'A',
            link: function (scope, element, attrs) {
                element.css('width', attrs.fixedSize);
            }
        };
    })

    .directive("fontSize", function () {
        return {
            restrict: 'A',
            link: function (scope, element, attrs) {
                var height = element[0].offsetHeight;
                element.css('font-size', parseInt(attrs.fontSize * height) + 'px');
            }
        };
    })

    .directive("fixedPosition", function () {
        return {
            restrict: 'A',
            link: function (scope, element, attrs) {
                var parent = element.parent();
                var width = element[0].offsetWidth;
                var height = element[0].offsetHeight;
                var parentWidth = parent[0].offsetWidth;
                var parentHeight = parentWidth;
                element.css('position', 'absolute');
                element.css('top', parseInt(parentHeight * parseFloat(attrs.fixedTop) - height / 2) + 'px');
                element.css('left', parseInt(parentWidth * parseFloat(attrs.fixedLeft) - width / 2) + 'px');
            }
        };
    })

    .directive("square", function () {
        return {
            restrict: 'A',
            link: function (scope, element, attrs) {
                var width = element[0].offsetWidth;
                var height = element[0].offsetWidth;
                if (width < height) {
                    element.css('width', height + 'px');
                } else {
                    element.css('height', width + 'px');
                }
            }
        };
    })

    .directive('input', function ($timeout) {
        return {
            restrict: 'E',
            scope: {
                'returnClose': '=',
                'onReturn': '&',
                'onFocus': '&',
                'onBlur': '&'
            },
            link: function (scope, element, attr) {
                element.bind('focus', function (e) {
                    if (scope.onFocus) {
                        $timeout(function () {
                            scope.onFocus();
                        });
                    }
                });
                element.bind('blur', function (e) {
                    if (scope.onBlur) {
                        $timeout(function () {
                            scope.onBlur();
                        });
                    }
                });
                element.bind('keydown', function (e) {
                    if (e.which == 13) {
                        if (scope.returnClose) element[0].blur();
                        if (scope.onReturn) {
                            $timeout(function () {
                                scope.onReturn();
                            });
                        }
                    }
                });
            }
        }
    })

    .directive('rdLoading', function () {
        var directive = {
            restrict: 'AE',
            template: '<div class="loading"><div class="double-bounce1"></div><div class="double-bounce2"></div></div>'
        };
        return directive;
    })

    .directive('rdWidget', function () {
        var directive = {
            transclude: true,
            template: '<div class="widget" ng-transclude></div>',
            restrict: 'EA'
        };
        return directive;

        function link(scope, element, attrs) {

        }
    })
    .directive('rdWidgetBody', function () {
        var directive = {
            requires: '^rdWidget',
            scope: {
                loading: '@?',
                classes: '@?'
            },
            transclude: true,
            template: '<div class="widget-body" ng-class="classes"><rd-loading ng-show="loading"></rd-loading><div ng-hide="loading" class="widget-content" ng-transclude></div></div>',
            restrict: 'E'
        };
        return directive;
    })

    .directive('rdWidgetFooter', function () {
        var directive = {
            requires: '^rdWidget',
            transclude: true,
            template: '<div class="widget-footer" ng-transclude></div>',
            restrict: 'E'
        };
        return directive;
    })

    .directive('rdWidgetHeader', function () {
        var directive = {
            requires: '^rdWidget',
            scope: {
                title: '@',
                icon: '@'
            },
            transclude: true,
            template: '<div class="widget-header"><i class="fa" ng-class="icon"></i> {{title}} <div class="pull-right" ng-transclude></div></div>',
            restrict: 'E'
        };
        return directive;
    });