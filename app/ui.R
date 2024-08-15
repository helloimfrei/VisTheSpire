
ui <- fluidPage(
  theme = bs_theme(
    bg = "#233253",
    fg = "#fcdc0f",
    primary = "#a62121",
    secondary = "#fcdc0f",
    success = "#a62121",
    base_font = font_google("Kreon"),
    code_font = font_google("Kreon")
  ),
  titlePanel('VisTheSpire V1.0'),
  spireUI('spire')
)