angular.module 'asTodo',['asOrbweaver','SignalR']

todoApp = angular.module 'asTodo'

todoApp.factory "TodoService", ->
  todos: [
    {completed: false, content: "first todo", points: 32}
    {completed: true, content: "second todo", points: 42}
    {completed: true, content: "third todo", points: 52}
  ]
  tally:
    points: 0

  fetchTodos: ()->
    @todos

  fetchTotals: ()->
    @tally.points = _(@todos).reduce( ( (total,todo) -> return total + todo.points ),0 )

  removeTodo: (todo)->
    index = @todos.indexOf todo
    @todos.splice index,1
    @fetchTotals()

  newTodo: () ->
    {}

  addTodo: (todo)->
    @todos.push todo
    @fetchTotals()

  updateTodo: (todo)->
    index = @todos.indexOf todo
    @todos[index] = todo
    @fetchTotals()

#todoApp.factory "asTodoApi",(asRestfulResource, asRestfulService)->
#  res = new asRestfulResource '/api/todos/:id', {}
#  new asRestfulService.withPromises res
#
#
#todoApp.factory "TodoService", (asTodoApi,$,$q,$rootScope)->
#  todos = [ ]
#  tally = { points: 0}
#  hub = $.connection.todosHub
#  hub.client.onTotalsUpdated = (pointTally) ->
#    tally.points = pointTally.pointsAvailable
#    $rootScope.$apply() unless $rootScope.$$phase?
#
#  todos: todos
#  tally: tally
#
#  fetchTodos: ()->
#    defer = asTodoApi.all()
#    defer.then (res)->
#      angular.copy res, todos
#
#  fetchTotals: ()->
#    $q.when $.connection.hub.start(), () ->
#      hub.server.fetchTotals()
#
#  removeTodo: (todo)->
#    q = asTodoApi.delete todo
#    q.then ()->
#      index = todos.indexOf todo
#      todos.splice index,1
#
#  addTodo: (todo)->
#    q = asTodoApi.save todo
#    q.then () ->
#      todos.push todo
#
#  newTodo: () ->
#    asTodoApi.empty()
#
#  updateTodo: (todo)->
#    asTodoApi.save todo

todoApp.controller 'TodoController', ($scope,TodoService) ->
  TodoService.fetchTotals()
  TodoService.fetchTodos()
  $scope.todos = TodoService.todos
  $scope.tally = TodoService.tally
  $scope.newTodo = TodoService.newTodo()

  $scope.removeItem = (todo) ->
    TodoService.removeTodo todo

  $scope.addItem = (todo) ->
    TodoService.addTodo todo
    $scope.newTodo = TodoService.newTodo()

  $scope.updateItem = (todo) ->
    TodoService.updateTodo todo

