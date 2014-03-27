(function(window, angular, undefined) {
  'use strict';

  var orbweaver = angular.module('asOrbweaver', ['ngResource']);

  orbweaver.factory("asRestfulResource", ['$resource', function($resource) {
    return function(url, params, methods) {
      var defaults = {
        update: { method: 'put', isArray: false },
	      create: { method: 'post' }
      };

      methods = angular.extend(defaults, methods);

      var resource = $resource(url, params, methods);

      resource.prototype.$save = function (params, success, failure) {
	      if (!this.id) { 
          this.$create(params, success, failure); 
        } else {
	        this.$update(params, success, failure);
	      }
      };

      return resource;
    };
  }]);

  orbweaver.factory("asRestfulService", ['$q', 'asProgressService', function($q, asProgressService) {
    var defer = function(fn, params) {
      params = params || {};
      var deferred = $q.defer();
      asProgressService.start();
      fn(params,
	      function(response) {
	        asProgressService.done();
	        deferred.resolve(response);
	      },
	      function(response) {
	        asProgressService.done();
	        deferred.reject(response);
	      });
      return deferred.promise;
    };

    var deferInstance = function(inst, fn, params) {
      params = params || {};
      var deferred = $q.defer();
      asProgressService.start();
      inst[fn](params,
	      function(response) {
	        asProgressService.done();
	        deferred.resolve(response);
	      },
	      function(response) {
	        asProgressService.done();
	        deferred.reject(response);
	      });
      return deferred.promise;
    };

    return {
      withPromises: function(restfulResource) {
	      return {
	        empty: function() { return new restfulResource(); },
	        all: function(params) { return defer(restfulResource.query, params); },
	        find: function(id, params) {
	          params = params || {};
	          params = _.extend(params, { id: id });
	          return defer(restfulResource.get, params);
          },
	        save: function(res, params) {
	          params = params || {};
	          if (res.id) {
	            params = _.extend(params, { id: res.id });
	            return deferInstance(res, "$update", params);
	          } else {
	            return deferInstance(res, "$create", params);
	          }
	        },
	        delete: function(res, params) { return deferInstance(res, "$delete", { id: res.id }); }
	      };
      }
    };
  }]);

  orbweaver.factory("asProgressService", function() {
    var progressCounter = 0;

    function incrementProgressCounter() {
      if (progressCounter === 0) {
	NProgress.start();
      }
      progressCounter++;
    }

    function decrementProgressCounter() {
      progressCounter--;
      if (progressCounter === 0) {
	NProgress.done();
      }
    }

    return {
      start: function() {
	incrementProgressCounter();
      },
      done: function() {
	decrementProgressCounter();
      }
    };
  });
  orbweaver.constant('asToastrOptions', {
    "closeButton": true,
    "debug": false,
    "positionClass": "toast-top-right",
    "onclick": null,
    "showDuration": "300",
    "hideDuration": "1000",
    "timeOut": "3000",
    "extendedTimeOut": "1000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
  });
  orbweaver.factory("asMessageService", function($rootScope, $timeout, asToastrOptions) {
    toastr.options = asToastrOptions;

    return {
      success: function(message) {
	toastr.success(message);
      },
      info: function(message) {
	toastr.info(message);
      },
      warning: function(message) {
	toastr.warning(message);
      },
      error: function(message) {
	toastr.error(message);
      }
    };
  });


  orbweaver.directive("asWellCollapsible", function () {
    var template =
      '<div class="well well-small" ng-click="toggleCollapse()">' +
	'  <div class="clearfix">' +
	'    <div class="pull-right">' +
	'      <span class="label" ng-show="isCollapsed">{{showText}} <i class="icon-large icon-double-angle-down"></i></span>' +
	'      <span class="label" ng-hide="isCollapsed">{{hideText}} <i class="icon-large icon-double-angle-up"></i></span>' +
	'    </div>' +
	'  </div>' +
	'  <div ng-hide="isCollapsed" ng-transclude>' +
	'  </div>' +
	'</div>';
    return {
      restrict: "EA",
      template: template,
      transclude: true,
      controller: function ($scope, $element, $attrs) {
	this.expandChild = function() { };
      },
      link: function (scope, element, attrs, controller) {
	scope.isCollapsed = true;
	scope.toggleCollapse = function () {
	  console.log('toggle collapse called');
	  scope.isCollapsed = !scope.isCollapsed;
	  controller.expandChild();
	};
      },
      scope: {
	showText: "@",
	hideText: "@"
      }
    };
  });
})(window, window.angular);

