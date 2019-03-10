import json
import os
import struct
import sys

import subprocess

PACKAGES_DIR = "elm-home/0.19.0/package"

# Construct an ELM_HOME directory, containing symlinks to all the
# packages we want to be available to the build.
all_packages = []
for package_dir in sys.argv[4:]:
    with open(os.path.join(package_dir, "elm.json")) as f:
        metadata = json.load(f)
    all_packages.append((metadata["name"], metadata["version"]))

    internal_package_dir = os.path.join(PACKAGES_DIR, metadata["name"])
    os.makedirs(internal_package_dir)
    os.symlink(
        os.path.abspath(package_dir),
        os.path.join(internal_package_dir, metadata["version"]),
    )

# Generate a versions.dat package index file. Without it, Elm will be
# dependent on internet access. Let the package index file contain just
# those packages that are available to the build.
with open(os.path.join(PACKAGES_DIR, "versions.dat"), "wb") as f:
    f.write(struct.pack(">QQ", len(all_packages), len(all_packages)))
    for name, version in sorted(all_packages):
        name_parts = name.split("/", 1)
        version_parts = version.split(".", 2)
        f.write(struct.pack(">Q", len(name_parts[0])))
        f.write(bytes(name_parts[0], encoding="ASCII"))
        f.write(struct.pack(">Q", len(name_parts[1])))
        f.write(bytes(name_parts[1], encoding="ASCII"))
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

os.symlink(sys.argv[1], "elm.json")
os.execve(sys.argv[2], [sys.argv[2], "make", sys.argv[3]], {"ELM_HOME": "elm-home"})
