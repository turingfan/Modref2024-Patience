#!/usr/bin/env python3

from os import listdir, remove
from os.path import exists, join
from sys import argv, exit
from re import search

info_headings = [
    "SolverMemOut",
    "SolverTotalTime",
    "SATClauses",
    "SavileRowClauseOut",
    "SavileRowTotalTime",
    "SolverSatisfiable",
    "SavileRowTimeOut",
    "SolverTimeOut",
    "SolverNodes",
    "SATVars"
]
info_extension = ".info"


def file_to_line(filename: str, csv_path: str) -> None:

    info_heading_set = set(info_headings)

    is_match = search(r'.*seed(\d+).info', filename)

    result_dict = dict()
    seed_title = "seed"

    if is_match:

        result_dict[seed_title] = is_match.group(1)

        with open(filename, "r") as info_file:
            for line in info_file:
                content = line.strip().split(":")
                if len(content) == 2 and content[0] in info_heading_set:
                    result_dict[content[0]] = content[1]

        with open(csv_path, "a") as f:

            f.write(result_dict[seed_title])

            for heading in info_headings:
                f.write(",")
                if heading in result_dict:
                    f.write(result_dict[heading])
            f.write("\n")


def collate_infos(dirname: str, csv_path: str) -> None:
    if exists(csv_path):
        remove(csv_path)

    with open(csv_path, "w") as f:
        f.write("seed")
        for heading in info_headings:
            f.write(f",{heading}")
        f.write("\n")

    for f in listdir(dirname):
        if f.endswith(info_extension):
            file_to_line(join(dirname, f), csv_path)


def usage():
    print(f"Usage: {argv[0]} <dirname> <csv_name>")


if __name__ == "__main__":

    if len(argv) < 3:
        usage()
        exit(1)

    collate_infos(argv[1], argv[2])
