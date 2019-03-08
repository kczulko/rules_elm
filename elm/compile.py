import os
import json
import sys

with open("elm.json", "w") as f:
    json.dump(
        {
            "type": "application",
            "dependencies": {
                # TODO(edsch): These dependencies shouldn't be necessary.
                # https://github.com/elm/compiler/issues/1908
                "direct": {"elm/core": "1.0.2", "elm/json": "1.0.0"},
                "indirect": {},
            },
            "elm-version": "0.19.0",
            "source-directories": [],
            "test-dependencies": {"direct": {}, "indirect": {}},
        },
        f,
    )

os.execv(sys.argv[1], [sys.argv[1], "make", sys.argv[2]])
