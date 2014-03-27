using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TodoSample.Data.Entities {
    public class Todo {
        public int Id { get; set; }
        public bool Completed { get; set; }
        public string Content { get; set; }
        public int Points { get; set; }
    }
}
