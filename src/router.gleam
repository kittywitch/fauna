import controller/main as main_controller
import controller/static as static_controller
import controller/livereload as livereload_controller
import dream/context.{type EmptyContext}
import dream/http/request.{Get}
import dream/router.{type Router, route, router}
import service.{type Services}
import middleware/logging

pub fn create_router() -> Router(EmptyContext, Services) {
  let dfm = [
    logging.logging_middleware
  ]
  router()
  |> route(
    method: Get,
    path: "/",
    controller: main_controller.index,
    middleware: dfm,
  )
  |> route(
    method: Get,
    path: "/assets/**filepath",
    controller: static_controller.serve_assets,
    middleware: dfm,
  )
  |> route(
    method: Get,
    path: "/trigger_livereload",
    controller: livereload_controller.trigger_livereload,
    middleware: dfm,
  )
  |> route(
    method: Get,
    path: "/livereload",
    controller: livereload_controller.handle_livereload_upgrade,
    middleware: dfm,
  )
  |> route(
    method: Get,
    path: "/**filepath",
    controller: main_controller.custom_404,
    middleware: dfm,
  )
}
