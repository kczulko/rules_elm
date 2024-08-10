import os
import struct
import sys
import json

(
    module_name,
    tests_found_filepath,
    output_file,
) = sys.argv[1:4]

tests_found = []

# Extract all tests stored in the source file.
with open(tests_found_filepath) as f:
    tests_found = json.load(f)

all_tests = tests_found

# TODO: there's a bug: when multiple functions are found, then List.map fails to unify the type
# Emit a main source file that calls the tests.
# TODO(edsch): What about the seed?
with open(output_file, "w") as f:
    f.write(
        """module RulesElmMainTestsExecutor exposing (main)
import Console.Text exposing (UseColor(..))
import Test exposing (Test)
import Test.Reporter.Reporter exposing (Report(..))
import Test.Runner.Node

import %(module_name)s

maybeTests : List (Maybe Test)
maybeTests = [ %(tests)s ]

main : Test.Runner.Node.TestProgram
main = Test.Runner.Node.run {
            runs = 1,
            seed = 236315485321474,
            report = (ConsoleReport UseColor),
            globs = [],
            paths = ["%(source_file)s"],
            processes = 1
        } [ ("%(module_name)s", maybeTests) ]"""
        % {
            "source_file": output_file,
            "module_name": module_name,
            "tests": ", ".join("Test.Runner.Node.check %s.%s" % (module_name, test) for test in all_tests),
        }
    )

