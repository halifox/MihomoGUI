import http.server
import pathlib
import sys
import time

class Proxy(http.server.BaseHTTPRequestHandler):
    def do_CONNECT(self):
        self.send_response(200)
        self.end_headers()
        request = self.connection.recv(65536)
        time.sleep(2 if b"/slow" in request else 0.03)
        try:
            self.connection.sendall(b"HTTP/1.1 204 No Content\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
        except (BrokenPipeError, ConnectionResetError):
            pass
        self.close_connection = True

    def do_GET(self):
        if "/rules.yaml" in self.path:
            body = b"payload:\n  - '+.http.fixture.test'\n"
            self.send_response(200)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        time.sleep(2 if "/slow" in self.path else 0.03)
        try:
            self.send_response(204)
            self.send_header("Content-Length", "0")
            self.end_headers()
        except (BrokenPipeError, ConnectionResetError):
            pass

    def log_message(self, *args):
        pass

server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Proxy)
pathlib.Path(sys.argv[1]).write_text(str(server.server_port))
server.serve_forever()
