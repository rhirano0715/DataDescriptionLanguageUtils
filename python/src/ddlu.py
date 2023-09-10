# -*- coding: utf-8 -*-

import argparse
import pathlib
import json
import xmltodict

def main() -> None:
    (input_file_path, output_file_path) = parse_arg()

    validate(input_file_path, output_file_path)

    run(input_file_path, output_file_path)

def run(input_file_path, output_file_path):
    data = read(input_file_path)
    write(output_file_path, data)

def validate(input_file_path: pathlib.Path, output_file_path: pathlib.Path):
    if not input_file_path.is_file():
        raise ValueError("Input file is not exists.")

    if not output_file_path.parent.is_dir():
        raise ValueError("Output directory is not exists.")

def read(input_file_path: pathlib.Path):
    if input_file_path.suffix == '.json':
        with input_file_path.open(mode="r") as inf:
            return json.load(inf)

    if input_file_path.suffix == '.xml':
        return xmltodict.parse(input_file_path.read_text())

    raise ValueError(f"Reading {input_file_path.suffix} is not supported.")

def write(output_file_path:pathlib.Path, data):
    if output_file_path.suffix == '.json':
        with output_file_path.open(mode="w") as otf:
            otf.write(json.dumps(data, indent=4))
            return

    if output_file_path.suffix == '.xml':
        if type(data) is list:
            data = {"items": {"item": data}}
        with output_file_path.open(mode="w") as otf:
            otf.write(xmltodict.unparse(data, pretty=True))
            return

    raise ValueError(f"Writing {output_file_path.suffix} is not supported.")

def parse_arg():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_file_path", help="input file path")
    parser.add_argument("output_file_path", help="output file path")
    args = parser.parse_args()
    return (pathlib.Path(args.input_file_path), pathlib.Path(args.output_file_path))

if __name__ == "__main__":
    main()
