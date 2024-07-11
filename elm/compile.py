import json
import os
import struct
import subprocess
import sys

def mkdir(directory):
    try:
        original_umask = os.umask(0)
        os.makedirs(directory)
    finally:
        os.umask(original_umask)

PACKAGES_DIR = "elm-home/0.19.1/packages"
mkdir(PACKAGES_DIR)

(
    arg_compilation_mode,
    arg_elm_binary,
    arg_elm_json,
    arg_main,
    arg_out_js,
    arg_out_elmi,
) = sys.argv[1:7]

# Construct an ELM_HOME directory, containing symlinks to all the
# packages we want to be available to the build.
all_packages = []
for package_dir in sys.argv[7:]:
    with open(os.path.join(package_dir, "elm.json")) as f:
        metadata = json.load(f)
    all_packages.append((metadata["name"].split("/", 1), metadata["version"]))

    internal_package_dir = os.path.join(PACKAGES_DIR, metadata["name"])
    mkdir(internal_package_dir)
    os.symlink(
        os.path.abspath(package_dir),
        os.path.join(internal_package_dir, metadata["version"]),
    )

def str_to_bytes(s):
    try:
        return bytes(s, encoding="ASCII")
    except TypeError:
        return bytes(s)

# os.system("ls -la elm-home/0.19.1/packages/elm")

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
    os.chmod(root, 0o700)

# Convert Bazel compilation mode to flags for 'elm make'.
opt_flags = {"dbg": ["--debug"], "fastbuild": [], "opt": ["--optimize"]}[
    arg_compilation_mode
]

# Invoke Elm build action.
os.symlink(arg_elm_json, "elm.json")

exit_code = subprocess.call(
    [arg_elm_binary, "make", "--output=" + arg_out_js, arg_main] + opt_flags,
    env={"ELM_HOME": "elm-home"},
    stdout=open(os.devnull, "w"),
)

