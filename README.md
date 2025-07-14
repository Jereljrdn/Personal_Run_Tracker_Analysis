# Personal Run Tracker Analysis

This project explores my personal running data collected from the **Nike Run Club** app, enhanced with **historical weather data** that I pulled from the [WeatherAPI](https://www.weatherapi.com/). It merges data from my runs with weather conditions to evaluate how factors such as temperature, time of day, and elevation gain may influence my run performance.

## Tools Used
- **Microsoft Excel** – Used as the input and output format for the dataset. Run data from the Nike Run Club app was manually logged here and the final merged dataset (with weather data) was exported back to Excel to prepare for analysis and visualization.
- **Python** – Used to read and clean data from the Excel spreadsheet (`pandas`), retrieve historical weather conditions for each run using the WeatherAPI (`requests`), merge the weather data with the original dataset, and export the result as a new Excel file.
- **WeatherAPI** – Used to retrieve historical weather data based on each run's date, time, and location.
- **R** – Used for data visualization and analysis. Explored potential relationships between weather conditions, time of day, elevation, and overall run performance.
