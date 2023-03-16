library(shiny)
library(imola)
library(dplyr)

# Application dependencies
include_styles <- tags$head(
  tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
  tags$script(src = "script.js"),
  tags$script(src="highlight.min.js"),
  tags$script("hljs.highlightAll();"),
  tags$link(href = "a11y-dark.min.css", rel = "stylesheet")
)

# Create a single filter as a NLQ preposition
#
# @param prefix_text The text to display before the filter input.
# @param input The input that the user can interact with.
# @param suffix_text The text to display after the filter input.
#
# @return A UI tagList.
filter_preposition <- function(prefix_text, input, suffix_text) {
  div(
    class = "filter-preposition",
    prefix_text, input, suffix_text
  )
}

# Create a full filter query using multiple prepositions
#
# @param prefix_text The text to display at the start of the filter sentence.
# @param Any number of `filter_preposition()` to use in the query filter.
# @param suffix_text The text to display at the end of the filter sentence.
#
# @return A UI tagList.
filter_query <- function(prefix_text = "", ..., suffix_text = "") {
  div(
    class = "filter-query",
    prefix_text, ..., suffix_text
  )
}

# Generate the filter query for the application
filters <- filter_query(
  prefix_text = "Show me",

  # filter number of results
  filter_preposition(
    "",
    selectInput("quantity", "", c(5, 10, 15)),
    "cars,"
  ),

  # number of car gears
  filter_preposition(
    "that have",
    selectInput("gear", "", sort(unique(mtcars$gear))),
    "gears,"
  ),

  # minimum horse power
  filter_preposition(
    "with at least",
    numericInput("hp", "", min(mtcars$hp),
      step = 5,
      min = min(mtcars$hp),
      max = max(mtcars$hp)
    ),
    "horse power,"
  ),

  # fuel usage
  filter_preposition(
    "and that consume at most",
    numericInput("mpg", "", 50,
      step = 10,
      min = min(mtcars$mpg),
      max = 50
    ),
    "miles per gallon."
  ),

  suffix_text = ""
)

# Define UI for the application
ui <- gridPage(
  include_styles,

  areas = list(
    "filters",
    "output"
  ),
  rows = c("auto", "1fr"),

  filters = flexPanel(
    filters
  ),

  output = tableOutput("results"),

  div(
    id = "myNav",
    class = "overlay",
    a(href = "javascript:void(0)", class="closebtn", onclick="closeNav()", "x"),

    div(class="overlay-content",
      includeMarkdown("code.md")
    )
  ),

  div(class = "code-view",
    a(
      href = "javascript:void(0)",
      onclick="openNav()",
      "Preview Code"
    ),
    a(
      href = "https://github.com/Appsilon/natural_language_queries",
      target = "_blank",
      "View on Github"
    )
  )
)

server <- function(input, output, session) {

  # Observe filter values and update the results table
  observeEvent(c(input$quantity, input$hp, input$gear, input$mpg), {

    results <- mtcars

    if (!is.null(input$gear)) {
      results <- results %>%
        filter(gear == as.numeric(input$gear))
    }

    if (!is.null(input$hp)) {
      results <- results %>%
        filter(hp >= input$hp)
    }

    if (!is.null(input$mpg)) {
      results <- results %>%
        filter(mpg <= input$mpg)
    }

    if (!is.null(input$quantity)) {
      results <- results %>%
        slice_head(n = as.numeric(input$quantity))
    }

    output$results <- renderTable(results, rownames = TRUE)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
