# -*-coding: utf-8-*-
__author__ = 'mty'

import threading
import socket


class SocketServer(threading.Thread):
    def __init__(self, host, port, message, semaphore):
        threading.Thread.__init__(self)
        self.host = host
        self.port = port
        self.connection = None
        self.address = None
        self.message = message
        self.semaphore = semaphore

    def run(self):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind((self.host, self.port))
        sock.listen(1)
        self.connection, self.address = sock.accept()
        while True:
            try:
                data = self.connection.recv(4096)
            except socket.error:
                break
            self.semaphore.acquire()
            self.message += data
            self.semaphore.release()

    def send_message(self, message):
        self.connection.send(message)