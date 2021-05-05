import json
from pathlib import Path
from typing import Tuple, List
from datetime import datetime


def process_workout(path: Path):
    with open(path) as workout_data_file:
        json_entry = json.load(workout_data_file)
        assert "data" in json_entry
        data = json_entry["data"]
        return data


def get_heart_rate_chart_values(workout) -> Tuple[List[datetime], List[float]]:
    data = workout["heartRateSamples"]

    x_values: List[datetime] = [datetime.strptime(x["startTime"], '%Y-%m-%d %H:%M:%S %z') for x in data]
    y_values: List[float] = [x["quantity"]["doubleValue"] for x in data]

    return x_values, y_values


def get_location_altitude_chart_values(workout) -> Tuple[List[datetime], List[float]]:
    data = workout["locations"]

    x_values: List[datetime] = [datetime.strptime(x["timestamp"], '%Y-%m-%d %H:%M:%S %z') for x in data]
    y_values: List[float] = [x["altitude"] for x in data]

    return x_values, y_values


def get_speed_chart_values(workout) -> Tuple[List[datetime], List[float]]:
    data = workout["locations"]

    x_values: List[datetime] = [datetime.strptime(x["timestamp"], '%Y-%m-%d %H:%M:%S %z') for x in data]
    y_values: List[float] = [x["speed"]["doubleValue"] for x in data]

    return x_values, y_values


if __name__ == '__main__':
    extracted_workout = process_workout(Path("data/20210504-WorkoutApple/data.json"))

    heart_x_values, heart_y_values = get_heart_rate_chart_values(extracted_workout)
    altitude_x_values, altitude_y_values = get_location_altitude_chart_values(extracted_workout)
    speed_x_values, speed_y_values = get_speed_chart_values(extracted_workout)
