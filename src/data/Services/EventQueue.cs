using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.WindowsAzure.Storage.Queue;
using Newtonsoft.Json;
using TodoSample.Data.Messages;

namespace TodoSample.Data.Services {
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
