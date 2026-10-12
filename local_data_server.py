"""Serve the dashboard and read its Excel source on every data request.

The workbook stays at DATA_FILE. JSON is generated in memory and is never saved.
"""

import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit

from openpyxl import load_workbook


ROOT = Path(__file__).resolve().parent
DATA_FILE = Path(r"D:\原始数据\各期期数表汇总\基础数据汇总_订单已匹配.xlsx")
HOST = "127.0.0.1"
PORT = 8765
PAGES = {
    "/": ROOT / "index.html",
    "/index.html": ROOT / "index.html",
    "/数据查看面板.html": ROOT / "数据查看面板.html",
}


def read_rows():
    workbook = load_workbook(DATA_FILE, read_only=True, data_only=True)
    try:
        values = workbook.worksheets[0].values
        headers = next(values)
        if not headers or any(not header for header in headers):
            raise ValueError("Excel 表头为空")
        return [
            dict(zip(headers, ("" if value is None else value for value in values_row)))
            for values_row in values
        ]
    finally:
        workbook.close()


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = unquote(urlsplit(self.path).path)
        if path == "/api/data":
            try:
                body = json.dumps(read_rows(), ensure_ascii=False, default=str).encode("utf-8")
            except Exception as error:
                print(f"Excel 读取失败: {error}", file=sys.stderr, flush=True)
                self.send_error(503, "Excel data unavailable")
                return
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
        elif path in PAGES:
            body = PAGES[path].read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
        else:
            self.send_error(404)
            return
        self.send_header("Cache-Control", "no-store, max-age=0")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        pass


if __name__ == "__main__":
    if not DATA_FILE.is_file():
        raise SystemExit(f"找不到本地数据源: {DATA_FILE}")
    print(f"黄导数据面板: http://{HOST}:{PORT}/", flush=True)
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
