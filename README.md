# Colchester Crime Analysis 2023: A Hotspot-Driven Approach to Optimizing Police Resources
To conduct an in-depth analysis of crime patterns in Colchester during 2023. The primary goal is to identify high-risk areas, times, and prevalent crime types to provide actionable intelligence for law enforcement resource allocation and inform targeted community safety programs.


### 🎯 Project Objective
This project moves beyond simple crime reporting to deliver actionable intelligence for law enforcement. By applying geospatial clustering and temporal analysis to over 6,800 crime incidents in Colchester for 2023, the goal was to identify not just *that* crime was happening, but precisely *where* and *what kind* of crime was concentrated, enabling a more strategic allocation of police resources.

---

### 🚀 Live Demos & Report
* **[View the Full Static Report (HTML)](file:///Users/shahbaz/Documents/study%20material/Data%20visualisation/Crime_project.html)**
* **[Interact with the Live Dashboard (Shiny App)](https://your-shinyapps-io-link-here)** *(https://shahbaz-sharif.shinyapps.io/Crime-Hotspot-Analysis/)*

---

### 🔑 Key Insights & Recommendations
My analysis successfully broke down the city's crime landscape from one large, unmanageable area into distinct, targetable hotspots with unique crime profiles.

#### 1.  **Identified Two Distinct Major Hotspots, Not Just One "City Center"**
The DBSCAN clustering revealed that Colchester's crime is concentrated in two primary, but different, major hotspots.

* **Hotspot #3 (The Primary Epicenter):** This massive cluster (3,535 incidents) is the commercial and nightlife core. It's dominated by **Violent and sexual offences** and **Anti-social behaviour**.
* **Hotspot #1 (The Secondary Hub):** This large but distinct zone (947 incidents) shows a different pattern, with **Shoplifting** and **Other theft** being significantly more prevalent.

**Recommendation:** Law enforcement should not treat the city center as a single zone. **Hotspot #3** requires patrols focused on public order and safety, especially during evenings. **Hotspot #1** requires a strategy focused on loss prevention and property crime, likely during retail hours.

![Crime Profile of Major Hotspots](https://i.imgur.com/your-image-link-here.png)
*(To get this link, take a screenshot of your final plot, upload it to a site like [Imgur](https://imgur.com/upload), and paste the image link here)*

#### 2. **Crime Peaked in Summer, Driven by Public-Facing Offences**
Incidents peaked sharply during the summer months (June-August). This trend was primarily driven by public-facing crimes like Anti-social behaviour, which are more common in warmer weather.

**Recommendation:** Increase patrol visibility and community engagement programs during the summer, when public interaction and associated crime are at their highest.

---

### 🛠️ Technical Showcase

* **Language:** **R**
* **Core Libraries:** `tidyverse` (for data wrangling), `sf` (for spatial analysis), `leaflet` (for interactive mapping), `ggplot2` (for visualization).
* **Machine Learning:** Identified and validated high-density hotspots using the **DBSCAN clustering algorithm**, iteratively tuning `eps` and `minPts` parameters to find the most strategically meaningful clusters.
* **Dashboarding:** Developed a fully interactive **R Shiny dashboard** to allow non-technical users to explore the data and insights dynamically.

---

### 📈 Methodology
1.  **Data Cleaning & Feature Engineering:** Processed raw CSV data, handled missing values, and engineered new temporal features like `month` and `season` to enable deeper trend analysis.
2.  **Geospatial Transformation:** Converted latitude/longitude data to a projected Coordinate Reference System (CRS: 27700) to perform accurate, distance-based clustering.
3.  **Comparative Analysis:** The core of the project was not just identifying hotspots, but analyzing and comparing their unique crime compositions to provide targeted, specific recommendations.

---

### 🚀 How to Run Locally

1.  **Clone Repository:**
    ```bash
    git clone [your-repo-link]
    ```
2.  **Open Project:** Open the `.Rproj` file in RStudio.
3.  **Install Packages:** The script will prompt for any missing packages.
4.  **Run Files:**
    * Knit `Crime_project.Rmd` to generate the static HTML report.
    * Run `app.R` to launch the interactive Shiny dashboard.
