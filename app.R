# =============================================================================
# Part 1: GLOBAL SETUP
# =============================================================================

# -- Load all necessary libraries --
library(shiny)
library(tidyverse)
library(sf)
library(leaflet)
library(dbscan)
library(DT) # For interactive tables

# -- Load and Prepare Data --
crime_df <- read_csv("crime23.csv")

crime_clean <- crime_df %>%
  mutate(date = as.Date(paste0(date, "-01"))) %>%
  drop_na(lat, long) %>%
  mutate(
    month = fct_reorder(format(date, "%B"), as.numeric(format(date, "%m"))),
    season = case_when(
      month %in% c("December", "January", "February") ~ "Winter",
      month %in% c("March", "April", "May") ~ "Spring",
      month %in% c("June", "July", "August") ~ "Summer",
      TRUE ~ "Autumn"
    )
  )

# Create an unprojected sf object for general use
crime_sf_unprojected <- st_as_sf(crime_clean, coords = c("long", "lat"), crs = 4326)

# -- Perform Clustering --
# 1. Convert to projected CRS for accurate distance calculation
crime_sf_proj <- st_transform(crime_sf_unprojected, crs = 27700)
coords <- st_coordinates(crime_sf_proj)

# 2. Run DBSCAN with your best settings
db <- dbscan(coords, eps = 120, minPts = 25)

# 3. Add cluster results to the projected dataframe
crime_sf_proj$cluster <- as.factor(db$cluster)

# 4. Transform the data with clusters BACK to lat/long for Leaflet mapping
crime_sf <- st_transform(crime_sf_proj, crs = 4326)

# -- Create Static Variables for UI --
date_range <- range(crime_sf$date, na.rm = TRUE)
categories <- sort(unique(crime_sf$category))
cluster_levels <- levels(crime_sf$cluster)

# =============================================================================
# Part 2: UI (USER INTERFACE)
# =============================================================================

ui <- fluidPage(
  titlePanel("Colchester Crime Analysis Dashboard (2023)"),
  sidebarLayout(
    sidebarPanel(
      # Trend controls
      selectInput("crimecat", "View Monthly Trend for:",
                  choices = names(sort(table(crime_sf$category), decreasing = TRUE)),
                  selected = "violent-crime", multiple = TRUE
      ),
      hr(),
      h4("Map Data Filters"),
      # Map controls
      dateRangeInput(
        "map_dates", "Filter Map by Date:",
        start = date_range[1], end = date_range[2], min = date_range[1], max = date_range[2]
      ),
      selectInput("map_cats", "Filter Map by Category:",
                  choices = categories,
                  selected = categories, multiple = TRUE
      ),
      helpText("Use filters to control the data on the 'Hotspot Map' and 'Cluster Profiles' tabs.")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Overview",
                 h3("Main Crimes in Colchester"),
                 plotOutput("bar_crimes"),
                 h4("Key Statistics"),
                 verbatimTextOutput("summary_stats")
        ),
        tabPanel("Trends",
                 h3("Monthly Pattern"),
                 plotOutput("trends")
        ),
        tabPanel("Hotspot Map",
                 h3("Geospatial Crime Clusters (Filtered)"),
                 leafletOutput("crime_map", height = 600)
        ),
        tabPanel("Cluster Profiles",
                 h3("Top Crime Types in Main Hotspots"),
                 plotOutput("cluster_comp")
        )
      )
    )
  )
)

# =============================================================================
# Part 3: SERVER
# =============================================================================

