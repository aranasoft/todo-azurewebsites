using System;
using System.Configuration;
using System.Collections.Generic;
using System.Data.Entity.Migrations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TodoSample.Data.Entities;

namespace TodoSample.Data.Services {
    public class TodoServiceDB {
        public IEnumerable<Todo> All()
        {
            using (var db = new TodoContext())
            {
                return db.Todos.ToList();
            }
        }

        public Todo Find(int id)
        {
            using (var db = new TodoContext())
            {
                return db.Todos.Find(id);
            }
        }

        public Todo Add(Todo todo)
        {
            using (var db = new TodoContext())
            {
                db.Todos.Add(todo);
                db.SaveChanges();

                return todo;
            }
        }

        public void Update(Todo todo)
        {
            using (var db = new TodoContext())
            {
                db.Todos.AddOrUpdate(todo);
                db.SaveChanges();
            }
        }

        public void Delete(int id)
        {
            using (var db = new TodoContext())
            {
                db.Todos.Remove(new Todo {Id = id});
                db.SaveChanges();
            }
        }

        public int CalculateTotalPoints()
        {
	    var totalPoints = All().Sum(todo => todo.Points);
            return totalPoints;
        }
    }
}
