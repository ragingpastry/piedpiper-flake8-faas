import tempfile
import sys
#from pylint import epylint as lint
from flake8.api import legacy as flake8
import io
from contextlib import redirect_stdout

def handle(req):
    """handle a request to the function
    Args:
        req (str): request body
    """

    flake_report = []
    for py_file in req.files.getlist("files"):
        temp_file = tempfile.NamedTemporaryFile(delete=False)
        temp_file.write(py_file.read())
        temp_file.flush()


    #pylint_stdout, pylint_stderr = lint.py_run(temp_file, return_std=True)

        with io.StringIO() as buf, redirect_stdout(buf):
            style_guide = flake8.get_style_guide()
            report = style_guide.check_files([temp_file.name])
            flake_report.append(buf.getvalue())



    #return pylint_stdout.read()
    return '\n'.join(flake_report)
