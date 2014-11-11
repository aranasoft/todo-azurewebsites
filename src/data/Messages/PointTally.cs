using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;

namespace TodoList.Data.Messages {
    public class PointTally {
        [JsonProperty("pointsAvailable")]
        public int PointsAvailable { get; set; }
    }
}