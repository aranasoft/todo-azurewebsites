using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using TodoList.Data.Handlers;
using TodoList.Data.Messages;
using TodoList.Data.Services;

namespace TodoList.Processor {
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
