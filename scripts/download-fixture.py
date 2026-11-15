#!/usr/bin/env python3
"""Loopback-only HTTP fixture for streaming limits and cancellation checks."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import sys
import time


class Handler(BaseHTTPRequestHandler):
    put_count = 0

    def do_PUT(self):
        Handler.put_count += 1
        self.send_response(204)
        self.end_headers()

    def log_message(self, *_args):
        pass

    def do_GET(self):
        route = self.path.split("?", 1)[0]
        if route in ("/version", "/put-count"):
            body = b'{"version":"v1.19.32"}' if route == "/version" else str(Handler.put_count).encode()
            self.send_response(200)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        self.send_response(503 if route == "/error" else 200)
        if route == "/exact":
            self.send_header("Content-Length", "1024")
        elif route == "/declared":
            self.send_header("Content-Length", "1000000000")
        elif route == "/empty":
            self.send_header("Content-Length", "0")
        self.end_headers()
        if route in ("/error", "/empty"):
            return
        count = 1 if route == "/exact" else 1000 if route == "/cancel" else 64
        try:
            for _ in range(count):
                self.wfile.write(b"x" * 1024)
                self.wfile.flush()
                time.sleep(0.01)
        except (BrokenPipeError, ConnectionResetError):
            pass


if __name__ == "__main__":
    server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
    Path(sys.argv[1]).write_text(str(server.server_port))
    server.serve_forever()
