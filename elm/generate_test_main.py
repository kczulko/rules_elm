from __future__ import print_function

import struct
import sys


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
        raise OverflowError(
            "Cannot read string of length %d (%#018x) at offset %#x"
            % (length, length, offset)
        )
    data = f.read(length)
    try:
        return str(data, encoding="ASCII")
    except TypeError:
        return str(data)


def _create_list_reader(read_element):
    def reader(f):
        res = []
        for _ in range(_read_uint64(f)):
            res.append(read_element(f))
        return res

    return reader


def _create_map_reader(read_key, read_value):
    def reader(f):
        res = {}
        for _ in range(_read_uint64(f)):
            key = read_key(f)
            if key in res:
                raise KeyError("Key %s already exists" % key)
            res[key] = read_value(f)
        return res

    return reader


def _create_maybe_reader(read_value):
    def reader(f):
        has_value = _read_uint8(f)
        if has_value == 0:
            return None
        if has_value == 1:
            return read_value(f)
        raise OverflowError("Unknown maybe field value %d" % has_type)

    return reader


def _create_set_reader(read_key):
    def reader(f):
        res = set()
        for _ in range(_read_uint64(f)):
            key = read_key(f)
            if key in res:
                raise KeyError("Key %s already exists" % key)
            res.add(key)
        return res

    return reader


# Types from compiler/src/Elm/Name.hs.


def _read_name(f):
    return _read_string(f)


# Types from compiler/src/Elm/Package.hs.


def _read_package_name(f):
    return (_read_string(f), _read_string(f))


# Types from compiler/src/AST/Module/Name.hs.


def _read_module_name(f):
    return (_read_package_name(f), _read_name(f))


# Types from compiler/src/AST/Canonical.hs.


def _read_annotation(f):
    return (_read_freevars(f), _read_type(f))


def _read_freevars(f):
    return _create_set_reader(_read_name)(f)


def _read_tvar(f):
    return _read_name(f)


def _read_tlambda(f):
    return (_read_type(f), _read_type(f))


def _read_ttuple(f):
    return (_read_type(f), _read_type(f), _create_maybe_reader(_read_type)(f))


def _read_fieldtype(f):
    return (_read_uint16(f), _read_type(f))


def _read_trecord(f):
    return (
        _create_map_reader(_read_name, _read_fieldtype)(f),
        _create_maybe_reader(_read_name)(f),
    )


def _read_tunit(f):
    return ()


def _read_ttype(f):
    return (_read_module_name(f), _read_name(f), _create_list_reader(_read_type)(f))


def _read_ttype_n(f, n):
    module_name = _read_module_name(f)
    name = _read_name(f)
    types = []
    for _ in range(n):
        types.append(_read_type(f))
    return (module_name, name, types)


def _read_talias(f):
    return (
        _read_module_name(f),
        _read_name(f),
        _create_list_reader(lambda f: (_read_name(f), _read_type(f)))(f),
        _read_alias_type(f),
    )


def _read_alias_type(f):
    offset = f.tell()
    tag = _read_uint8(f)
    if tag == 0:
        return (False, _read_type(f))
    elif tag == 1:
        return (True, _read_type(f))
    else:
        raise OverflowError("Unknown alias type kind %d at offset %#x" % (tag, offset))


def _read_type(f):
    tag = _read_uint8(f)
    if tag == 0:
        return _read_tlambda(f)
    elif tag == 1:
        return _read_tvar(f)
    elif tag == 2:
        return _read_trecord(f)
    elif tag == 3:
        return _read_tunit(f)
    elif tag == 4:
        return _read_ttuple(f)
    elif tag == 5:
        return _read_talias(f)
    elif tag == 6:
        return _read_ttype(f)
    else:
        return _read_ttype_n(f, tag - 7)


# Types from compiler/src/Elm/Interface.hs.


def _read_interface(f):
    return _create_map_reader(_read_name, _read_annotation)(f)
    # TODO(edsch): Unions, aliases, binops.


with open(sys.argv[1], "rb") as f:
    print(_read_interface(f))
