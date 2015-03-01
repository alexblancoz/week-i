"use strict";

angular.module('WeekI.resources', ['ActiveRecord'])

    .factory('User', ['ActiveRecord', 'Configuration', 'Storage', function (ActiveRecord, Configuration, Storage) {

        var User = ActiveRecord.extend(
            {
                $urlRoot: Configuration.apiEndpoint + '/users',

                $headers: function () {
                    return {
                        'Auth-Token': Storage.get('token'),
                        'Auth-Secret': Storage.get('secret')
                    };
                }
            },
            {
                list: function () {
                    return this.post('list.json', {});
                },

                show: function (userId) {
                    return this.post('show.json', {
                        data: {
                            id: userId
                        }
                    });
                },

                login: function (enrollment, password) {
                    return this.post('login.json', {
                        data: {
                            enrollment: enrollment,
                            password: password
                        }
                    });
                },

                create: function (params) {
                    return this.post('create.json', {
                        data: params
                    });
                },

                update: function (params) {
                    return this.post('update.json', {
                        data: params
                    });
                },

                updatePassword: function (old_password, password, password_confirmation) {
                    return this.post('update_password.json', {
                        data: {
                            old_password: old_password,
                            password: password,
                            password_confirmation: password_confirmation
                        }
                    });
                },

                dashboard: function() {
                    return this.post('dashboard.json');
                },

                majors: function() {
                    return this.post('majors.json');
                },

                campuses: function() {
                    return this.post('campuses.json');
                },

                identities: {
                    administrator: 0,
                    user: 1,
                    teacher: 2
                }

            });

        return User;

    }])

    .factory('Group', ['ActiveRecord', 'Configuration', 'Storage', function (ActiveRecord, Configuration, Storage) {

        var Group = ActiveRecord.extend(
            {
                $urlRoot: Configuration.apiEndpoint + '/groups',

                $dataWrapper: 'group',

                $headers: function () {
                    return {
                        'Auth-Token': Storage.get('token'),
                        'Auth-Secret': Storage.get('secret')
                    };
                }
            },
            {
                list: function () {
                    return this.post('list.json', {});
                },

                scored: function () {
                    return this.post('scored.json', {});
                },

                nonScored: function () {
                    return this.post('non_scored.json', {});
                },

                show: function (groupId) {
                    return this.post('show.json', {
                        data: {
                            id: groupId
                        }
                    });
                },

                save: function (params) {
                    var action = 'create.json';
                    if (params.hasOwnProperty('id') && params.id != null) {
                        action = 'update.json';
                    }
                    return this.post(action, {
                        data: params
                    });
                },

                destroy: function (courseId) {
                    return this.post('destroy.json', {
                        data: {
                            id: courseId
                        }
                    });
                },

                addMembership: function(groupId) {
                    return this.post('add_membership.json', {
                        data: {
                            id: groupId
                        }
                    });
                },

                destroyMembership: function() {
                    return this.post('destroy_membership.json', {});
                },

                acceptMembership: function(userId) {
                    return this.post('accept_membership.json', {
                        data: {
                            id: userId
                        }
                    });
                },

                status: {
                    request: 0,
                    member: 1
                }
            });

        return Group;

    }])

    .factory('Course', ['ActiveRecord', 'Configuration', 'Storage', function (ActiveRecord, Configuration, Storage) {

        var Course = ActiveRecord.extend(
            {
                $urlRoot: Configuration.apiEndpoint + '/courses',

                $dataWrapper: 'course',

                $headers: function () {
                    return {
                        'Auth-Token': Storage.get('token'),
                        'Auth-Secret': Storage.get('secret')
                    };
                }
            },
            {
                taken: function () {
                    return this.post('taken.json', {});
                },

                notTaken: function () {
                    return this.post('not_taken.json', {});
                },

                show: function (groupId) {
                    return this.post('show.json', {
                        data: {
                            id: groupId
                        }
                    });
                },

                save: function (params) {
                    var action = 'create.json';
                    if (params.hasOwnProperty('id') && params.id != null) {
                        action = 'update.json';
                    }
                    return this.post(action, {
                        data: params
                    });
                },

                destroy: function (courseId) {
                    return this.post('destroy.json', {
                        data: {
                            id: courseId
                        }
                    });
                },

                destroyProfessor: function (courseProfessorUserId) {
                    return this.post('destroy_professor.json', {
                        data: {
                            id: courseProfessorUserId
                        }
                    });
                },

                addProfessor: function(courseProfessorId) {
                    return this.post('add_professor.json', {
                        data: {
                            id: courseProfessorId
                        }
                    });
                },

                professors: function(courseId) {
                    return this.post('professors.json', {
                        data: {
                            id: courseId
                        }
                    });
                }
            });

        return Course;

    }])

.factory('Professor', ['ActiveRecord', 'Configuration', 'Storage', function (ActiveRecord, Configuration, Storage) {

        var Professor = ActiveRecord.extend(
            {
                $urlRoot: Configuration.apiEndpoint + '/professors',

                $dataWrapper: 'professor',

                $headers: function () {
                    return {
                        'Auth-Token': Storage.get('token'),
                        'Auth-Secret': Storage.get('secret')
                    };
                }
            },
            {
                list: function () {
                    return this.post('list.json', {});
                },

                save: function (params) {
                    var action = 'create.json';
                    if (params.hasOwnProperty('id') && params.id != null) {
                        action = 'update.json';
                    }
                    return this.post(action, {
                        data: params
                    });
                },

                destroy: function (courseId) {
                    return this.post('destroy.json', {
                        data: {
                            id: professorId
                        }
                    });
                }
            });

        return Professor;

    }]);
