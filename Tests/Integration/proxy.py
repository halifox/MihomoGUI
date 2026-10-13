import http.server
import pathlib
import sys
import time

class Proxy(http.server.BaseHTTPRequestHandler):
    def do_CONNECT(self):
        self.send_response(200)
        self.end_headers()
        self.connection.recv(65536)
        time.sleep(0.03)
        self.connection.sendall(b"HTTP/1.1 204 No Content\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
        self.close_connection = True

    def do_GET(self):
        time.sleep(0.03)
        self.send_response(204)
        self.send_header("Content-Length", "0")
        self.end_headers()

    def log_message(self, *args):
        pass

server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Proxy)
pathlib.Path(sys.argv[1]).write_text(str(server.server_port))
server.serve_forever()