server <- function(input, output, session) {
  
  # -- Overview Tab --
  output$summary_stats <- renderPrint({
    violent_count <- crime_sf %>% filter(category == "violent-crime") %>% nrow()
    total_incidents <- nrow(crime_sf)
    percent_violent <- round(violent_count / total_incidents * 100, 1)
    cat("Total Incidents:", total_incidents, "\n",
        "Violent Crimes:", violent_count, "(", percent_violent, "%)\n",
        "Number of Hotspots Detected:",
        length(setdiff(unique(crime_sf$cluster), "0")),
        "\n")
  })
  
  output$bar_crimes <- renderPlot({
    ggplot(crime_sf, aes(y = fct_rev(fct_infreq(category)))) +
      geom_bar(fill = "steelblue") +
      geom_text(stat = 'count', aes(label = after_stat(count)), hjust = -0.2) +
      scale_x_continuous(expand = expansion(mult = c(0, 0.1))) +
      labs(title = "Main Crime Types", x = "Number of Incidents", y = "Crime Category") +
      theme_minimal() + theme(panel.grid.major.y = element_blank())
  })
  
  # -- Trends Tab --
  output$trends <- renderPlot({
    req(input$crimecat)
    crime_sf %>%
      filter(category %in% input$crimecat) %>%
      count(month, category) %>%
      ggplot(aes(x = month, y = n, group = category, color = category)) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 2) +
      labs(title = "Incident Trends by Month", x = "Month", y = "Number of Incidents") +
      theme_light() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # -- Reactive data for Map and Cluster Profile tabs --
  filtered_map_data <- reactive({
    req(input$map_dates, input$map_cats)
    crime_sf %>%
      filter(
        date >= input$map_dates[1],
        date <= input$map_dates[2],
        category %in% input$map_cats
      )
  })
  
  # -- Hotspot Map Tab --
  # Create the base map canvas once
  output$crime_map <- renderLeaflet({
    pal <- colorFactor(
      c("grey", "#FF5733", "#33FF57", "#3357FF", "#FF33A1", "#F1C40F", "#8E44AD"),
      domain = cluster_levels
    )
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 0.8919, lat = 51.8959, zoom = 13) %>%
      addLegend("bottomright", pal = pal, values = cluster_levels, title = "Hotspot ID")
  })
  
  # Use an observer to update only the map markers for performance
  observe({
    pal <- colorFactor(
      c("grey", "#FF5733", "#33FF57", "#3357FF", "#FF33A1", "#F1C40F", "#8E44AD"),
      domain = cluster_levels
    )
    leafletProxy("crime_map", data = filtered_map_data()) %>%
      clearMarkers() %>%
      addCircleMarkers(
        radius = 4,
        color = ~pal(cluster),
        stroke = FALSE,
        fillOpacity = 0.7,
        popup = ~paste0("<b>Category:</b> ", category, "<br><b>Cluster:</b> ", cluster)
      )
  })
  
  # -- Cluster Profiles Tab --
  # This corrected version gracefully handles cases with no hotspots
  output$cluster_comp <- renderPlot({
    map_data <- filtered_map_data()
    
    # Check if there are any actual hotspots in the filtered data
    clustered_data <- map_data %>%
      filter(cluster != "0")
    
    # If no hotspots exist for the filter, show a helpful message
    if (nrow(clustered_data) == 0) {
      return(
        ggplot() +
          annotate("text", x = 1, y = 1, label = "No hotspots found for the current filter settings.", size = 6) +
          theme_void()
      )
    }
    
    # Identify the top 4 largest clusters from the filtered data
    top_4_clusters <- clustered_data %>%
      sf::st_drop_geometry() %>%
      count(cluster, sort = TRUE) %>%
      slice_head(n = 4) %>%
      pull(cluster)
    
    # Analyze the crime composition for only these top clusters
    cluster_analysis <- clustered_data %>%
      filter(cluster %in% top_4_clusters) %>%
      sf::st_drop_geometry() %>%
      count(cluster, category, sort = TRUE) %>%
      group_by(cluster) %>%
      mutate(percentage = round(n / sum(n) * 100, 1)) %>%
      slice_max(order_by = percentage, n = 3)
    
    # Create the final plot
    ggplot(cluster_analysis, aes(x = percentage, y = fct_reorder(category, percentage), fill = category)) +
      geom_col(show.legend = FALSE) +
      facet_wrap(~ paste("Hotspot", cluster), ncol = 2) +
      labs(
        title = "Crime Profile of Major Hotspots (for current filter)",
        subtitle = "Comparing the top 3 crimes in the largest identified hotspots",
        x = "Percentage of Incidents within Each Hotspot",
        y = "Crime Category"
      ) +
      theme_light(base_size = 12)
  })
}

# =============================================================================
# Part 4: RUN APP
# =============================================================================
shinyApp(ui = ui, server = server)