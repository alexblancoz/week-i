angular.module('WeekI.controllers', [])

    .controller('ErrorCtrl', function ($scope, $modalInstance, title, content) {
        $scope.title = title;
        $scope.content = content;

        $scope.close = function () {
            $modalInstance.dismiss('close');
        };
    })

    .controller('SplashCtrl', function ($scope, $state, Storage, Session) {

        var initialize = function () {
            var session = Session.load();
            if (session.token && session.secret && session.user_identity) {
                $state.go('dashboard.groups.list');
            }
        };

        initialize();

    })

    .controller('AlertsCtrl', function ($scope) {
        $scope.alerts = [{
            type: 'success',
            msg: 'Thanks for visiting! Feel free to create pull requests to improve the dashboard!'
        }, {
            type: 'danger',
            msg: 'Found a bug? Create an issue with as many details as you can.'
        }];

        $scope.addAlert = function() {
            $scope.alerts.push({
                msg: 'Another alert!'
            });
        };

        $scope.closeAlert = function(index) {
            $scope.alerts.splice(index, 1);
        };
    })

    .controller('LoginCtrl', function ($scope, $state, Session, User, Helper, Error) {

        var initialize = function() {
            $scope.errors = {};
        };

        var loginSuccess = function (data, status) {
            Session.save(data.token, data.secret, data.user_identity);
            $state.go('dashboard.groups.list');
        };

        var handleError = function (data, status) {
            if (status == 401) {
                $scope.errors = data.error;
            }
        };

        $scope.login = function (user) {
            if (user === undefined) {
                user = {};
            }
            User.login(user.enrollment, user.password).success(loginSuccess).error(handleError);
        };

        initialize();

    })

    .controller('RegisterCtrl', function ($scope, $state, Session, User, Error) {

        var initialize = function () {
            $scope.errors = {};
            User.majors()
                .success(function(data, status) {
                    $scope.majors = data;
                })
                .error(handleError);

            User.campuses()
                .success(function(data, status) {
                    $scope.campuses = data;
                })
                .error(handleError);
        };

        var registerSuccess = function (data, status) {
            Session.save(data.token, data.secret, data.user_identity);
            $state.go('dashboard.groups.list');
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
            if (status == 422) {
                $scope.errors = data.errors;
            }
        };

        var clearErrors = function () {
            $scope.errors = {};
        };

        $scope.register = function (user) {
            clearErrors();
            User.create(user).success(registerSuccess).error(handleError);
        };

        initialize();

    })

    .controller('DashboardCtrl', function($scope, $state, User, Storage, Error, Session) {

        var initialize = function() {
            $scope.items = [];

            $scope.dropdownItems = [
                {
                    label: 'Cerrar sessión',
                    action: logout
                }
            ];

            User.dashboard()
                .success(function(data, status) {
                    $scope.items = data;
                })
                .error(handleError);

            User.show()
                .success(function(data, status) {
                    $scope.user = data;
                    $scope.$broadcast('user.loaded');
                })
                .error(handleError);

            $scope.user_identities = User.identities;
        };

        var logout = function() {
            Session.clear();
            $state.go('splash.login');
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
            if (status == 422) {
                $scope.errors = data.errors;
            }
        };

        var mobileView = 992;

        $scope.getWidth = function() {
            return window.innerWidth;
        };

        $scope.$watch($scope.getWidth, function(newValue, oldValue) {
            if (newValue >= mobileView) {
                if (angular.isDefined(Storage.get('toggle'))) {
                    $scope.toggle = !Storage.get('toggle');
                } else {
                    $scope.toggle = true;
                }
            } else {
                $scope.toggle = false;
            }
        });

        $scope.toggleSidebar = function() {
            $scope.toggle = !$scope.toggle;
            Storage.set('toggle', $scope.toggle);
        };

        $scope.dropdownClicked = function(index) {
            $scope.dropdownItems[index].action();
        };

        window.onresize = function() {
            $scope.$apply();
        };

        initialize();

    })

    .controller('GroupsCtrl', function ($scope, $state, Group, Error, User) {

        var initialize = function () {
            $scope.groups = [];

            if ($scope.user) {
                loadGroups();
            } else {
                $scope.$on('user.loaded', function() {
                    loadGroups();
                });
            }

        };


        var loadGroups = function() {
            switch ($scope.user.identity) {
                case User.identities.administrator:
                case User.identities.user:
                    Group.list()
                        .success(function(data, status) {
                            $scope.groups = data;
                        })
                        .error(handleError);
                    break;
                case User.identities.teacher:
                    Group.scored()
                        .success(function(data, status) {
                            $scope.scored_groups = data;
                        })
                        .error(handleError);

                    Group.nonScored()
                        .success(function(data, status) {
                            $scope.non_scored_groups = data;
                        })
                        .error(handleError);
                    break;
                default:
                    Error.customError('Error', 'No se pudo identitficar tu tipo de usario.');
                    break;
            }
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        $scope.show = function(group) {
            $state.transitionTo('dashboard.groups.show', { groupId: group.id });
        };

        initialize();

    })

    .controller('GroupsShowCtrl', function ($scope, $stateParams, Group, Helper, Error) {

        var initialize = function () {
            loadGroup();
            $scope.status = Group.status;
        };

        var loadGroup = function() {
            Group.show($stateParams.groupId)
                .success(function (data, status) {
                    $scope.group = data;
                    updateRequestButton(data);
                })
                .error(handleError);
        };

        var updateRequestButton = function(group) {
            switch (group.status) {
                case 0:
                    $scope.request_membership_button = 'Esperando respuesta...';
                    break;
                case 1:
                    $scope.request_membership_button = 'Dejar el grupo';
                    break;
                default:
                    $scope.request_membership_button = 'Unirse al grupo';
                    break;
            }

        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        $scope.requestMembership = function(group) {
            switch (group.status) {
                case 0:
                    break;
                case 1:
                    Group.destroyMembership()
                        .success(loadGroup)
                        .error(handleError);
                    break;
                default:
                    Group.addMembership(group.id)
                        .success(loadGroup)
                        .error(handleError);
            }

        };

        $scope.acceptMembership = function(user) {
            Group.acceptMembership(user.id)
                .success(loadGroup)
                .error(handleError);
        };

        initialize();
    })

    .controller('GroupsFormCtrl', function ($scope, $state, $stateParams, Error, Group) {
        var initialize = function () {
            $scope.errors = {};
            $scope.group = {};

            if ($stateParams.groupId != null) {
                Group.show($stateParams.groupId)
                    .success(groupShowSuccess)
                    .error(handleError)
                    .finally(loaded);
            } else {
                $scope.loading = false;
            }
        };

        var loaded = function () {
            $scope.loading = false;
        };

        var groupShowSuccess = function (data, status) {
            $scope.group = data;
        };

        var groupSuccess = function(data, status) {
            $state.go('dashboard.groups.list');
        };

        var handleError = function(data, status) {
            Error.handleError(data, status);
            if (status == 422) {
                $scope.errors = data.errors;
            }
        };

        $scope.save = function (group) {
            Group.save(group)
                .success(groupSuccess)
                .error(handleError)
        };

        initialize();
    })

    .controller('CoursesCtrl', function ($scope, $state, $modal, Course, Error) {

        var initialize = function () {
            $scope.courses_taken = [];
            $scope.courses_not_taken = [];

            loadCourses();

        };

        var loadCourses = function() {
            Course.taken()
                .success(function(data, status) {
                    $scope.courses_taken = data;
                })
                .error(handleError);

            Course.notTaken()
                .success(function(data, status) {
                    $scope.courses_not_taken = data;
                })
                .error(handleError);
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        var addCourseProfessor = function(professor) {
            Course.addProfessor(professor.course_professor_id)
                .success(loadCourses)
                .error(handleError);
        };

        $scope.addCourse = function(course) {

            var modalInstance = $modal.open({
                templateUrl: 'course/modal',
                controller: 'CourseModalCtrl',
                resolve: {
                    courseId: function() {
                        return course.id;
                    }
                }
            });

            modalInstance.result.then(function (selectedProfessor) {
                addCourseProfessor(selectedProfessor)
            });
        };

        $scope.destroyCourse = function(course) {
            Course.destroyProfessor(course.course_professor_user_id)
                .success(loadCourses)
                .error(handleError);
        }

        $scope.show = function(course) {
            $state.transitionTo('dashboard.courses.show', { courseId: course.id });
        };

        initialize();

    })

    .controller('CourseModalCtrl', function ($scope, $modalInstance, courseId, Course, Error) {

        var initialize = function() {
            Course.professors(courseId)
                .success(function(data, status) {
                    $scope.professors = data;
                    $scope.selected = $scope.professors[0];
                })
                .error(handleError);

        };

        var handleError = function(data, status) {
            Error.handleError(data, status);
        };

        $scope.ok = function () {
            $modalInstance.close($scope.selected);
        };

        $scope.cancel = function () {
            $modalInstance.dismiss('cancel');
        };

        initialize();
    })

    .controller('CoursesShowCtrl', function ($scope, $stateParams, Course, Helper, Error) {

        var initialize = function () {
            Course.show($stateParams.courseId)
                .success(function (data, status) {
                    $scope.course = data;
                })
                .error(handleError);
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        initialize();
    })

    .controller('CoursesFormCtrl', function ($scope, $state, $stateParams, Error, Course) {
        var initialize = function () {
            $scope.errors = {};
            $scope.course = {};

            if ($stateParams.courseId != null) {
                Course.show($stateParams.courseId)
                    .success(courseShowSuccess)
                    .error(handleError)
                    .finally(loaded);
            } else {
                $scope.loading = false;
            }
        };

        var loaded = function () {
            $scope.loading = false;
        };

        var courseShowSuccess = function (data, status) {
            $scope.course = data;
        };

        var courseSuccess = function(data, status) {
            $state.go('dashboard.courses.list');
        };

        var handleError = function(data, status) {
            Error.handleError(data, status);
            if (status == 422) {
                $scope.errors = data.errors;
            }
        };

        $scope.save = function (course) {
            Course.save(course)
                .success(courseSuccess)
                .error(handleError)
        };

        initialize();
    })

    .controller('ProfessorsCtrl', function ($scope, $state, Professor, Error) {

        var initialize = function () {
            $scope.professors = [];
            Professor.list()
                .success(function(data, status) {
                    $scope.professors = data;
                })
                .error(handleError);
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        initialize();

    })

    .controller('ProfessorsFormCtrl', function ($scope, $state, $stateParams, Error, Professor) {
        var initialize = function () {
            $scope.errors = {};
            $scope.professor = {};

            if ($stateParams.professorId != null) {
                Professor.show($stateParams.professorId)
                    .success(professorShowSuccess)
                    .error(handleError)
                    .finally(loaded);
            } else {
                $scope.loading = false;
            }
        };

        var loaded = function () {
            $scope.loading = false;
        };

        var professorShowSuccess = function (data, status) {
            $scope.professor = data;
        };

        var professorSuccess = function(data, status) {
            $state.go('dashboard.professors.list');
        };

        var handleError = function(data, status) {
            Error.handleError(data, status);
            if (status == 422) {
                $scope.errors = data.errors;
            }
        };

        $scope.save = function (professor) {
            Professor.save(professor)
                .success(professorSuccess)
                .error(handleError)
        };

        initialize();
    })
