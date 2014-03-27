using System;
using System.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Queue;

namespace TodoSample.Data.Services {
    public abstract class SimpleQueue
    {
        protected abstract string Name { get; }

        private CloudStorageAccount _account;
        protected CloudStorageAccount Account
        {
            get
            {
                if (_account != null) return _account;
                var connectionString = ConfigurationManager.ConnectionStrings["storage"];
                _account = CloudStorageAccount.Parse(connectionString.ConnectionString);
                return _account;
            }
        }

        private CloudQueue _queue;
        protected CloudQueue Queue
        {
            get
            {
                if (_queue != null) return _queue;

                var queueClient = Account.CreateCloudQueueClient();
                _queue = queueClient.GetQueueReference(Name);
                _queue.CreateIfNotExists();

                return _queue;
            }
            set { _queue = value; }
        }
    }
}
