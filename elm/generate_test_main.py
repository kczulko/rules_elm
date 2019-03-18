from __future__ import print_function

import os
import struct
import sys


# Parsers for raw structures stored on .elmi files.


def _read_uint8(f):
    return struct.unpack(">B", f.read(1))[0]


def _read_uint16(f):
    return struct.unpack(">H", f.read(2))[0]


def _read_uint64(f):
    return struct.unpack(">Q", f.read(8))[0]


def _read_string(f):
    offset = f.tell()
    length = _read_uint64(f)
    if length > 1000:
        raise Exception(
            "Cannot read string of length %d (%#018x) at offset %#x"
            % (length, length, offset)
        )
    data = f.read(length)
    try:
        return str(data, encoding="ASCII")
    except TypeError:
        return str(data)


def _create_list_reader(read_element):
    def reader(f, v):
        res = []
        for _ in range(_read_uint64(f)):
            res.append(read_element(f, v))
        return res

    return reader


def _create_map_reader(read_key, read_value):
    def reader(f, v):
        res = {}
        for _ in range(_read_uint64(f)):
            key = read_key(f, v)
            if key in res:
                raise Exception("Key %s already exists" % key)
            res[key] = read_value(f, v)
        return res

    return reader


def _create_maybe_reader(read_value):
    def reader(f, v):
        has_value = _read_uint8(f)
        if has_value == 0:
            return None
        if has_value == 1:
            return read_value(f, v)
        raise Exception("Unknown maybe field value %d" % has_type)

    return reader


def _create_set_reader(read_key):
    def reader(f, v):
        res = set()
        for _ in range(_read_uint64(f)):
            key = read_key(f, v)
            if key in res:
                raise Exception("Key %s already exists" % key)
            res.add(key)
        return res

    return reader


# Types from compiler/src/Elm/Name.hs.


def _read_name(f, v):
    return v.visit_name(_read_string(f))


# Types from compiler/src/Elm/Package.hs.


def _read_package_name(f, v):
    return v.visit_package_name(_read_string(f), _read_string(f))


# Types from compiler/src/AST/Module/Name.hs.


def _read_module_name(f, v):
    return v.visit_module_name(_read_package_name(f, v), _read_name(f, v))


# Types from compiler/src/AST/Canonical.hs.


def _read_annotation(f, v):
    return v.visit_annotation(_read_freevars(f, v), _read_type(f, v))


def _read_freevars(f, v):
    return _create_set_reader(_read_name)(f, v)


def _read_tvar(f, v):
    return v.visit_tvar(_read_name(f, v))


def _read_tlambda(f, v):
    return v.visit_tlambda(_read_type(f, v), _read_type(f, v))


def _read_ttuple(f, v):
    return v.visit_ttuple(
        _read_type(f, v), _read_type(f, v), _create_maybe_reader(_read_type)(f, v)
    )


def _read_fieldtype(f, v):
    return v.visit_fieldtype(_read_uint16(f), _read_type(f, v))


def _read_trecord(f, v):
    return v.visit_trecord(
        _create_map_reader(_read_name, _read_fieldtype)(f, v),
        _create_maybe_reader(_read_name)(f, v),
    )


def _read_tunit(f, v):
    return v.visit_tunit()


def _read_ttype(f, v):
    return v.visit_ttype(
        _read_module_name(f, v), _read_name(f, v), _create_list_reader(_read_type)(f, v)
    )


def _read_ttype_n(f, v, n):
    module_name = _read_module_name(f, v)
    name = _read_name(f, v)
    types = []
    for _ in range(n):
        types.append(_read_type(f, v))
    return v.visit_ttype(module_name, name, types)


def _read_talias(f, v):
    return v.visit_talias(
        _read_module_name(f, v),
        _read_name(f, v),
        _create_list_reader(lambda f, v: (_read_name(f, v), _read_type(f, v)))(f, v),
        _read_aliastype(f, v),
    )


def _read_aliastype(f, v):
    offset = f.tell()
    tag = _read_uint8(f)
    if tag == 0:
        return v.visit_aliastype(False, _read_type(f, v))
    elif tag == 1:
        return v.visit_aliastype(True, _read_type(f, v))
    else:
        raise Exception("Unknown alias type kind %d at offset %#x" % (tag, offset))


def _read_type(f, v):
    tag = _read_uint8(f)
    if tag == 0:
        return _read_tlambda(f, v)
    elif tag == 1:
        return _read_tvar(f, v)
    elif tag == 2:
        return _read_trecord(f, v)
    elif tag == 3:
        return _read_tunit(f, v)
    elif tag == 4:
        return _read_ttuple(f, v)
    elif tag == 5:
        return _read_talias(f, v)
    elif tag == 6:
        return _read_ttype(f, v)
    else:
        return _read_ttype_n(f, v, tag - 7)


# Types from compiler/src/Elm/Interface.hs.


def _read_interface(f, v):
    # Skip parsing unions, aliases and binops. We don't need them for
    # this specific purpose.
    return v.visit_interface(_create_map_reader(_read_name, _read_annotation)(f, v))


class TypeAliasExtractor:
    """Extracts just the "TAlias" type entries from an .elmi file."""

    def visit_aliastype(self, filled, type_):
        return None

    def visit_annotation(self, free_variables, type_):
        return type_

    def visit_fieldtype(self, source_order, type_):
        return None

    def visit_interface(self, annotations):
        return annotations

    def visit_module_name(self, package, name):
        return (package, name)

    def visit_name(self, name):
        return name

    def visit_package_name(self, author, name):
        return (author, name)

    def visit_talias(self, module_name, name, fields, type_):
        return (module_name, name)

    def visit_tlambda(self, left, right):
        return None

    def visit_trecord(self, fields, name):
        return None

    def visit_ttuple(self, first, second, maybe_third):
        return None

    def visit_ttype(self, module_name, name, types):
        return None

    def visit_tunit(self):
        return None

    def visit_tvar(self, name):
        return None


# Extract all tests stored in the source file.
with open(sys.argv[1], "rb") as f:
    all_tests = sorted(
        name
        for name, type_ in _read_interface(f, TypeAliasExtractor()).items()
        if type_ == ((("elm-explorations", "test"), "Test"), "Test")
    )
if not all_tests:
    raise Exception("Failed to find any tests in this source file")

module_name = os.path.basename(sys.argv[1])
if module_name.endswith(".elmi"):
    module_name = module_name[:-5]

# Emit a main source file that calls the tests.
# TODO(edsch): What about the seed?
with open(sys.argv[2], "w") as f:
    print(
        """import Console.Text exposing (UseColor(..))
import Test
import Test.Reporter.Reporter exposing (Report(..))
import Test.Runner.Node

import %(module_name)s

main : Test.Runner.Node.TestProgram
main =
    [ Test.describe "%(module_name)s" [%(tests)s] ]
        |> Test.concat
        |> Test.Runner.Node.run {
            runs = Nothing,
            report = (ConsoleReport UseColor),
            seed = 236315485321474,
            processes = 1,
            paths = ["%(source_file)s"]
        }"""
        % {
            "source_file": sys.argv[1],
            "module_name": module_name,
            "tests": ", ".join("%s.%s" % (module_name, test) for test in all_tests),
        },
        file=f,
    )
