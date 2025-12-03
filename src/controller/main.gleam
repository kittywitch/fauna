import dream/context.{type EmptyContext}
import dream/http
import dream/http/request.{type Request}
import dream/http/response.{type Response, html_response}
import dream/http/status
import gleam/http as http_lib
import gleam/result
import utilities/response_helpers
import view/main as main_view
import service.{type Services}

/// Index action - displays hello world
pub fn index(
  _request: Request,
  _context: EmptyContext,
  _services: Services,
) -> Response {
  html_response(status.ok, main_view.home_page())
}

pub fn custom_404(
  request: Request,
  _context: EmptyContext,
  _services: Services,
) -> Response {
  let result = {
    use filepath <- result.try(http.require_string(request, "filepath"))
    Ok(filepath)
  }

  case result {
    Ok(filepath) -> html_response(status.not_found, main_view.error_page(filepath))
    Error(err) -> response_helpers.handle_error(err)
  }
}

