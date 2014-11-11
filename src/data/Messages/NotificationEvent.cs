using System;
using System.Collections.Generic;
using System.Linq;

namespace TodoList.Data.Messages {
    public enum NotificaitonEventType {
        ListChanged = 0
    }

    public class NotificationEvent {
        public NotificaitonEventType EventType { get; set; }
        public string Content { get; set; }
    }
}