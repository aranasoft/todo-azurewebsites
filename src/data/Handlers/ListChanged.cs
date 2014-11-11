using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.Net;
using Newtonsoft.Json;
using TodoList.Data.Messages;
using TodoList.Data.Services;

namespace TodoList.Data.Handlers {
    public class ListChanged {
        public void HandleChange(NotificationEvent changeEvent) {
            Trace.TraceInformation(changeEvent.Content);

            // add up the points
            var todoService = new TodoServiceDB();
            int totalPoints = todoService.CalculateTotalPoints();
            var tally = new PointTally {
                PointsAvailable = totalPoints
            };

            string notifictionUrl = ConfigurationManager.AppSettings["notificationUrl"];
            using (var client = new WebClient()) {
                client.Headers.Add("Content-Type", @"application/json");
                string serializedTally = JsonConvert.SerializeObject(tally);
                client.UploadString(notifictionUrl, serializedTally);
            }
        }
    }
}