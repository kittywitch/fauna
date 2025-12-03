import nakai
import nakai/html.{type Node}
import nakai/attr.{type Attr}

pub fn head(title: String, dev_mode: Bool) -> Node {
  let dev_script = case dev_mode {
    True -> [
      html.Script([
        attr.src("/assets/js/livereload.js")
      ],"")
    ]
    False -> []
  }
  html.Head([
    html.meta([
      attr.name("viewport"),
      attr.content("width=device-width, initial-scale=1"),
    ]),
    html.link([
      attr.rel("stylesheet"),
      attr.type_("text/css"),
      attr.href("/assets/css/stylesheet.css"),
    ]),
    html.title(title),
    ..dev_script
  ])
}

pub fn header(title: String) -> Node {
  html.header([
    ], [
    html.nav([], [
      html.ul([], [
        html.h1_text([], title),
      ]),
      html.ul([], [
        list_link("/", "Home"),
        list_link("/blog", "Blog"),
        list_link("/external", "External"),
      ]),
    ])
  ])
}

pub fn a_link(link: String, label: String, newtab: Bool) -> Node {
  let newtab_attr = case newtab {
    True -> [attr.rel("noopener noreferrer"), attr.target("_blank")]
    False -> []
  }
  html.a_text([
    attr.href(link),
    ..newtab_attr
  ], label)
}

pub fn list_link(link: String, label: String) -> Node {
  html.li([], [
    a_link(link, label, False)
  ])
}

pub fn nav(items: List(Node)) -> Node {
  html.nav([], [
    html.ul([], items)
  ])
}

pub fn render(main: Node) -> Node {
  let title = "dork.dev (development)"
  html.Fragment([
    head(title, True),
    html.Body(
      [
        attr.class("container"),
      ],
      [
        header(title),
        html.main([], [
          main
        ]),
        html.footer([
        ], [
          html.span([], [
            html.Text("Written with "),
            a_link("https://gleam.run/", "Gleam", True),
            html.Text(" in Canada! 🇨🇦"),
        ]),
        ]),
      ]
    ),
  ])
}

pub fn error_page(filepath: String) -> String {
  render(html.Fragment([
    html.Element("hgroup", [], [
      html.h2_text([], "404: Path \"" <> filepath <> "\" not found!"),
      html.span([], [
        html.Text("Click "),
        a_link("/", "here", False),
        html.Text(" to return home."),
      ])
    ])
  ]))
  |> nakai.to_string()
}

pub fn home_page() -> String {
  render(html.Fragment([
    html.p_text([], "Hi!")
  ]))
  |> nakai.to_string()
}
