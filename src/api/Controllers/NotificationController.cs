using System.Web.Http;
using TodoList.API.Hubs;
using TodoList.Data.Messages;

namespace TodoList.API.Controllers {
    public class NotificationController : ApiController {
        // POST api/notification
        public void Post([FromBody]PointTally tally)
        {
            var todoHub = GlobalHost.ConnectionManager.GetHubContext<TodosHub>();
	    todoHub.Clients.All.OnTotalsUpdated(tally);
        }

    }
}