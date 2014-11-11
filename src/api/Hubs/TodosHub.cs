using TodoList.Data.Messages;
using TodoList.Data.Services;

namespace TodoList.API.Hubs {
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