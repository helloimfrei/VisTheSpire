
ui <- fluidPage(titlePanel('VisTheSpire V1.0'),
  spireUI('spire'),
  theme = bs_theme(
    bg = "#231732",
    fg = "#229dbc",
    primary = "#E69F00",
    secondary = "#d7d7d7",
    success = "#E69F00",
    base_font = font_google("Kreon"),
    code_font = font_google("Kreon")
  )
)