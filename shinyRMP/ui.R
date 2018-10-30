shinyUI(dashboardPage(skin = "green",
    dashboardHeader(title = 'College Analyzer'),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Map", tabName = "map", icon = icon("map")),
            menuItem("School Comparison", tabName = "compare", icon = icon("graduation-cap")),
            menuItem("Word Cloud", tabName = "cloud", icon = icon("cloud")),
            menuItem("User Ratings Table", tabName = "data", icon = icon("database"))
        )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = "map",
                fluidRow(box(selectInput("criteria", label = h5(strong('Please select a rating criteria:')),
                                            choices = choice, selectize = F, size = 10), 
                                          width = 3, height = 490),
                         box(htmlOutput("attrib_map"), title = h4(strong("Rankings of Schools Based on Selected Criteria"), align = "center"),
                             width = 8, height = 490))
                       
        ),
        
        tabItem(tabName = "cloud",
                tabsetPanel(type = "tabs", 
                  tabPanel("Word Cloud", 
                           fluidRow(box(selectizeInput("cloud_selectschool", label = "Please select a school:",
                                                    choices = school_choices,
                                                    options = list(maxOptions=5000)),
                                                    width = 3, height = 490),
                                    box(wordcloud2Output('cloudplot'), width = 9, height = 490))),
                  
                  tabPanel("Comments", 
                           fluidRow(box(DT::dataTableOutput("commentstable"), width = 12)))
                         
                )
        ),
        
        tabItem(tabName = "compare",
                fluidRow(box(selectizeInput("compare_selectstate1", label = "Select state for first school",
                                            selected = "Massachusetts", choices = unique(sort(rmp_df$state_name))), br(),
                             selectizeInput("compare_selectstate2", label = "Select state for second school",
                                            selected = "Connecticut", choices = unique(sort(rmp_df$state_name))), br(),
                             sliderInput("numreview_slider", label = "Number of reviews",
                                         min = 0, max=1300, value = c(0,1300), step = 100), br(),
                             selectizeInput("school1", label = "Select first school",
                                            choices = school_choices, options = list(maxOptions=5000)), br(),
                             selectizeInput("school2", label = "Select second school",
                                            choices = school_choices, options = list(maxOptions=5000)), br(),
                             actionButton('go', label = 'Compare Schools', icon("graduation-cap")),  width = 3),
                         
                         box(plotOutput("boxplot"), width = 9))
        ),
        
        tabItem(tabName = "data",
                fluidRow(box(DT::dataTableOutput("datatable"), width = 12))
        )
        
      )
    )
))
