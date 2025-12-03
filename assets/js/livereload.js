function connect() {
  var socket = new WebSocket("ws://localhost:3000/livereload");

  socket.onclose = function(event) {
    console.log("Websocket connection closed or unable to connect; " +
      "starting reconnect timeout");

    socket = null;

    setTimeout(function() {
      connect();
    }, 5000)
  }


  socket.onmessage = function(event) {
    var data = JSON.parse(event.data);
    console.log(data);
    switch(data.type) {
      case "acknowledgement":
        console.log("Received acknowledgement from server")
        break;

      case "reload_request":
        socket.close(1000, "Reloading page after receiving reload_request");

        console.log("Reloading page after receiving reload_request");
        location.reload(true);

        break;

      default:
        console.log(`Don't know how to handle type '${data.type}'`);
    }
  }
}

connect();
