from typing import Dict
import pyright
import subprocess
import json
import io

from ..pyright_to_rdjson import pyright_to_rdjson


class TestPyright:
    def test_pyright_to_rdjson(self):
        result = pyright.run(
            "--outputjson",
            "./pyright_to_rdjson/tests/files",
            stdout=subprocess.PIPE,
        )

        assert result.returncode == 1
        assert len(result.stdout) > 0

        result_string: str = ""
        if isinstance(result.stdout, bytes):
            result_string = result.stdout.decode("utf-8")
        elif isinstance(result.stdout, str):
            result_string = str(result.stdout)

        result_pyright = json.loads(result_string)

        result_rdjson = pyright_to_rdjson(io.StringIO(json.dumps(result_pyright)))
        assert isinstance(result_rdjson, str)
        assert len(result_rdjson) > 0

        result_rdjson = json.loads(result_rdjson)

        diagnostic: Dict
        for i, rdjson_diagnostic in enumerate(result_rdjson["diagnostics"]):
            rdjson_line_range = rdjson_diagnostic["location"]["range"]
            rdjson_line_start = rdjson_line_range["start"]
            rdjson_line_end = rdjson_line_range["end"]

            pyright_diagnostic = result_pyright["generalDiagnostics"][i]
            pyright_line_range = pyright_diagnostic["range"]
            pyright_line_start = pyright_line_range["start"]
            pyright_line_end = pyright_line_range["end"]

            assert rdjson_line_start["line"] == pyright_line_start["line"]
            assert rdjson_line_start["column"] == pyright_line_start["character"]

            assert rdjson_line_end["line"] == pyright_line_end["line"]
            assert rdjson_line_end["column"] == pyright_line_end["character"]
