using System;
using System.Collections.Generic;
using System.Linq;
using TodoList.Data.Entities;

namespace TodoList.Data.Services {
    public class TodoServiceList {
        public static List<Todo> _todos = new List<Todo> {
            new Todo {Id = 1, Completed = true, Content = "initial todo", Points = 42}
        };

        public IEnumerable<Todo> All() {
            return _todos;
        }

        public Todo Find(int id) {
            return _todos.First(todo => todo.Id == id);
        }

        public Todo Add(Todo newTodo) {
            newTodo.Id = _todos.Any() ? _todos.Max(todo => todo.Id) + 1 : 1;
            _todos.Add(newTodo);

            return newTodo;
        }

        public void Update(Todo updatedTodo) {
            Todo existingTodo = _todos.First(todo => todo.Id == updatedTodo.Id);
            int existingIndex = _todos.IndexOf(existingTodo);
            _todos[existingIndex] = updatedTodo;
        }

        public void Delete(int id) {
            _todos.RemoveAll(todo => todo.Id == id);
        }
    }
}