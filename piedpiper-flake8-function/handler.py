from flake8.api import legacy as flake8
import io
from contextlib import redirect_stdout
import os

from .util import build_temp_zipfiles, build_directories, unzip_files


def handle(request):
    """handle a request to the function
    Args:
        req (str): request body
    """

    zip_files = build_temp_zipfiles(request)
    temp_directories = build_directories(request)
    flake_reports = []

    for zip_file, temp_directory in zip(zip_files, temp_directories):
        unzip_files(zip_file, temp_directory.name)
        os.chdir(temp_directory.name)
        report = run_flake8('.')
        flake_reports.append(report)

    return '\n'.join(flake_reports)

def run_flake8(directory):
    with io.StringIO() as buf, redirect_stdout(buf):
        style_guide = flake8.get_style_guide()
        report = style_guide.check_files([directory])
        return buf.getvalue()

