import json
import os
import struct
import subprocess
import sys

PACKAGES_DIR = "elm-home/0.19.0/package"

# Construct an ELM_HOME directory, containing symlinks to all the
# packages we want to be available to the build.
all_packages = []
for package_dir in sys.argv[6:]:
    with open(os.path.join(package_dir, "elm.json")) as f:
        metadata = json.load(f)
    all_packages.append((metadata["name"].split("/", 1), metadata["version"]))

    internal_package_dir = os.path.join(PACKAGES_DIR, metadata["name"])
    os.makedirs(internal_package_dir)
    os.symlink(
        os.path.abspath(package_dir),
        os.path.join(internal_package_dir, metadata["version"]),
    )


def str_to_bytes(s):
    try:
        return bytes(s, encoding="ASCII")
    except TypeError:
        return bytes(s)


# Generate a versions.dat package index file. Without it, Elm will be
# dependent on internet access. Let the package index file contain just
# those packages that are available to the build.
with open(os.path.join(PACKAGES_DIR, "versions.dat"), "wb") as f:
    f.write(struct.pack(">QQ", len(all_packages), len(all_packages)))
    for name_parts, version in sorted(all_packages):
        version_parts = version.split(".", 2)
        f.write(struct.pack(">Q", len(name_parts[0])))
        f.write(str_to_bytes(name_parts[0]))
        f.write(struct.pack(">Q", len(name_parts[1])))
        f.write(str_to_bytes(name_parts[1]))
        f.write(
            struct.pack(
                ">QBBB",
                1,
                int(version_parts[0]),
                int(version_parts[1]),
                int(version_parts[2]),
            )
        )

# Cause a hard failure in case Elm tries to bypass our packages.
for root, dirs, files in os.walk("elm-home"):
    os.chmod(root, 0o500)

# Invoke Elm build action.
os.symlink(sys.argv[2], "elm.json")
main_file = sys.argv[3]
subprocess.check_call(
    [sys.argv[1], "make", "--output=" + sys.argv[4], main_file],
    env={"ELM_HOME": "elm-home"},
    stdout=open(os.devnull, "w"),
)

# Preserve the .elmi file. This file contains information about
# top-level declarations in the source file. It is used by elm_test() to
# automatically generate an entry point that invokes all unit tests.
if sys.argv[5] != "":
    elmi_file = os.path.basename(main_file)
    if elmi_file.endswith(".elm"):
        elmi_file = elmi_file[:-4]
    elmi_file += ".elmi"
    os.rename(os.path.join("elm-stuff/0.19.0", elmi_file), sys.argv[5])
