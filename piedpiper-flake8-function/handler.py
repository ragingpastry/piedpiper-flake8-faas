import tempfile
import sys
from flake8.api import legacy as flake8
import io
from contextlib import redirect_stdout
import zipfile
import os


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


def build_temp_zipfiles(request):
    zip_files = []
    for zip_file in request.files.getlist("files"):
        tmp_file = tempfile.NamedTemporaryFile(delete=False)
        tmp_file.write(zip_file.read())
        tmp_file.flush()
        zip_files.append(tmp_file.name)
    return zip_files

def build_directories(request):

    temp_directories = []
    for _ in request.files.getlist("files"):
        temp_directory = tempfile.TemporaryDirectory()
        temp_directories.append(temp_directory)

    return temp_directories

def unzip_files(zip_file, temp_directory):
    zip_ref = zipfile.ZipFile(zip_file, 'r')
    zip_ref.extractall(temp_directory)
    zip_ref.close()
