# Solver Schedule

Attempts to learn a schedule for the provided models, using the PAR10 metric.

## Dependencies

- savilerow
- python3

## Usage

`./evaluate_seeds.sh <eprime model> <#seeds to use> <timeout (seconds)>`

Where:

- `<eprime model>` is the constraint model to use,
- `<#seeds to use>` is the number of seeds from the seed files to use
- `<timeout (seconds)>` is the total timeout to optimise for

For example, to find the optimal schedule for the first 1000 seeds in the data directory
for a maximum timeout of 20 minutes, use:

```bash
./evaluate_seeds.sh optimese_schedule.eprime 1000 1200
```

## Parsing output

The first output line contains the names of the data files in the order they are passed into the model.

The __order__ variable is the order each of these files should be processed.

The __timePortion__ variable is the proportion of the time limit  allocated 
to that solver/model.

## Data files

The [data](./data) directory must contain csv files with data for each solver.

Requirements for these files can be found [here](./data/README.md).

## Model explanation  

A detailed explanation of the scheduling constraint model (used for generating the optimal constraint-based schedule of solvers) is available in `./docs/constraint_explination.md`
