library(shiny)
function(input, output, session) {
  # 1. Create a reactive value for the current painting's row number
  rv <- reactiveValues(painting = 1)
  
  # 2. Create a reactive expression for the current painting's data
  current_painting <- reactive({
    paintings[rv$painting,]
  })
  
  # 3. Create a text renderer for the current painting's title
  output$title <- renderText({
    sprintf(
      "%s: %s",
      current_painting()$episode,
      current_painting()$title
    )
  })
  
  # 4. Complete the image renderer's code for the current painting's image
  output$painting <- renderImage({
    list(src = file.path("data", "images", current_painting()$image))
  }, deleteFile = FALSE)
  
  # 5. Use observeEvent() to make the buttons switch between paintings
  observeEvent(input$btn_previous, {
    rv$painting <- max(1, rv$painting - 1)
  })
  
  observeEvent(input$btn_next, {
    rv$painting <- min(NROW(paintings), rv$painting + 1)
  })
  
  # 6. Add sliders for quickly choosing the season and episode
  observe({
    chosen_episode <- sprintf("S%iE%i", input$season, input$episode)
    rv$painting <- match(chosen_episode, paintings$episode)
  })
  
  # 7. Add a carousel feature to the gallery using time-based invalidation
  observe({
    # If the carousel mode is enabled
    if(input$carousel_enable){
      # Invalidate this observer in a few seconds
      invalidateLater(input$carousel_speed * 1000)
      # Show the next painting
      rv$painting <- (isolate(rv$painting)) %% NROW(paintings) + 1
    }
  })
  
  # 8. Update the slider values to always represent the current image
  observe({
    # Get the current painting's episode
    episode <- current_painting()$episode
    # Separate the season from the episode, and then extract the numbers
    episode <- parse_number(strsplit(episode, "E")[[1]])
    # Update the value of the season and episode sliders
    updateSliderInput(session, "season", value = episode[1])
    updateSliderInput(session, "episode", value = episode[2])
  })
  
  # 9. Conditionally display carousel speed
  output$ui_carousel_speed <- renderUI({
    if(input$carousel_enable){
      sliderInput("carousel_speed", label = "Carousel speed:", min = 1, max = 15, value = 3, step = 0.5)
    }
    else{
      NULL
    }
  })
}
