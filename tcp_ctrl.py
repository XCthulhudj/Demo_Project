"""X 轴连续点动（简版，自己启动 / Ctrl-C 停）。

修正点：
  1) 补回 logging.basicConfig(...) 和 log = logging.getLogger(__name__)
     —— 你贴的版本删了这两处，运行到第一条 log.info 就会 NameError。
  2) 补回 __main__ 保护与 KeyboardInterrupt，退出前由 finally 发 STOP。
"""
import logging
import socket
import time

HOST, PORT = "192.168.1.132", 4241
INTERVAL = 1
VEL, DIR = 500, 1
START = f"JOG_x_{DIR}_v_{VEL}_s_1\r\n".encode()   # 启动：+X, 50 mm/s
STOP = f"JOG_x_{DIR}_v_{VEL}_s_0\r\n".encode()    # 停止

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
log = logging.getLogger(__name__)


def main():
    log.info("启动客户端，目标 %s:%d", HOST, PORT)
    while True:                                  # 外层：断线就重连
        try:
            with socket.create_connection((HOST, PORT), timeout=5) as s:
                s.settimeout(2)
                log.info("已连接，开始点动")
                try:
                    while True:
                        s.sendall(START)         # 启动 + 保活
                        try:
                            data = s.recv(1024)  # 读回包，避免收缓冲塞满
                            if data:
                                for line in data.split(b"\r\n"):
                                    if line:
                                        log.info("收到: %r", line)
                        except socket.timeout:
                            pass
                        time.sleep(INTERVAL)
                finally:
                    try:
                        s.sendall(STOP)          # 退出前必须停
                        log.info("已发送停止，%.1fs 后断开", 0.3)
                        time.sleep(0.3)
                    except OSError:
                        pass
        except (socket.timeout, ConnectionError, OSError) as e:
            log.error("连接失败/断开: %s，5 秒后重连", e)
            time.sleep(5)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        log.info("手动退出")
