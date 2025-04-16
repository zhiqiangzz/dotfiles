#!/usr/bin/env python
import argparse
import re


def split_and_filter_file(input_file, output_file):
    with open(input_file, "r", encoding="utf-8") as f:
        content = f.readlines()

    pattern = re.compile(r".*IR Dump After .*\((.*?)\).*")
    filtered_blocks = []
    current_block = []
    exclude_block = False

    for line in content:
        match = pattern.match(line)
        if match:  # Match the separator line
            if current_block and not exclude_block:
                filtered_blocks.append("".join(current_block))
            current_block = [line]
            exclude_block = False  # Reset flag for new block
            if re.search(
                r"canonicalize|cse|simplify|optimize-int-arithmetic|dce|fold|inline",
                match.group(1),
                re.IGNORECASE,
            ):
                exclude_block = True
        else:
            current_block.append(line)

    if current_block and not exclude_block:
        filtered_blocks.append("".join(current_block))

    with open(output_file, "w", encoding="utf-8") as f:
        f.writelines(filtered_blocks)


def main():
    parser = argparse.ArgumentParser(
        description="Split a large file into blocks and filter out specific ones."
    )
    parser.add_argument("input_file", help="Path to the input file")
    parser.add_argument(
        "-o", "--output_file", required=True, help="Path to the output file"
    )
    args = parser.parse_args()

    split_and_filter_file(args.input_file, args.output_file)


if __name__ == "__main__":
    main()
