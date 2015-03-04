"use strict";

angular.module('WeekI.services', [])

    .service('Configuration', function () {
        this.requestProtocol = 'http';
        this.domainName = 'localhost:3000';
        this.endpoint = this.requestProtocol + '://' + this.domainName;
        this.apiEndpoint = this.endpoint + '/api/v1';
    })


    .service('Session', ['Storage', function (Storage) {
        return {

            save: function (token, secret, user_identity) {
                Storage.set('token', token);
                Storage.set('secret', secret);
                Storage.set('user_identity', user_identity);
            },

            clear: function () {
                Storage.remove('token');
                Storage.remove('secret');
                Storage.remove('user_identity');
            },

            load: function () {
                return {
                    token: Storage.get('token'),
                    secret: Storage.get('secret'),
                    user_identity: Storage.get('user_identity')
                };
            }

        };
    }])

    .service('Storage', function () {
        return {

            get: function (key) {
                var value = window.localStorage[key];
                if (value) {
                    return angular.fromJson(value);
                }
                return null;
            },

            set: function (key, value) {
                window.localStorage[key] = angular.toJson(value);
            },

            remove: function (key) {
                localStorage.removeItem(key);
            },

            clear: function () {
                window.localStorage.clear();
            }

        };
    })

    .service('Helper', function () {

        var binarySearch = function (array, start, end, key, value) {
            if (start > end) {
                return -1;
            }

            var half = ((end + start) / 2) << 0;

            if (array[half][key] > value) {
                return binarySearch(array, start, half - 1, key, value);
            } else if (array[half][key] < value) {
                return binarySearch(array, half + 1, end, key, value);
            } else {
                return half;
            }
        };

        return {

            filterObject: function (rules, object) {
                var newObj = {};

                for (var attr in rules) {
                    if (object && object.hasOwnProperty(attr)) {
                        newObj[attr] = object[attr];
                    } else {
                        newObj[attr] = null;
                    }
                }

                return newObj;
            },

            mergeObjects: function (object1, object2) {
                var newObj = {};

                for (var attr in object1) {
                    newObj[attr] = object1[attr];
                }

                for (var attr in object2) {
                    newObj[attr] = object2[attr];
                }

                return newObj;
            },

            binarySearch: function (array, key, value) {
                return binarySearch(array, 0, array.length - 1, key, value);
            },

            innerWidth: function (element) {
                var styles = window.getComputedStyle(element);
                return element.offsetWidth - parseFloat(styles.paddingLeft) - parseFloat(styles.paddingRight);
            },

            messageFromObject: function(obj, show_keys) {
                if (typeof show_keys == undefined) show_keys = false;

                var message = '';
                for (var key in obj) {
                    if (show_keys) {
                        message += key + ': ' + obj[key];
                    } else {
                        message += obj[key];
                    }

                }
                return message;
            },

            search: function(arr, value) {
                for (var i = 0; i < arr.length; ++i) {
                    if (arr[i] == value) {
                        return i;
                    }
                }
                return -1;
            }
        }
    })

    .service('Error', ['$state', '$modal', 'Session', function ($state, $modal, Session) {

        var showPopup = function (title, content) {
            $modal.open({
                templateUrl: 'splash/modal',
                controller: 'ErrorCtrl',
                resolve: {
                    title: function() {
                        return title;
                    },
                    content: function() {
                        return content;
                    }
                }
            });
        };

        return {

            handleError: function (data, status) {
                switch (status) {
                    case 401:
                        Session.clear();
                        $state.go('splash.login');
                        if (data.hasOwnProperty('error')) {
                            showPopup('Error del servidor', data.error.message);
                        } else {
                            showPopup('Error del servidor', 'Invalid credentials');
                        }
                        break;
                    case 422:
                        break;
                    default:
                        if (data.hasOwnProperty('error')) {
                            showPopup('Error del servidor: ' + status, data.error.message);
                        } else {
                            showPopup('Error del servidor: '  + status, 'Hubo un error desconocido en el servidor.');
                        }

                        break;
                }
            },

            customError: function (title, message) {
                showPopup(title, message);
            }

        };

    }]);