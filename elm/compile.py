import os
import sys

os.rename(sys.argv[1], "elm.json")
os.execv(sys.argv[2], [sys.argv[2], "make", sys.argv[3]])
