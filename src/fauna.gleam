import dream/servers/mist/server.{bind, listen, router, context, services}
as dream
import dream/context.{EmptyContext}
import router.{create_router}
import service
import radiate
import dream/services/broadcaster
import filespy.{type Event, Modified, Closed}
import gleam/io
import gleam/erlang/process
import gleam/string
import gleam/option
import dream_ets/config as ets
import dream_ets/table
import dream_ets/operations
import child_process
import child_process/stdio
import dream_http_client/client
import gleam/http as http_lib

pub fn broadcast_livereload() {
  let req = client.new
  |> client.method(http_lib.Get)
  |> client.scheme(http_lib.Http)
  |> client.host("localhost:3000")
  |> client.path("/trigger_livereload")
  |> client.add_header("User-Agent", "kat-reloader")

  let _ = client.send(req)
}

pub fn compile_sass() {
      io.println("Beginning SASS recompilation!")
      let _ = child_process.new("make")
      |> child_process.args(["sass"])
      |> child_process.stdio(stdio.lines(fn(line) {
        io.println(line)
      }))
      |> child_process.spawn()
    io.println("SASS recompilation complete.")
}

pub fn main() {
  let assert Ok(sem_table) = ets.new("RecompSemaphore")
    |> ets.key_string()
    |> ets.value_string()
    |> ets.create()

  compile_sass()

  io.println("Beginning SCSS recompilation watcher")
  let _ses = filespy.new()
  |> filespy.add_dir("assets/scss")
  |> filespy.set_handler(fn (path, event) {
    io.println("SCSS Filespy says " <> path <> " has been " <> {event |> string.inspect()})
    case event {
      Closed -> compile_sass()
      _ -> Nil
    }
    Nil
  })
  |> filespy.start()

  io.println("Beginning Gleam recompilation watcher")
  let _res = radiate.new()
  |> radiate.add_dir(".")
  |> radiate.on_reload(fn (_path, event) {
    io.println("Gleam Radiate says path " <> event <> " has requested recompilation")
      case operations.get(sem_table, "sem") {
        Ok(option.Some(_v)) -> {
          io.println("awa!")
          Nil
        }
        Ok(option.None) -> {
          let _ = operations.set(sem_table, "sem", "nyaa~")
          io.println("ooh!")
          let _ =  broadcast_livereload()
          process.sleep(5000)
          let _ = operations.delete(sem_table, "sem")
          Nil
        }
        Error(_err) -> {
          Nil
        }
      }
    Nil
    })
    |> radiate.start()

  io.println("Services initializing")
  let app_services = service.initialize()
  io.println("Services initialized")

  io.println("Starting dream server")
  dream.new()
  |> context(EmptyContext)
  |> services(app_services)
  |> router(create_router())
  |> bind("localhost")
  |> listen(3000)
}
