angular.module('WeekI.controllers', [])

    .controller('ErrorCtrl', function ($scope, $modalInstance, title, content) {
        $scope.title = title;
        $scope.content = content;

        $scope.close = function () {
            $modalInstance.dismiss('close');
        };
    })

    .controller('SplashCtrl', function ($scope, $state, Storage, Session, User) {

        var initialize = function () {
            var session = Session.load();
            if (session.token && session.secret && session.user_identity) {
                switch (session.user_identity) {
                    case User.Identities.administrator:
                    case User.Identities.user:
                        $state.go('dashboard.groups.list');
                        break;
                    case User.Identities.teacher:
                        $state.go('dashboard.scores.list');
                        break;
                    default:
                        Error.customError('Error', 'No se pudo identitficar tu tipo de usario.');
                        break;
                }
            }
        };

        initialize();

    })

    .controller('LoginCtrl', function ($scope, $state, Session, User, Helper, Error) {

        var initialize = function () {
            $scope.errors = {};
        };

        var loginSuccess = function (data, status) {
            Session.save(data.token, data.secret, data.user_identity);
            switch (data.user_identity) {
                case User.Identities.administrator:
                case User.Identities.user:
                    $state.go('dashboard.groups.list');
                    break;
                case User.Identities.teacher:
                    $state.go('dashboard.scores.list');
                    break;
                default:
                    Error.customError('Error', 'No se pudo identitficar tu tipo de usario.');
                    break;
            }
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
                .success(function (data, status) {
                    $scope.majors = data;
                })
                .error(handleError);

            User.campuses()
                .success(function (data, status) {
                    $scope.campuses = data;
                })
                .error(handleError);
        };

        var registerSuccess = function (data, status) {

            Session.save(data.token, data.secret, data.user_identity);
            switch (data.user_identity) {
                case User.Identities.administrator:
                case User.Identities.user:
                    $state.go('dashboard.groups.list');
                    break;
                case User.Identities.teacher:
                    $state.go('dashboard.scores.list');
                    break;
                default:
                    Error.customError('Error', 'No se pudo identitficar tu tipo de usario.');
                    break;
            }

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

    .controller('DashboardCtrl', function ($scope, $state, User, Storage, Error, Session) {

        var initialize = function () {
            $scope.items = [];

            $scope.dropdownItems = [
                {
                    label: 'Cerrar sessión',
                    action: logout
                }
            ];

            User.dashboard()
                .success(function (data, status) {
                    $scope.items = data;
                })
                .error(handleError);

            User.show()
                .success(function (data, status) {
                    $scope.user = data;
                    $scope.$broadcast('user.loaded');
                })
                .error(handleError);

            $scope.user_identities = User.Identities;
        };

        var logout = function () {
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

        $scope.getWidth = function () {
            return window.innerWidth;
        };

        $scope.$watch($scope.getWidth, function (newValue, oldValue) {
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

        $scope.toggleSidebar = function () {
            $scope.toggle = !$scope.toggle;
            Storage.set('toggle', $scope.toggle);
        };

        $scope.dropdownClicked = function (index) {
            $scope.dropdownItems[index].action();
        };

        window.onresize = function () {
            $scope.$apply();
        };

        initialize();

    })

    .controller('GroupsCtrl', function ($scope, $state, Group, Error, User, Score) {

        var initialize = function () {
            $scope.groups = [];
            $scope.search = {};

            if ($scope.user) {
                loadGroups();
            } else {
                $scope.$on('user.loaded', function () {
                    loadGroups();
                });
            }
        };

        var loadGroups = function () {
            switch ($scope.user.identity) {
                case User.Identities.administrator:
                case User.Identities.user:
                    Group.list()
                        .success(function (data, status) {
                            $scope.groups = data;
                        })
                        .error(handleError);
                    break;
                case User.Identities.teacher:
                    Score.scoredGroups()
                        .success(function (data, status) {
                            $scope.scored_groups = data;
                        })
                        .error(handleError);

                    Score.nonScoredGroups()
                        .success(function (data, status) {
                            $scope.non_scored_groups = data;
                        })
                        .error(handleError);
                    break;
                default:
                    Error.customError('Error', 'No se pudo identificar tu tipo de usuario.');
                    break;
            }
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        $scope.show = function (group) {
            $state.transitionTo('dashboard.groups.show', {groupId: group.id});
        };

        $scope.destroy = function (group) {
            Group.destroy(group.id)
                .success(loadGroups)
                .error(handleError);
        };

        initialize();

    })

    .controller('GroupsShowCtrl', function ($scope, $stateParams, Group, Helper, Error) {

        var initialize = function () {
            loadGroup();
            $scope.status = Group.status;
        };

        var loadGroup = function () {
            Group.show($stateParams.groupId)
                .success(function (data, status) {
                    $scope.group = data;
                    updateRequestButton(data);
                })
                .error(handleError);
        };

        var updateRequestButton = function (group) {
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

        $scope.requestMembership = function (group) {
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

        $scope.acceptMembership = function (user) {
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

        var groupSuccess = function (data, status) {
            $state.go('dashboard.groups.list');
        };

        var handleError = function (data, status) {
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

    .controller('CoursesCtrl', function ($scope, $state, $modal, Course, Error, User) {

        var initialize = function () {
            $scope.courses_taken = [];
            $scope.courses_not_taken = [];
            $scope.courses = [];
            $scope.search = {};

            if ($scope.user) {
                loadCourses();
            } else {
                $scope.$on('user.loaded', function () {
                    loadCourses();
                });
            }
        };

        var loadCourses = function () {
            switch ($scope.user.identity) {
                case User.Identities.administrator:
                    Course.list()
                        .success(function (data, status) {
                            $scope.courses = data;
                        })
                        .error(handleError);
                    break;
                case User.Identities.user:
                    Course.taken()
                        .success(function (data, status) {
                            $scope.courses_taken = data;
                        })
                        .error(handleError);

                    Course.notTaken()
                        .success(function (data, status) {
                            $scope.courses_not_taken = data;
                        })
                        .error(handleError);
                default:
                    break;
            }
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        var addCourseProfessor = function (professor) {
            Course.addProfessorUser(professor.course_professor_id)
                .success(loadCourses)
                .error(handleError);
        };

        $scope.addCourse = function (course) {
            Course.professors(course.id)
                .success(function (data, status) {
                    var modalInstance = $modal.open({
                        templateUrl: 'course/modal',
                        controller: 'CourseModalCtrl',
                        resolve: {
                            professors: function() {
                                return data;
                            }
                        }
                    });

                    modalInstance.result.then(function (selectedProfessor) {
                        addCourseProfessor(selectedProfessor)
                    });

                })
                .error(handleError);
        };

        $scope.destroyCourse = function (course) {
            Course.destroyProfessorUser(course.course_professor_user_id)
                .success(loadCourses)
                .error(handleError);
        };

        $scope.show = function (course) {
            $state.transitionTo('dashboard.courses.show', {courseId: course.id});
        };

        $scope.destroy = function (course) {
            Course.destroy(course.id)
                .success(loadCourses)
                .error(handleError);
        };

        initialize();

    })

    .controller('CourseModalCtrl', function ($scope, $modalInstance, professors, Course, Error) {

        var initialize = function () {
            $scope.professors = professors;
            $scope.selected = $scope.professors[0];
            $scope.search = {};
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        $scope.ok = function () {
            $modalInstance.close($scope.selected);
        };

        $scope.cancel = function () {
            $modalInstance.dismiss('cancel');
        };

        $scope.select = function(professor) {
            $scope.selected = professor;
        };

        initialize();
    })

    .controller('CoursesShowCtrl', function ($scope, $stateParams, $modal, Course, Helper, Error, Professor) {

        var initialize = function () {
            loadCourse();
        };

        var loadCourse = function() {
            Course.show($stateParams.courseId)
                .success(function (data, status) {
                    $scope.course = data;
                })
                .error(handleError);
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        var addProfessorSuccess = function(course, professors) {
            var modalInstance = $modal.open({
                templateUrl: 'course/modal',
                controller: 'CourseModalCtrl',
                resolve: {
                    professors: function() {
                        return professors;
                    }
                }
            });

            modalInstance.result.then(function (selectedProfessor) {
                addCourseProfessor(selectedProfessor, $scope.course)
            });
        };

        var addCourseProfessor = function(professor, course) {
            Course.addProfessor(professor.id, course.id)
                .success(loadCourse)
                .error(handleError);
        };

        $scope.addProfessor = function(course) {
            Professor.list()
                .success(function(data, status) {
                    addProfessorSuccess(course, data);
                })
                .error(handleError);
        };

        $scope.destroyProfessor = function(professor, course) {
            Course.destroyProfessor(professor.id, course.id)
                .success(loadCourse)
                .error(handleError);
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

        var courseSuccess = function (data, status) {
            $state.go('dashboard.courses.list');
        };

        var handleError = function (data, status) {
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

    .controller('ProfessorsCtrl', function ($scope, $state, Professor, Error, User) {

        var initialize = function () {
            $scope.professors = [];
            $scope.search = {};
            Professor.list()
                .success(function (data, status) {
                    $scope.professors = data;
                })
                .error(handleError);
        };

        var loadProfessors = function () {

            switch ($scope.user.identity) {
                case User.Identities.administrator:
                    Professor.list()
                        .success(function (data, status) {
                            $scope.professors = data;
                        })
                        .error(handleError);
                    break;
                default:
                    Error.customError('Error', 'No se pudo identificar el tipo de profesor.');
                    break;
            }
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };


        $scope.show = function (professor) {
            $state.transitionTo('dashboard.professors.show', {professorId: professor.id});
        };

        $scope.destroy = function (professor) {
            Professor.destroy(professor.id)
                .success(loadProfessors)
                .error(handleError);
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

        var professorSuccess = function (data, status) {
            $state.go('dashboard.professors.list');
        };

        var handleError = function (data, status) {
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

    .controller('ScoresCtrl', function ($scope, $state, Group, Error, User, Score) {

        var initialize = function () {
            $scope.scores = [];
            $scope.search = {};

            if ($scope.user) {
                loadScores();
            } else {
                $scope.$on('user.loaded', function () {
                    loadScores();
                });
            }
        };

        var loadScores = function () {
            switch ($scope.user.identity) {
                case User.Identities.teacher:
                    Score.scoredGroups()
                        .success(function (data, status) {
                            $scope.scored_groups = data;
                        })
                        .error(handleError);

                    Score.nonScoredGroups()
                        .success(function (data, status) {
                            $scope.non_scored_groups = data;
                        })
                        .error(handleError);
                    break;
                default:
                    Error.customError('Error', 'No se pudo identitficar tu tipo de usuario.');
                    break;
            }
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        initialize();

    })

    .controller('ScoresFormCtrl', function ($scope, $state, $stateParams, Error, Score) {
        var initialize = function () {
            $scope.errors = {};
            $scope.score = {};
        };

        var scoreSuccess = function (data, status) {
            $state.go('dashboard.scores.list');
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
            if (status == 422) {
                $scope.errors = data.errors;
            }
        };

        $scope.save = function (score) {
            score.group_id = $stateParams.groupId;
            Score.save(score)
                .success(scoreSuccess)
                .error(handleError)
        };

        initialize();
    })

    .controller('UsersCtrl', function ($scope, $state, User, Error) {

        var initialize = function () {
            $scope.users = [];
            $scope.search = {};
            User.list()
                .success(function (data, status) {
                    $scope.users = data;
                })
                .error(handleError);

            User.identities()
                .success(function (data, status) {
                    $scope.identities = data;
                })
                .error(handleError);
        };

        var handleError = function (data, status) {
            Error.handleError(data, status);
        };

        $scope.show = function (group) {
            $state.transitionTo('dashboard.groups.show', {groupId: group.id});
        };

        initialize();
    });