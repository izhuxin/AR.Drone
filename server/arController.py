# -*-coding: utf-8-*-
__author__ = 'mty'

import socket
import threading

from socketModel import SocketServer

IOS_PORT = 8080
ANDROID_PORT = 8081


class Controller():
    def __init__(self):
        self.ios_message = ''
        self.ios_semaphore = threading.Semaphore()
        self.ios_socket = SocketServer('', IOS_PORT, self.ios_message, self.ios_semaphore)
        self.android_message = ''
        self.android_semaphore = threading.Semaphore()
        self.android_socket = SocketServer('', ANDROID_PORT, self.android_message, self.android_semaphore)
        self.ios_socket.start()
        self.android_socket.start()

    def start(self):
        self.authentication()
        while True:
            self.android_semaphore.acquire()
            try:
                self.ios_socket.send_message(self.android_message)
                self.android_message = ''
            except socket.error:
                self.ios_socket.connection.close()
                self.ios_socket = SocketServer('', IOS_PORT, self.ios_message, self.ios_semaphore)
                self.ios_socket.start()
            self.android_semaphore.release()
            self.ios_semaphore.acquire()
            try:
                self.android_message(self.ios_message)
                self.ios_message = ''
            except socket.error:
                self.android_socket.connection.close()
                self.android_socket = SocketServer('', ANDROID_PORT, self.android_message, self.android_semaphore)
                self.android_socket.start()
                self.authentication()
            self.ios_semaphore.release()

    def authentication(self):
        self.android_socket.send_message('USR 0;')
        while True:
            self.android_semaphore.acquire()
            if 'RES' in self.android_message:
                if 'RES USR 1 androidv1 xiaomi 123456 5;' in self.android_message:
                    self.android_message = self.android_message[
                                           self.android_message.rfind('RES USR 1 androidv1 xiaomi 123456 5;') + len(
                                               'RES USR 1 androidv1 xiaomi 123456 5;'):]
                    self.android_semaphore.release()
                    self.android_socket.send_message('UES SUC 1;')
                else:
                    self.android_message = ''
                    self.android_socket.send_message('UES FIL 1;')
                break
            else:
                self.android_message = ''
                self.android_semaphore.release()