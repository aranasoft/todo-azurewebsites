using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.WindowsAzure.Storage.Queue;
using Newtonsoft.Json;
using TodoList.Data.Messages;

namespace TodoList.Data.Services {
    public class EventQueue : SimpleQueue
    {
        public const string QueueName = "tasklistchanged";
        protected override string Name { get { return QueueName; } }

        public void AddNotification()
        {
            var listChangedEvent = new NotificationEvent {
                EventType = NotificaitonEventType.ListChanged,
                Content = "listChanged"
            };
            var message = new CloudQueueMessage(JsonConvert.SerializeObject(listChangedEvent));
            Queue.AddMessage(message);
        }
    }
}
