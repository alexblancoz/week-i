
angular.module('WeekI', ['ui.router', 'ui.bootstrap', 'WeekI.controllers', 'WeekI.services', 'WeekI.resources', 'WeekI.directives'])

    .config(function($stateProvider, $urlRouterProvider) {

        $stateProvider

            .state('splash', {
                url: '/splash',
                abstract: true,
                templateUrl: '/splash',
                controller: 'SplashCtrl'
            })

            .state('splash.login', {
                url: '/login',
                views: {
                    'splashContent': {
                        templateUrl: '/sessions/new',
                        controller: 'LoginCtrl'
                    }
                }
            })

            .state('splash.register', {
                url: '/register',
                views: {
                    'splashContent': {
                        templateUrl: '/users/new',
                        controller: 'RegisterCtrl'
                    }
                }
            })

            .state('dashboard', {
                url: '/dashboard',
                abstract: true,
                templateUrl: '/dashboard',
                controller: 'DashboardCtrl'
            })

            .state('dashboard.groups', {
                abstract: true,
                url: '/groups',
                views: {
                    'dashboardContent': {
                        template: '<ui-view/>'
                    }
                }
            })

            .state('dashboard.groups.list', {
                url: '/list',
                views: {
                    '': {
                        templateUrl: '/groups',
                        controller: 'GroupsCtrl'
                    }
                }
            })

            .state('dashboard.groups.form', {
                url: '/form?groupId',
                views: {
                    '': {
                        templateUrl: '/groups/new',
                        controller: 'GroupsFormCtrl'
                    }
                }
            })

            .state('dashboard.groups.show', {
                url: '/:groupId',
                views: {
                    '': {
                        templateUrl: '/groups/show',
                        controller: 'GroupsShowCtrl'
                    }
                }
            })

            .state('dashboard.courses', {
                abstract: true,
                url: '/courses',
                views: {
                    'dashboardContent': {
                        template: '<ui-view/>'
                    }
                }
            })

            .state('dashboard.courses.list', {
                url: '/list',
                views: {
                    '': {
                        templateUrl: '/courses',
                        controller: 'CoursesCtrl'
                    }
                }
            })

            .state('dashboard.courses.form', {
                url: '/form?groupdId',
                views: {
                    '': {
                        templateUrl: '/courses/new',
                        controller: 'CoursesFormCtrl'
                    }
                }
            });

        $urlRouterProvider.otherwise('/splash/login');

    });
