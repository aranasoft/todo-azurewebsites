using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
// using Newtonsoft.Json;
// using Newtonsoft.Json.Serialization;

namespace TodoList.API {
    public static class WebApiConfig {
        public static void Register(HttpConfiguration config) {
            // Web API configuration and services
            // JsonSerializerSettings settings = GlobalConfiguration.Configuration.Formatters.JsonFormatter.SerializerSettings;
            // settings.ContractResolver = new CamelCasePropertyNamesContractResolver();

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute("DefaultApi", "api/{controller}/{id}", new {id = RouteParameter.Optional});
        }
    }
}