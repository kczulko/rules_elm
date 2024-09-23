import sys
import os
import gzip

(
    compressed_filepath,
    decompressed_filepath,
) = sys.argv[1:3]

with open(decompressed_filepath, "xb") as decompressed:
    with gzip.open(compressed_filepath, 'rb') as compressed:
        decompressed.write(compressed.read())

os.chmod(decompressed_filepath, 0o555)

