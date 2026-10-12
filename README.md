# 黄导数据查询面板

数据表位于 `D:\原始数据\各期期数表汇总\基础数据汇总_订单已匹配.xlsx`。本地服务在每次请求 `/api/data` 时读取该表，在内存中生成 JSON 并返回给页面；不会在项目目录保存 JSON 文件。

在已安装 Python 的 Windows 电脑上，以管理员身份运行 `install_local_data_task.ps1`。脚本会准备 `.venv`、安装依赖、注册开机启动任务 `HuangDaoLocalDataServer`，并立即启动服务。之后从本机打开 `http://127.0.0.1:8765/`。

服务仅监听 `127.0.0.1:8765`。运行中的 `run_local_data_server.ps1` 会在 Python 服务退出后重新启动它。电脑休眠或关机期间服务不可用。

目前 GitHub Pages 上的静态页面没有连接本机服务的通道，因此在 GitHub Pages 域名打开时会显示数据加载失败。本机服务返回完整数据给访问它的浏览器；这一步尚未加入飞书环境判定。
