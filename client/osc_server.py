import argparse
import math
import re

from pythonosc import dispatcher
from pythonosc import osc_server

from websocket import create_connection


ws = create_connection("ws://281b343a.ngrok.io/muse_socket")


# def eeg_handler(unused_addr, args, ch1, ch2, ch3, ch4):
# ws.send("EEG (uV) per channel: %s, %s, %s, %s" % (ch1, ch2, ch3, ch4))


def all_args(addr, *args):
    addr = addr.replace("/muse/elements/", "")
    ws.send(str({addr: args}))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip",
                        default="127.0.0.1",
                        help="The ip to listen on")
    parser.add_argument("--port",
                        type=int,
                        default=5000,
                        help="The port to listen on")
    args = parser.parse_args()

    dispatcher = dispatcher.Dispatcher()

    dispatcher.map("/muse/elements/*_relative", all_args)

    server = osc_server.ThreadingOSCUDPServer(
        (args.ip, args.port), dispatcher)
    print("Serving on {}".format(server.server_address))
    server.serve_forever()
