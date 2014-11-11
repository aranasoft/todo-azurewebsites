using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;

namespace TodoList.API
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services
            //var settings = GlobalConfiguration.Configuration.Formatters.JsonFormatter.SerializerSettings;
	    //settings.ContractResolver = new CamelCasePropertyNamesContractResolver();

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }
    }
}
