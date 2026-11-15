#!/usr/bin/env python3
"""Loopback-only HTTP fixture for streaming limits and cancellation checks."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import sys
import json
import re
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
        health_mode = Path(sys.argv[1]).parent / 'health-mode'
        if route == '/version' and health_mode.exists(): route = '/health/' + health_mode.read_text()
        if route in ("/version", "/put-count"):
            body = b'{"version":"v1.19.32"}' if route == "/version" else str(Handler.put_count).encode()
            self.send_response(200)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if route.startswith('/health/'):
            count_file = Path(sys.argv[1]).parent / 'health-count'
            count = int(count_file.read_text()) if count_file.exists() else 0
            count_file.write_text(str(count + 1))
            version = re.search(r'^public let configurationCoreVersion = "([^"]+)"$', Path('Sources/MihomoGUICore/DocSchemas.swift').read_text(), re.M)[1]
            body = {'version': 'v' + version, 'meta': True}
            if route == '/health/version': body['version'] = 'v0.0.0'
            if route == '/health/meta': body['meta'] = False
            if route == '/health/oversized': body['padding'] = 'x' * 65536
            data = b'OK' if route == '/health/text' else json.dumps(body).encode()
            self.send_response(401 if route == '/health/unauthorized' else 302 if route == '/health/redirect' else 200)
            if route != '/health/timeout': self.send_header('Content-Length', str(len(data)))
            self.end_headers()
            try:
                self.wfile.write(data); self.wfile.flush()
                if route == '/health/timeout': time.sleep(2)
            except (BrokenPipeError, ConnectionResetError): pass
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
