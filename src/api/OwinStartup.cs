using System;
using Microsoft.Owin;
using Microsoft.Owin.Cors;
using Owin;
using TodoList.API;

[assembly: OwinStartup(typeof (OwinStartup))]

namespace TodoList.API {
    public class OwinStartup {
        public void Configuration(IAppBuilder app) {
            app.Map("/signalr", builder => {
                builder.UseCors(CorsOptions.AllowAll);
                builder.RunSignalR();
            });
            // For more information on how to configure your application, visit http://go.microsoft.com/fwlink/?LinkID=316888
        }
    }
}