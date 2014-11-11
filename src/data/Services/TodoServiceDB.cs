using System;
using System.Collections.Generic;
using System.Data.Entity.Migrations;
using System.Linq;
using TodoList.Data.Entities;

namespace TodoList.Data.Services {
    public class TodoServiceDB {
        public IEnumerable<Todo> All() {
            using (var db = new TodoContext()) {
                return db.Todos.ToList();
            }
        }

        public Todo Find(int id) {
            using (var db = new TodoContext()) {
                return db.Todos.Find(id);
            }
        }

        public Todo Add(Todo todo) {
            using (var db = new TodoContext()) {
                db.Todos.Add(todo);
                db.SaveChanges();

                return todo;
            }
        }

        public void Update(Todo todo) {
            using (var db = new TodoContext()) {
                db.Todos.AddOrUpdate(todo);
                db.SaveChanges();
            }
        }

        public void Delete(int id) {
            using (var db = new TodoContext()) {
                db.Todos.Remove(new Todo {Id = id});
                db.SaveChanges();
            }
        }

        public int CalculateTotalPoints() {
            int totalPoints = All().Sum(todo => todo.Points);
            return totalPoints;
        }
    }
}