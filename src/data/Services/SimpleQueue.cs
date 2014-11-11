using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Queue;

namespace TodoList.Data.Services {
    public abstract class SimpleQueue {
        private CloudStorageAccount _account;

        private CloudQueue _queue;
        protected abstract string Name { get; }

        protected CloudStorageAccount Account {
            get {
                if (_account != null) return _account;
                ConnectionStringSettings connectionString = ConfigurationManager.ConnectionStrings["storage"];
                _account = CloudStorageAccount.Parse(connectionString.ConnectionString);
                return _account;
            }
        }

        protected CloudQueue Queue {
            get {
                if (_queue != null) return _queue;

                CloudQueueClient queueClient = Account.CreateCloudQueueClient();
                _queue = queueClient.GetQueueReference(Name);
                _queue.CreateIfNotExists();

                return _queue;
            }
            set { _queue = value; }
        }
    }
}