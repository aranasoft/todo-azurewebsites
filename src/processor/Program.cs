using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.WindowsAzure.Jobs;
using Newtonsoft.Json;
using TodoSample.Data.Handlers;
using TodoSample.Data.Messages;
using TodoSample.Data.Services;

namespace TodoSample.Processor {
    class Program {
        static void Main(string[] args)
        {
            var host = new JobHost();
	    host.RunAndBlock();
        }

        public static void ProcessEvent([QueueInput(EventQueue.QueueName)] string message)
        {
            var notificationEvent = JsonConvert.DeserializeObject<NotificationEvent>(message);

            var handler = new ListChanged();
	    handler.HandleChange(notificationEvent);
        }
    } 
}
