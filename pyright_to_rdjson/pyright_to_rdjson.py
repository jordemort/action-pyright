import json
import os
import sys
from typing import Any, Dict, TextIO


def validate_pyright_json(pyright: Dict) -> None:
    """Validate if the input JSON contains pyright diagnostics."""
    if "generalDiagnostics" not in pyright:
        raise RuntimeError("This doesn't look like pyright json")


def convert_range(range_info: Dict[str, Dict[str, int]]) -> Dict[str, Dict[str, int]]:
    """Convert zero-based offsets from pyright to one-based for rdjson."""
    return {
        "start": {
            "line": range_info["start"]["line"] + 1,
            "column": range_info["start"]["character"] + 1,
        },
        "end": {
            "line": range_info["end"]["line"] + 1,
            "column": range_info["end"]["character"] + 1,
        },
    }


def create_diagnostic_entry(diagnostic: Dict[str, Any]) -> Dict[str, Any]:
    """Create an rdjson diagnostic entry from a pyright diagnostic."""
    message = diagnostic["message"]
    rule = diagnostic.get("rule")

    if rule:
        message = f"{message} ({rule})"

    return {
        "message": message,
        "severity": diagnostic["severity"].upper(),
        "location": {
            "path": diagnostic["file"],
            "range": convert_range(diagnostic["range"]),
        },
    }


def pyright_to_rdjson(jsonin: TextIO) -> str:
    """Convert pyright JSON diagnostics to rdjson format."""
    pyright: Dict[str, Any] = json.load(jsonin)
    tool_name: str = os.getenv("INPUT_TOOL_NAME", "pyright")
    validate_pyright_json(pyright)
    rdjson: Dict[str, Any] = {
        "source": {"name": tool_name, "url": "https://github.com/Microsoft/pyright"},
        "severity": "WARNING",
        "diagnostics": [
            create_diagnostic_entry(d) for d in pyright["generalDiagnostics"]
        ],
    }

    return json.dumps(rdjson, indent=2)


if __name__ == "__main__":
    print(pyright_to_rdjson(sys.stdin))
