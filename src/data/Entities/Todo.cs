using System;
using System.Collections.Generic;
using System.Linq;

namespace TodoList.Data.Entities {
    public class Todo {
        public int Id { get; set; }
        public bool Completed { get; set; }
        public string Content { get; set; }
        public int Points { get; set; }
    }
}