using System.Web.Http;
using Microsoft.AspNet.SignalR;
using TodoList.API.Hubs;
using TodoList.Data.Messages;

namespace TodoList.API.Controllers {
    public class NotificationController : ApiController {
        // POST api/notification
        public void Post([FromBody] PointTally tally) {
            IHubContext todoHub = GlobalHost.ConnectionManager.GetHubContext<TodosHub>();
            todoHub.Clients.All.OnTotalsUpdated(tally);
        }
    }
}