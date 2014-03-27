_ = require 'lodash'

todos = [
  {id: 1, completed: false, content: "first todo", points: 32}
  {id: 2, completed: true, content: "second todo", points: 42}
  {id: 3, completed: true, content: "third todo", points: 52}
]

module.exports =
  drawRoutes: (app) =>
    app.get '/signalr/hubs', (req, res) ->
      res.type 'js'
      res.sendfile './server/testTodoHub.js'

    app.get '/api/todos/:id', (req, res) ->
      id = Number(req.params.id)
      todo = _(todos).find (t) ->
        t.id == id

      res.json todo

    app.get '/api/todos', (req, res) ->
      res.json todos

    app.post '/api/todos', (req, res) ->
      maxIndexItem = _.max todos, 'id'
      nextIndex = maxIndexItem.id + 1

      console.log 'body: ', req.body
      
      newTodo = req.body
      newTodo.id = nextIndex
      todos.push newTodo

      res.json newTodo

    app.put '/api/todos/:id', (req, res) ->
      id = Number(req.params.id)

      updatedTodo = req.body
      existingTodo = _(todos).findWhere {id: id}
      existingTodo.completed = updatedTodo.completed
      existingTodo.content = updatedTodo.content
      existingTodo.points = updatedTodo.points

      res.json existingTodo

    app.delete '/api/todos/:id', (req,res) ->
      id = Number(req.params.id)
      _(todos).remove (todo)->
        todo.id == id
      res.setHeader "content-type", "application/json"
      res.end "{}"

