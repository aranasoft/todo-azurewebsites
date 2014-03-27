using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using TodoSample.Data.Entities;
using TodoSample.Data.Services;

namespace api.Controllers {
    public class TodosController : ApiController
    {
        //public static TodoServiceList _todoService = new TodoServiceList();
	public static TodoServiceDB _todoService = new TodoServiceDB();

        // GET api/<controller>
        public IEnumerable<Todo> Get()
        {
            return _todoService.All().ToList();
        }

        // GET api/<controller>/5
        public Todo Get(int id)
        {
            return _todoService.Find(id);
        }

        // POST api/<controller>
        public Todo Post([FromBody]Todo newTodo)
        {
            _todoService.Add(newTodo);

	    AddChangeNotification();

            return newTodo;
        }

        // PUT api/<controller>/5
        public Todo Put(int id, [FromBody]Todo updatedTodo)
        {
	    _todoService.Update(updatedTodo);

	    AddChangeNotification();

            return updatedTodo;
        }

        // DELETE api/<controller>/5
        public void Delete(int id) {
	    _todoService.Delete(id);

	    AddChangeNotification();
        }

        private void AddChangeNotification()
        {
            var queue = new EventQueue();
	    queue.AddNotification();
        }
    }
}