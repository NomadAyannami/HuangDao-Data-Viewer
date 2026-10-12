"""Export the local Excel workbook to persistent dashboard JSON."""

import json
import os
from pathlib import Path

from openpyxl import load_workbook


ROOT = Path(__file__).resolve().parent
DATA_FILE = Path(r"D:\原始数据\各期期数表汇总\基础数据汇总_订单已匹配.xlsx")
OUTPUT_FILE = ROOT / "panel_data.json"


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


def update_json():
    rows = read_rows()
    body = json.dumps(rows, ensure_ascii=False, default=str, separators=(",", ":")).encode("utf-8")
    if OUTPUT_FILE.is_file() and OUTPUT_FILE.read_bytes() == body:
        print(f"Data unchanged: {len(rows)} rows")
        return

    temporary_file = OUTPUT_FILE.with_suffix(".json.tmp")
    try:
        temporary_file.write_bytes(body)
        os.replace(temporary_file, OUTPUT_FILE)
    finally:
        temporary_file.unlink(missing_ok=True)
    print(f"Updated {OUTPUT_FILE.name}: {len(rows)} rows")


if __name__ == "__main__":
    if not DATA_FILE.is_file():
        raise SystemExit(f"Data source not found: {DATA_FILE}")
    update_json()
