using Microsoft.AspNet.SignalR;
using TodoSample.Data.Messages;
using TodoSample.Data.Services;

namespace TodoSample.Api.Hubs {
    public class TodosHub : Hub {
        public void FetchTotals()
        {
            var todoService = new TodoServiceDB();
            var pointTally = new PointTally
            {
		PointsAvailable = todoService.CalculateTotalPoints()
            };
            Clients.All.OnTotalsUpdated(pointTally);
        }
    }
}