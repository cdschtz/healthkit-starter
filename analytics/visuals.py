from typing import Tuple, List
from datetime import datetime
from pathlib import Path
import matplotlib.pyplot as plt
from utils.utils import process_heart_rate_samples


def visualize_heart_rate_samples(target_path: Path, graph_values: Tuple[List[datetime], List[int]]) -> None:
    x_values, y_values = graph_values

    plt.plot(x_values, y_values)
    plt.savefig(target_path)


if __name__ == '__main__':
    values = process_heart_rate_samples(Path("data/20210302-NRC/heart_rate_samples.json"))
    visualize_heart_rate_samples(Path("assets/nrc_heart_rate.png"), values)
