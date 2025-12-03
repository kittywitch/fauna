import dream/context.{type EmptyContext}
import dream/http/request.{type Request}
import dream/http/response.{type Response}
import gleam/int
import gleam/io
import service.{type Services}

pub fn logging_middleware(
  request: Request,
  context: EmptyContext,
  services: Services,
  next: fn(Request, EmptyContext, Services) -> Response,
) -> Response {
  io.println(request.path <> " → processing...")

  let response = next(request, context, services)

  io.println(request.path <> " → " <> int.to_string(response.status))

  response
}
