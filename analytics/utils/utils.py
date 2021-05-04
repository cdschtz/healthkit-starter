import json
from pathlib import Path
from typing import NamedTuple, Tuple, List
from datetime import datetime


class HeartRateSample(NamedTuple):
    startTime: datetime
    endTime: datetime
    count: int
    quantity: str  # bpm


def process_heart_rate_samples(path: Path) -> Tuple[List[datetime], List[int]]:
    with open(path) as heart_rate_samples_file:
        data: List[HeartRateSample] = json.load(heart_rate_samples_file)['data']

    x_vals: List[datetime] = [datetime.strptime(x['startTime'], '%Y-%m-%d %H:%M:%S %z') for x in data]
    y_vals: List[int] = [int(x['quantity'].split(" ")[0]) for x in data]

    return x_vals, y_vals


if __name__ == '__main__':
    hr_samples = process_heart_rate_samples(Path("../data/sample/heart_rate_samples.json"))
