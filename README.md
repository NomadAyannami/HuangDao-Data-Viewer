# 黄导数据查询面板

网页从仓库中的 `panel_data.json` 读取数据。该文件长期保存于仓库，并由 GitHub Pages 公开提供；访问者可以下载其中的全部数据。

数据源仍是本机的 `D:\原始数据\各期期数表汇总\基础数据汇总_订单已匹配.xlsx`。在安装 Python 的 Windows 电脑上，手动运行 `update_data.ps1` 即可读取 Excel、更新 JSON，并提交和推送到 GitHub `main`。只有生成的 JSON 内容变化时才会产生新提交。脚本不常驻，也没有开机任务。

`update_data.py` 仅负责生成本地 JSON。单独运行它不会推送 GitHub。首次运行脚本时会创建 `.venv` 并安装 `requirements.txt` 中的依赖。
