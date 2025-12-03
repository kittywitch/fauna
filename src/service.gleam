import service/livereload.{type LiveReload, init_livereload}
import service/livereload as livereload_service

/// Application services
///
/// Holds all application-level dependencies shared across requests.
pub type Services {
  Services(livereload: LiveReload)
}

/// Initialize all application services
///
/// Creates and returns a Services instance with all initialized dependencies.
///
/// ## Example
///
/// ```gleam
/// let app_services = services.initialize()
/// ```
pub fn initialize() -> Services {
  let livereload = init_livereload()
  Services(livereload: livereload)
}
