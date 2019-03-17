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
    if length > 10000:
        raise OverflowError("Cannot read string of length %d (%#018x) at offset %#x" % (length, length, offset))
    return str(f.read(length), encoding="ASCII")


def _read_tvar(f):
    return _read_string(f)

def _read_tlambda(f):
    return "(%s) -> (%s)" % (_read_type(f), _read_type(f))

def _read_maybe(f, read_func):
    has_value = _read_uint8(f)
    if has_value == 0:
        return None
    if has_value == 1:
        return read_func(f)
    raise OverflowError("Unknown maybe field value %d" % has_type)

def _read_ttuple(f):
    fields = [_read_type(f), _read_type(f)]
    third = _read_maybe(f, _read_type)
    if third:
        fields.append(third)
    return "(%s)" % ", ".join(fields)

def _read_trecord(f):
    raise OverflowError("Not implemented")

def _read_type(f):
    offset = f.tell()
    tag = _read_uint8(f)
    if tag == 0:
        return read_tlambda(f)
    elif tag == 1:
        return _read_tvar(f)
    elif tag == 2:
        return _read_trecord(f)
    elif tag == 3:
        raise OverflowError("Unknown tag %d at offset %#x" % (tag, offset))
    elif tag == 4:
        return _read_ttuple(f)
    elif tag == 5:
        a = _read_string(f)
        b = _read_string(f)
        c = _read_string(f)
        d = _read_string(f)
        return "\"%s.%s.%s\".%s" % (a, b, c, d)
    elif tag == 6:
        raise OverflowError("Unknown tag %d at offset %#x" % (tag, offset))
    elif tag == 7:
        a = _read_string(f)
        b = _read_string(f)
        c = _read_string(f)
        d = _read_string(f)
        return "\"%s.%s.%s\".%s" % (a, b, c, d)
    else:
        raise OverflowError("Unknown tag %d at offset %#x" % (tag, offset))

# From compiler/src/AST/Canonical.hs
with open(sys.argv[1], "rb") as f:
    # Parse types.
    for _ in range(_read_uint64(f)):
        print("Name: ", _read_string(f))
        for _ in range(_read_uint64(f)):
            print("| Free variable: " + _read_string(f))
        print("| Type: " + _read_type(f))

    # Parse unions.
    for _ in range(_read_uint64(f)):
        raise NotImplementedError

    # Parse aliases.
    for _ in range(_read_uint64(f)):
        raise NotImplementedError

    # Parse binary operators.
    for _ in range(_read_uint64(f)):
        raise NotImplementedError
