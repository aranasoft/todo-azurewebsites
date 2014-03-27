(function ($, window, undefined) {

    var randomPointTotals = function() {
        var tally =  {
            pointsAvailable: Math.floor(Math.random() * (100 - 50 + 1)) + 50
        };
        $.connection.todosHub.client.onTotalsUpdated(tally);
        return;
    };

    var interval;
    $.connection.hub.start = function(){
        if(interval === null || interval === undefined) {
            interval = window.setInterval(function() {
                randomPointTotals();
            }, 1000);
        }

        return {
            done: function(fn){return fn();}
        };
    }
    $.connection.hub.stop = function(){
        if(interval !== null && interval !== undefined) {
            window.clearInterval(interval);
            interval = null;
        }

        return;
    }
    $.connection.todosHub = {
        client: {
            onTotalsUpdated: function() {}
        },
        server: {
            fetchTotals: function(){
              var tally =  {
                pointsAvailable: Math.floor(Math.random() * (100 - 50 + 1)) + 50
              };
              return tally;
            }
        }
    };
}(window.jQuery, window));
