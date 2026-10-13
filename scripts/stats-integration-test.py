"""Isolated collector test: local fake controller, temporary database, no real proxy traffic."""
import http.server
import json
import pathlib
import sqlite3
import subprocess
import tempfile
import threading
import time

binary = pathlib.Path(__file__).resolve().parents[1] / ".build/manual/clash-stats"
samples = 0
connection_count = 1000


class Controller(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        global samples
        if self.headers.get("Authorization") != "Bearer test-secret":
            self.send_error(401)
            return
        samples += 1
        payload = {"connections": [
            {"id": str(i), "metadata": {"host": f"domain-{i % 20}.test", "processPath": "/bin/fixture"},
             "upload": samples * 10, "download": samples * 20, "chains": ["Fixture Node"]}
            for i in range(connection_count)
        ]}
        data = json.dumps(payload).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, *args):
        pass


server = http.server.HTTPServer(("127.0.0.1", 0), Controller)
threading.Thread(target=server.serve_forever, daemon=True).start()
try:
    with tempfile.TemporaryDirectory(prefix="clashdesk-collector-test-") as temp:
        directory = pathlib.Path(temp)
        settings = {"corePath": "", "secret": "test-secret", "subscriptions": [],
                    "rules": [], "tun": False, "defaultNode": None}
        (directory / "settings.json").write_text(json.dumps(settings))
        command = [str(binary), "--directory", temp, "--port", str(server.server_port)]
        process = subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        try:
            deadline = time.monotonic() + 20
            while samples < 4 and time.monotonic() < deadline:
                if process.poll() is not None:
                    raise AssertionError(process.stderr.read().decode())
                time.sleep(0.1)
            assert samples >= 4, "collector did not sample"
            time.sleep(0.2)  # allow the last SQLite transaction to commit
            rss = subprocess.check_output(["/bin/ps", "-o", "rss=", "-p", str(process.pid)], text=True).strip()
            duplicate = subprocess.run(command + ["--once"], capture_output=True, text=True, timeout=5)
            assert duplicate.returncode != 0, "duplicate collector must be rejected"
            with sqlite3.connect(directory / "traffic.sqlite") as db:
                up, down = db.execute("SELECT SUM(upload),SUM(download) FROM traffic").fetchone()
                assert up == (samples - 1) * 10 * connection_count, (up, samples)
                assert down == up * 2
                assert db.execute("SELECT COUNT(*) FROM traffic").fetchone()[0] == 20
            print("PASS: collector samples, persists deltas, aggregates and rejects duplicate instances")
            print(f"Observed collector RSS with {connection_count} active fixture connections: {int(rss) / 1024:.1f} MiB")
        finally:
            process.terminate()
            process.wait(timeout=5)
            process.stderr.close()
        subprocess.run(command + ["--once"], check=True, timeout=5)
        with sqlite3.connect(directory / "traffic.sqlite") as db:
            assert db.execute("SELECT SUM(upload) FROM traffic").fetchone()[0] == up
        print("PASS: collector restart establishes baseline without double counting")
finally:
    server.shutdown()
    server.server_close()
