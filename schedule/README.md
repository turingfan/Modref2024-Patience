# Solver Schedule

Attempts to learn a schedule for the provided models, using the PAR10 metric.

## Dependencies

- savilerow
- python3

## Model explanation  

A detailed explanation of the scheduling constraint model (used for generating the optimal constraint-based schedule of solvers) is available in `./docs/constraint_explination.md`

## Usage

### Generate schedule for specific training set and timeout

`./evaluate_seeds.sh <eprime model> <#seeds to use> <timeout (seconds)> <data directory>`

Where:

- `<eprime model>` is the constraint model to use,
- `<#seeds to use>` is the number of seeds from each seed file to use in the training set
- `<timeout (seconds)>` is the total timeout to optimise for
- `<data directory>` is the directory containing the data to optimise for

For example, to find the optimal schedule for the first 1000 seeds in the _data_ directory
for a maximum timeout of 20 minutes, use:

```bash
./evaluate_seeds.sh optimese_schedule.eprime 1000 1200 data
```

#### Parsing output

The first output line contains the prefixes of the data files in the order they are passed into the model.

The __order__ variable is the order each of these files should be processed.

The __timePortion__ variable is the proportion of the time limit  allocated 
to that solver/model.

### Calculate metrics for baseline schedules

`./generate_baselines.sh <result file>`

This will calculate the par10 and fraction certain scores for the test set in the paper,
saving the output to the result file provided in csv format.

For example:

```bash
./generate_baselines.sh baselines_from_paper.csv
```

### Generate and evaluate constraint derived schedules

`./run_params.sh <eprime model> <data directory> <results file>`

This will generate the optimal schedules on the first 1000 seeds of the algorithms in 
the data directory provided, and then evaluate the generated schedule (and basline schedules)
against the last 9000 seeds in the data directory provided for a range of timeouts, 
writing the results to the results file provided in csv format.

_This will take some time to execute_

For example:

```bash
./run_params.sh optimise_schedule.eprime dupe_data schedule_results.csv
```

## Data files

The [data](./data) directory must contain csv files with data for each solver.

Requirements for these files can be found [here](./data/README.md).

