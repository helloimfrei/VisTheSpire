
ui <- fluidPage(
  theme = bs_theme(
    version = 5,
    bg = "#233253",
    fg = "#fcdc0f",
    primary = "#a62121",
    secondary = "#fcdc0f",
    success = "#a62121",
    base_font = font_google("Kreon"),
    code_font = font_google("Kreon")
  ),
  titlePanel('VisTheSpire V0.5.0'),
  spireUI('spire')
)