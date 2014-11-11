using System;
using System.Threading.Tasks;
using Microsoft.Owin;
using Microsoft.Owin.Cors;
using Owin;

[assembly: OwinStartup(typeof(TodoSample.Api.OwinStartup))]

namespace TodoSample.Api {
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
