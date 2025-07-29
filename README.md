# Colchester Crime Analysis & Hotspot Detection (2023)

To conduct an in-depth analysis of crime patterns in Colchester during 2023. The primary goal is to identify high-risk areas, times, and prevalent crime types to provide actionable intelligence for law enforcement resource allocation and inform targeted community safety programs.


**Live Demo:** [Link to your knitted HTML report or a Shiny App]

## 📝 Project Overview

This project provides an in-depth analysis of 6,878 police-recorded crime incidents in Colchester, UK, for the year 2023. Using geospatial and temporal analysis, I identified key patterns and high-density crime "hotspots." The goal is to provide actionable intelligence that could help local law enforcement optimize resource allocation and improve public safety.

## 🔑 Key Findings

1.  **High-Density Hotspots Identified:** Using the DBSCAN clustering algorithm, **5 distinct crime hotspots** were identified, primarily located in the town center and areas with high foot traffic.
2.  **Peak Seasonality:** Crime incidents show a clear seasonal trend, peaking in the summer months (June-August), with a **25% increase** over the winter average.
3.  **Top Concern:** "Violent and sexual offences" remain the most prevalent crime category, accounting for over 40% of all incidents, with a notable concentration in nightlife areas.

![DBSCAN Cluster Map](output/plots/crime_cluster_map.png)

## 🛠️ Technical Stack

-   **Language:** R
-   **Core Libraries:** `dplyr`, `ggplot2`, `sf` (Simple Features), `leaflet`
-   **Geospatial Analysis:** `dbscan` for density-based clustering to identify hotspots.

## 📈 Methodology

1.  **Data Ingestion & Cleaning:** Loaded and preprocessed UK Police crime data, ensuring correct data types and formats.
2.  **Temporal Feature Engineering:** Extracted month and season from date fields to analyze time-based trends.
3.  **Geospatial Clustering:** Transformed data to a projected CRS (OSGB 1936) and applied DBSCAN to identify statistically significant clusters of crime incidents.
4.  **Visualization:** Created faceted time-series plots and interactive hotspot maps to communicate findings effectively.

## 🚀 How to Run

1.  Clone the repository: `git clone [your-repo-link]`
2.  Open the project in RStudio.
3.  Run the scripts in the `/R` folder in numerical order, or open and knit `report.Rmd`.
