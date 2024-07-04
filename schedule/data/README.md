# Data

This directory contains the data used to determine the schedules.

Each solver should have a separate csv file containing its data.

Each file must contain three columns.

| seed | result | time (seconds) |
|------|--------|----------------|

`seed` should be unique integers in ascending order.

`result` should be an integer between 0 and 2, 0 for unsolvable, 1 for solved, 2 for unknown.

`time (seconds)` should be the time in seconds for the solver/model

All data files should have the same seeds in the same order. If a seed is missing
from one data file, the same seed will be excluded from all other data files.
