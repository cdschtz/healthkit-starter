from typing import Tuple, List
from datetime import datetime
from pathlib import Path
import matplotlib.pyplot as plt
from utils.utils import process_workout, get_speed_chart_values, get_heart_rate_chart_values, \
    get_location_altitude_chart_values


def visualize_graph_values(target_path: Path, graph_values: Tuple[List[datetime], List[float]]) -> None:
    x_values, y_values = graph_values

    plt.plot(x_values, y_values)
    plt.savefig(target_path)
    plt.close()


if __name__ == '__main__':
    extracted_workout = process_workout(Path("data/20210504-WorkoutApple/data.json"))

    heart_rate_values = get_heart_rate_chart_values(extracted_workout)
    altitude_values = get_location_altitude_chart_values(extracted_workout)
    speed_values = get_speed_chart_values(extracted_workout)

    visualize_graph_values(Path("data/20210504-WorkoutApple/heart_rate.png"), heart_rate_values)
    visualize_graph_values(Path("data/20210504-WorkoutApple/altitude.png"), altitude_values)
    visualize_graph_values(Path("data/20210504-WorkoutApple/speed.png"), speed_values)
