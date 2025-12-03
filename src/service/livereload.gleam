import dream/services/broadcaster
import types/reloadpacket.{type ReloadPacket}

pub type LiveReload = broadcaster.Broadcaster(ReloadPacket)

pub fn init_livereload() -> LiveReload {
  let assert Ok(livereload) = broadcaster.start_broadcaster()
  livereload
}
