# =======================================
# Explore How Temperature, Elevation, and Cadence Affect Running Pace
# =======================================

# -----------------------
# Install and Load Packages
# -----------------------
packages <- c("tidyverse", "readxl", "lubridate", "janitor", "hms", "here")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) install.packages(packages[!installed])
lapply(packages, library, character.only = TRUE)

# -----------------------
# Create Output Folders (if they don't exist)
# -----------------------
dir.create(here("Plots"), showWarnings = FALSE)
dir.create(here("Output"), showWarnings = FALSE)

# -----------------------
# Load and Clean Data
# -----------------------
df <- read_excel(here("Data", "RunTimes_WithWeather.xlsx")) %>%
  clean_names() %>%
  filter(distance_mi < 20)  # Remove marathons

# -----------------------
# Calculate Correlations
# -----------------------
temp_cor_value <- round(cor(df$avg_pace_sec, df$temp_f, use = "complete.obs"),2)
elevation_cor_value <- round(cor(df$avg_pace_sec, df$elevation_gain_ft, use = "complete.obs"),2)
cadence_cor_value <- round(cor(df$avg_pace_sec, df$cadence, use = "complete.obs"),2)

# -----------------------
# Prepare Data
# -----------------------
df <- df %>%
  mutate(
    start_time = as_hms(start_time),
    time = as_hms(time),
    condition = as.factor(condition),
    city = as.factor(city)
      )

# -----------------------
# Run Linear Regression Model
# -----------------------
model <- lm(avg_pace_sec ~ cadence + elevation_gain_ft + temp_f + condition + city, data = df)

# Show summary in console
print(summary(model))

# Save model summary to file
capture.output(summary(model), file = here("Output", "lm_summary.txt"))

# -----------------------
# Plot: Temperature vs. Pace
# -----------------------
temp_plot <- ggplot(df, aes(x = temp_f, y = avg_pace_sec)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    x = "Temperature (°F)",
    y = "Average Pace (sec/mile)",
    title = "Effect of Temperature on Running Pace"
  ) +
  annotate("text",
           x = min(df$temp_f, na.rm = TRUE) + 2,
           y = max(df$avg_pace_sec, na.rm = TRUE) - 10,
           label = paste("Correlation:", temp_cor_value),
           size = 5, fontface = "bold", hjust = 0
  ) +
  theme_minimal()

ggsave(here("Plots", "temperature_vs_pace.png"), temp_plot, width = 8, height = 6)

# -----------------------
# Plot: Elevation vs. Pace
# -----------------------
elev_plot <- ggplot(df, aes(x = elevation_gain_ft, y = avg_pace_sec)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    x = "Elevation Gain (ft)",
    y = "Average Pace (sec/mile)",
    title = "Effect of Elevation Gain on Running Pace"
  ) +
  annotate("text",
           x = min(df$elevation_gain_ft, na.rm = TRUE) + 2,
           y = max(df$avg_pace_sec, na.rm = TRUE) - 10,
           label = paste("Correlation:", elevation_cor_value),
           size = 5, fontface = "bold", hjust = 0
  ) +
  theme_minimal()

ggsave(here("Plots", "elevation_vs_pace.png"), elev_plot, width = 8, height = 6)


# -----------------------
# Plot: Cadence vs. Pace
# -----------------------
cadence_plot <- ggplot(df, aes(x = cadence, y = avg_pace_sec)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    x = "Cadence (steps/min)",
    y = "Average Pace (sec/mile)",
    title = "Effect of Cadence on Running Pace"
  ) +
  annotate("text",
           x = max(df$cadence, na.rm = TRUE) - 10,
           y = max(df$avg_pace_sec, na.rm = TRUE) - 10,
           label = paste("Correlation:", cadence_cor_value),
           size = 5, fontface = "bold", hjust = 0
  ) +
  theme_minimal()

ggsave(here("Plots", "cadence_vs_pace.png"), cadence_plot, width = 8, height = 6)

# -----------------------
# 10. Optional: Save Session Info
# -----------------------
writeLines(capture.output(sessionInfo()), here("Output", "session_info.txt"))
