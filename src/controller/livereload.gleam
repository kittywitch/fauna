import dream/context.{type EmptyContext}
import dream/http/request.{type Request}
import dream/http/response.{type Response, text_response}
import dream/servers/mist/websocket
import dream/services/broadcaster
import gleam/erlang/process
import gleam/json
import dream/http/status
import gleam/option.{Some}
import service.{type Services}
import gleam/io
import types/reloadpacket.{type ReloadPacket, MicCheck, Reload}
import gleam/string

type LivereloadDependencies {
  LivereloadDependencies(services: Services)
}

pub fn trigger_livereload(
  _request: Request,
  _context: EmptyContext,
  services: Services,
) -> Response {
  broadcaster.publish(services.livereload, Reload)

  text_response(status.ok, "nyaa")
}

pub fn handle_livereload_upgrade(
  request: Request,
  _context: EmptyContext,
  services: Services,
) -> Response {

  let dependencies = LivereloadDependencies(services)

  websocket.upgrade_websocket(
    request,
    dependencies: dependencies,
    on_init: handle_websocket_init,
    on_message: handle_websocket_message,
    on_close: handle_websocket_close,
  )
}

fn handle_websocket_init(
  _connection: websocket.Connection,
  dependencies: LivereloadDependencies,
) -> #(String, option.Option(process.Selector(ReloadPacket))) {
  let LivereloadDependencies(services: services) = dependencies
  let channel = broadcaster.subscribe(services.livereload)

  // 2. Create selector for chat messages
  let selector = broadcaster.channel_to_selector(channel)

  // 3. Notify join
  broadcaster.publish(services.livereload, MicCheck)

  io.println("connection started o:")
  #("hewwo", Some(selector))
}

fn handle_websocket_message(
  state: String,
  message: websocket.Message(ReloadPacket),
  connection: websocket.Connection,
  dependencies: LivereloadDependencies,
) -> websocket.Action(String, ReloadPacket) {
  let LivereloadDependencies(services: _services) = dependencies

  case message {
    websocket.TextMessage(_text) -> {
      websocket.continue_connection(state)
    }
    websocket.CustomMessage(msg) -> {
      io.println(msg |> string.inspect)
      let _ = case msg {
        MicCheck -> {
          let json_msg = json.object([
            #("type", json.string("acknowledgement"))
          ])
          let _ = websocket.send_text(connection, json.to_string(json_msg))
        }
        Reload -> {
          let json_msg = json.object([
            #("type", json.string("reload_request"))
          ])
          let _ = websocket.send_text(connection, json.to_string(json_msg))
        }
      }
      websocket.continue_connection(state)
    }
    websocket.BinaryMessage(_) | websocket.ConnectionClosed ->
      websocket.continue_connection(state)
  }
}

fn handle_websocket_close(_state: String, dependencies: LivereloadDependencies) -> Nil {
  let LivereloadDependencies(services: _services) = dependencies
  Nil
  //broadcaster.publish(services.livereload, )
}
