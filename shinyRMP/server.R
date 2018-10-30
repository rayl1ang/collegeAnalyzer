shinyServer(function(input, output, session){
  
  
  #render gVis plot
  rmp_agg <- reactive({
    rmp_df %>% 
      filter(state %in% state.abb) %>% 
      group_by(state) %>% 
      summarise_at(.vars = input$criteria, .funs = mean)
    })
  
  
  output$attrib_map <- renderGvis({
    gvisGeoChart(rmp_agg(), "state", colnames(rmp_agg()[2]),
                 options=list(region="US", displayMode="regions", 
                              resolution="provinces",
                              width="auto", height="auto"))
  })
  
  #shool comparisons
  
  #dataframe for number of reviews based on slider
  school_compare1 <- reactive({
    rmp_df %>%
      filter(state_name == input$compare_selectstate1) %>%
      filter(num_schoolratings >= input$numreview_slider[1] &
             num_schoolratings <= input$numreview_slider[2])
  })

  school_compare2 <- reactive({
    rmp_df %>%
      filter(state_name == input$compare_selectstate2) %>%
      filter(num_schoolratings >= input$numreview_slider[1] &
               num_schoolratings <= input$numreview_slider[2])
  })
  
  observe({
    
    school_observe1 <- unique(sort(school_compare1()$school))
    
    school_observe2 <- unique(sort(school_compare2()$school))
    
    updateSelectizeInput(session, inputId = "school1",
                       choices = c(school_observe1))

    updateSelectizeInput(session, inputId = "school2",
                       choices = c(school_observe2))
  })

  user_df <- eventReactive(input$go, {
    rmp_df %>%
     filter(school == input$school1 | school == input$school2)
  })
  
  output$boxplot <- renderPlot({
    initial_df <- rmp_df %>%
      filter(school == "American International College" | school == "Albertus Magnus College")

    if (input$go == 0) {
      plot_df <- initial_df
    } else {
      plot_df <- user_df()
    }

    plot_df <- gather(plot_df, key = "Criteria", value = "Scores", Clubs:Social)

    plot_df %>%
      ggplot() +
      geom_violin(aes(Criteria, Scores, fill = factor(Criteria))) +
      facet_grid(~school) + 
      scale_fill_brewer(palette = "Set3") +
      theme(plot.subtitle = element_text(vjust = 1), 
            plot.caption = element_text(vjust = 1), 
            axis.title = element_text(size = 12, face = "bold", vjust = 0.75), 
            axis.text = element_text(size = 12), 
            axis.text.x = element_text(size = 12, 
            vjust = 0.75, angle = 20), plot.title = element_text(face = "bold", 
            hjust = 0.5), legend.title = element_text(face = "bold", size = 12)) +
      labs(title = "Comparison of School Ratings from Student Reviews", fill = "Legend")
  })

  #show ex-comments datatable
  
  output$datatable <- DT::renderDataTable({
    datatable(rmp_excomment, rownames=FALSE)
  })
  
  #show Comments datatable
  
  rmp_comments <- reactive({
    rmp_df %>% 
      filter(school == input$cloud_selectschool) %>% 
      select(date, comment, thumbs_up, thumbs_down) 
  })
  
  
  output$commentstable <- DT::renderDataTable({
    datatable(rmp_comments(), rownames=FALSE) 
  })
  
  #wordcloud
  
  cloud_df <- reactive({
    rmp_df %>% 
      filter(school == input$cloud_selectschool)
  })
  
  
  #Text Mining
  
  text_ <- reactive({
    #data needs to be in corpus form for tm_map functions
    temp<- Corpus(VectorSource(cloud_df()$comment)) 
  
    ##change comments to lowercase
    temp <- tm_map(temp, content_transformer(tolower))
    
    ##include common stopwords
    temp <- tm_map(temp, removeWords, stopwords("english"))
    
    #ignores school name and the word "school"
    tm_map(temp, removeWords, c(strsplit(tolower(input$cloud_selectschool), " ")[[1]], "school", "none"))
    
  })
  
  #Turning corpus to matrix with word and freq count
  wordfreq_df <- reactive({
    dtm <- TermDocumentMatrix(text_())
    mtx <- as.matrix(dtm)
    wordfreq <- sort(rowSums(mtx),decreasing=TRUE)
    data.frame(word = names(wordfreq),freq=wordfreq)
  })
  
  output$cloudplot <- renderWordcloud2({
    wordcloud2(wordfreq_df())
  })
  
  
})