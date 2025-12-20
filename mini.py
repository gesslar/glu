#!/usr/bin/env python3
import re
import argparse
from pathlib import Path

class LuaMinifier:
    def __init__(self, input_file, output_file):
        self.input_file = Path(input_file)
        self.output_file = Path(output_file)

    def minify(self, content):
        """Basic Lua minification."""
        # Remove comments (but keep shebangs)
        lines = content.split('\n')
        processed_lines = []
        in_multiline_comment = False

        for line in lines:
            # Handle multiline comments
            if in_multiline_comment:
                if ']]' in line:
                    line = line[line.find(']]') + 2:]
                    in_multiline_comment = False
                else:
                    continue

            if '--[[' in line:
                if ']]' in line:
                    # Single-line multi-line comment
                    line = line[:line.find('--[[')] + line[line.find(']]') + 2:]
                else:
                    line = line[:line.find('--[[')]
                    in_multiline_comment = True

            # Handle single-line comments
            if not in_multiline_comment and '--' in line:
                line = line[:line.find('--')]

            if line.strip():
                processed_lines.append(line)

        content = '\n'.join(processed_lines)

        # Remove unnecessary whitespace
        content = re.sub(r'\s+', ' ', content)
        content = re.sub(r';\s+', ';', content)
        content = re.sub(r'\s*([=+\-*/<>()])\s*', r'\1', content)

        # Preserve some readability with newlines between statements
        content = re.sub(r'([\n;])\s*', r'\1\n', content)

        return content.strip()

    def build(self):
        """Minify the input file."""
        print(f"Minifying {self.input_file}")

        # Read input file
        with open(self.input_file, 'r', encoding='utf-8') as f:
            content = f.read()

        original_size = len(content)

        # Minify
        minified_content = self.minify(content)

        # Create output directory if it doesn't exist
        self.output_file.parent.mkdir(parents=True, exist_ok=True)

        # Write the output
        with open(self.output_file, 'w', encoding='utf-8') as f:
            f.write(minified_content)

        # Print build statistics
        print(f"\nMinification completed: {self.output_file}")
        print(f"Original size: {original_size:,} bytes")
        print(f"Final size: {len(minified_content):,} bytes")
        print(f"Reduction: {(1 - len(minified_content)/original_size)*100:.1f}%")

def main():
    parser = argparse.ArgumentParser(description='Minify Lua file')
    parser.add_argument('input_file', help='Input Lua file to minify')
    parser.add_argument('output_file', help='Output minified file path')

    args = parser.parse_args()

    minifier = LuaMinifier(
        input_file=args.input_file,
        output_file=args.output_file
    )

    minifier.build()

if __name__ == '__main__':
    main()
