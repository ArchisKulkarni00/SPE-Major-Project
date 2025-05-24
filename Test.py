import unittest
import os
import subprocess
import time
import requests

class TestFileExistenceAndAPIRun(unittest.TestCase):

    def test_config_yml_exists(self):
        self.assertTrue(os.path.exists("config.yml"), "config.yml does not exist")

    def test_database_exists(self):
        self.assertTrue(os.path.exists("iiitb_dataset.db"), "iiitb_dataset.db does not exist")

    def test_synonyms_csv_exists(self):
        self.assertTrue(os.path.exists("synonyms.csv"), "synonyms.csv does not exist")

    def test_fastapi_file_exists(self):
        self.assertTrue(os.path.exists("Fastapi.py"), "Fastapi.py does not exist")

    def test_utils_file_exists(self):
        self.assertTrue(os.path.exists("utils.py"), "utils.py does not exist")

    def test_fastapi_api_runs_on_port_8000(self):
        # Start the FastAPI server
        process = subprocess.Popen(["python3", "Fastapi.py"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        try:
            # Wait for server to start
            time.sleep(5)

            # Attempt to connect to FastAPI server
            response = requests.get("http://localhost:8000/ask")

            # Check that we got a valid response (200 OK or similar)
            self.assertTrue(response.status_code < 500, f"Server returned status code {response.status_code}")

        except Exception as e:
            self.fail(f"Could not connect to FastAPI server: {e}")

        finally:
            # Kill the server process after test
            process.terminate()
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                process.kill()


if __name__ == '__main__':
    unittest.main()
