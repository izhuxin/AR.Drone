__author__ = 'mty'

from socketModel import SocketServer
import time

s = SocketServer('', 8080)
s.start()
time.sleep(10)
s.send_message('test')