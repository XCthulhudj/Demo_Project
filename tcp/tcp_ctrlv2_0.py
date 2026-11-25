"""Y 轴连续点动（简版，自己启动 / Ctrl-C 停）。

修正点：
  1) 补回 logging.basicConfig(...) 和 log = logging.getLogger(__name__)
  2) 补回 __main__ 保护与 KeyboardInterrupt，退出前由 finally 发 STOP
  3) 连接后先发 ENC_ENABLE 0：无编码器的板子必须关，
     否则 700ms 无反馈看门狗会把 JOG 掐掉（trajectory_cpu0.c 的 pl_no_fb_check）
     注意：ENC_ENABLE 不落 EEPROM，每次重烧/上电都要重发一次
"""
import logging
import socket
import time

HOST, PORT = "192.168.1.132", 4241
AXIS = 'y'
INTERVAL = 1
VEL, DIR = 60, 1
START = f"JOG_{AXIS}_{DIR}_v_{VEL}_s_1\r\n".encode()   # 启动：+Y, 100 mm/s
STOP = f"JOG_{AXIS}_{DIR}_v_{VEL}_s_0\r\n".encode()    # 停止
ENC_OFF = b"ENC_ENABLE 0\r\n"                          # ★ 关编码器

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
log = logging.getLogger(__name__)


def drain(s, wait=0.5):
    """把缓冲里的东西读出来（key_scan 每秒会主动推 ~6 条 GET_LOC1）"""
    buf, t0 = b"", time.time()
    while time.time() - t0 < wait:
        try:
            d = s.recv(1024)
        except socket.timeout:
            break
        if not d:
            break
        buf += d
    return buf


def main():
    log.info("启动客户端，目标 %s:%d", HOST, PORT)
    while True:                                  # 外层：断线就重连
        try:
            with socket.create_connection((HOST, PORT), timeout=5) as s:
                s.settimeout(2)

                # ★ 连接后第一件事：关编码器（无编码器的板子必须）
                s.sendall(ENC_OFF)
                ack = drain(s, 0.8)
                log.info("关编码器: %r", ack.strip() or b"(no reply)")

                log.info("已连接，开始点动")
                try:
                    while True:
                        s.sendall(START)         # 启动（其实发一次就够，这里保留原逻辑）
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