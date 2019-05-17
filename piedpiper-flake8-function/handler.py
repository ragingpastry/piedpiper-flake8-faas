from flake8.api import legacy as flake8
import tempfile
import io
import yaml
from contextlib import redirect_stdout
import os

from .util import unzip_files,\
    update_task_id_status, upload_artifact, download_artifact, read_secrets
from .config import Config

gman_url = Config['gman']['url']
storage_url = Config['storage']['url']


def handle(request):
    """handle a request to the function
    Args:
        req (str): request body
    """
    run_id = request.get_json().get('run_id')
    task_id = request.get_json()['task_id']

    access_key = read_secrets().get('access_key')
    secret_key = read_secrets().get('secret_key')

    update_task_id_status(gman_url=gman_url, status='received', task_id=task_id,
                          message='Received execution task from flake8 gateway')

    ## Download artifact from artifact URL
    with tempfile.TemporaryDirectory() as temp_directory:
        download_artifact(run_id, 'artifacts/flake8.zip', f'{temp_directory}/flake8.zip', storage_url,
                          access_key, secret_key)

        flake_reports = []

        unzip_files(f'{temp_directory}/flake8.zip', temp_directory)
        os.chdir(temp_directory)
        report = run_flake8('.')
        flake_reports.append(report)

        log_file = f'{temp_directory}/flake8.log'
        with open(log_file, 'w') as f:
            f.write(yaml.safe_dump(flake_reports))
        upload_artifact(run_id, 'artifacts/flake8.log', log_file, storage_url, access_key, secret_key)
        update_task_id_status(gman_url=gman_url, task_id=task_id,
                              status='completed', message='Flake8 execution complete')

    return '\n'.join(flake_reports)


def run_flake8(directory):
    with io.StringIO() as buf, redirect_stdout(buf):
        style_guide = flake8.get_style_guide()
        style_guide.check_files([directory])
        return buf.getvalue()
