using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using TodoSample.Data.Messages;
using TodoSample.Data.Services;

namespace TodoSample.Data.Handlers {
    public class ListChanged {
        public void HandleChange(NotificationEvent changeEvent)
        {
 	    Trace.TraceInformation(changeEvent.Content);

	    // add up the points
            var todoService = new TodoServiceDB();
            var totalPoints = todoService.CalculateTotalPoints();
            var tally = new PointTally {
                PointsAvailable = totalPoints
            };

           var notifictionUrl = ConfigurationManager.AppSettings["notificationUrl"];
           using (var client = new WebClient())
            {
		client.Headers.Add("Content-Type", @"application/json");
                var serializedTally = JsonConvert.SerializeObject(tally);
                client.UploadString(notifictionUrl, serializedTally);
            }
        }
    }
}
