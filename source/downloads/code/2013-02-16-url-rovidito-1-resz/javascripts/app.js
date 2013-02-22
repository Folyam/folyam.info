var App = {
  controllers: {},
  configuration: {
    domain: "s.l",
    protocol: "http"
  },
  utils: {}
};

(function UrlUtils (app) {
  app.utils.url = {
    get: function(path) {
      return app.configuration.protocol + "://" + app.configuration.domain + path;
    }
  };
})(App);

(function LinkController (app) {
  app.controllers.Link = function ($scope) {
    $scope.links = [];
    $scope.addLink = function addLink () {
      $scope.links.unshift({
        short: App.utils.url.get("/a4d56g"),
        long: $scope.newLink,
        clicks: 0,
        created_at: new Date()
      });

      $scope.newLink = "";
      return null;
    };
  };
  app.controllers.Link.$inject = ['$scope'];
})(App);
