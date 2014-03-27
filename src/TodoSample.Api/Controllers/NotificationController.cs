using System.Web.Http;
using Microsoft.AspNet.SignalR;
using TodoSample.Api.Hubs;
using TodoSample.Data.Entities;
using TodoSample.Data.Messages;

namespace api.Controllers {
    public class NotificationController : ApiController {
        // POST api/notification
        public void Post([FromBody]PointTally tally)
        {
            var todoHub = GlobalHost.ConnectionManager.GetHubContext<TodosHub>();
	    todoHub.Clients.All.OnTotalsUpdated(tally);
        }

    }
}