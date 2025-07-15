import pandas as pd
import requests
from datetime import datetime
import time

def main():

    #Configuration and user input
    API_KEY = input("Enter WeatherAPI Key: ")
    BASE_URL = "http://api.weatherapi.com/v1/history.json"

    input_path = input("Enter path for run data (Excel file): ")
    df = pd.read_excel(input_path)

    #Clean time column to prevent Excel formatting issues

    df['Time'] = df['Time'].astype(str)

    weather_results = []

    for i, row in df.iterrows():
        city = row['City']
        date = row['Date'].date()
        start_datetime = datetime.combine(row['Date'], row['Start Time'])
        time_str = start_datetime.strftime("%H:00")

        params = {
            "key": API_KEY,
            "q": city,
            "dt": str(date)
        }

        try:
            response = requests.get(BASE_URL, params=params)
            response.raise_for_status()
            time.sleep(1.5)

            data = response.json()
            hours = data['forecast']['forecastday'][0]['hour']
            match = next(h for h in hours if h['time'].endswith(time_str))
            temp = match['temp_f']
            condition = match['condition']['text']

        except Exception as e:
            print(f"Failed to fetch weather for {city} on {date} at {time_str}: {e}")
            temp = None
            condition = "Not found"

        weather_results.append({
            "Date": date,
            "Weather Time": time_str,
            "City": city,
            "Temp (F)": temp,
            "Condition": condition
        })

    weather_df = pd.DataFrame(weather_results)

    #Format and clean columns
    df['Avg. Pace (mm:ss)'] = df['Avg. Pace (mm:ss)'].apply(
        lambda x: f"{int(x.total_seconds() // 60):02}:{int(x.total_seconds() % 60):02}"
        if pd.notnull(x) else ""
    )

    df['Weather Time'] = df['Start Time'].apply(lambda t: t.strftime("%H:00"))
    df['Date'] = df['Date'].dt.date

    #Merge weather data with run data
    merged_df = pd.merge(df, weather_df, on=['Date', 'Weather Time', 'City'], how='left')

    #Save the final output
    output_path = input("Enter path to save the output Excel file: ")
    merged_df.to_excel(output_path, index=False)

    print("Weather data successfully saved to:", output_path)

if __name__ == "__main__":
    main()
