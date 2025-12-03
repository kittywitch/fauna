//// Static file serving controllers for the example app

import dream/context.{type EmptyContext}
import dream/controllers/static
import dream/http/request.{type Request, get_param}
import dream/http/response.{type Response, html_response}
import dream/http/status
import service.{type Services}

/// Serve with custom 404
pub fn serve_assets(
  request: Request,
  context: EmptyContext,
  services: Services,
) -> Response {
  case get_param(request, "filepath") {
    Ok(param) ->
      static.serve(
        request: request,
        context: context,
        services: services,
        root: "./assets",
        filepath: param.raw,
        config: static.default_config()
          |> static.with_custom_404(fn(_req, _ctx, _svc) {
            html_response(
              status.not_found,
              "<h1>Custom 404</h1><p>The requested file does not exist.</p>",
            )
          }),
      )
    Error(error_msg) ->
      html_response(
        status.bad_request,
        "<h1>Error</h1><p>" <> error_msg <> "</p>",
      )
  }
}
