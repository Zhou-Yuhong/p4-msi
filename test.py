import time
import threading
import sys
from scapy.all import *
# global variable
REQUEST_TYPE_FIRST_READ = 0
REQUEST_TYPE_FIRST_WRITE = 1 
REQUEST_TYPE_SECOND_READ = 2 
REQUEST_TYPE_SECOND_WRITE = 3
NODE_ID_0 = 1
NODE_ID_1 = 2
NODE_ID_2 = 4
NODE_ID_3 = 8
ETH_SRC = "ab:ab:ab:ab:ab:ab"
ETH_DST = "12:12:12:12:12:12"
ETH_TYPE = 0x1234
VETH = "veth0"
# R-read, W-write N - none(do nothing) 
NODE0_OPTIONS = ["R", "W", "N"] 
NODE0_INDEXES = [0, 0, 0]
NODE1_OPTIONS = ["W", "R", "R"]
NODE1_INDEXES = [0, 0, 0]
NODE2_OPTIONS = ["R", "R", "N"]
NODE2_INDEXES = [0, 0, 0]
NODE3_OPTIONS = ["R", "R", "R"]
NODE3_INDEXES = [0, 0, 0]
class RequestHeader(Packet):
    name = "RequestHeader"
    fields_desc = [
        BitField("node_id", 1, 4),
        BitField("index", 0, 32),
        BitField("requestType", 0, 4),
        BitField("miss_type", 0, 4),
        BitField("padding", 0, 4)
    ]

class StateEntryHeader0(Packet):
    name = "StateEntryHeader0"
    fields_desc = [
        BitField("requestType", 0, 4),
        BitField("cur_state", 0, 4) ,
        BitField("next_state", 0, 4),
        BitField("padding", 0, 4)
    ]   

class StateEntryHeader1(Packet):
    name = "StateEntryHeader1"
    fields_desc = [
        BitField("requestType", 0, 4),
        BitField("cur_state", 0, 4) ,
        BitField("next_state", 0, 4),
        BitField("padding", 0, 4)
    ]

class StateEntryHeader2(Packet):
    name = "StateEntryHeader2"
    fields_desc = [
        BitField("requestType", 0, 4),
        BitField("cur_state", 0, 4) ,
        BitField("next_state", 0, 4),
        BitField("padding", 0, 4)
    ]

class StateEntryHeader3(Packet):
    name = "StateEntryHeader3"
    fields_desc = [
        BitField("requestType", 0, 4),
        BitField("cur_state", 0, 4) ,
        BitField("next_state", 0, 4),
        BitField("padding", 0, 4)
    ]

def translate(option):
    if option == "R":
        return 0
    if option == "W":
        return 1           
class Client0(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
    def run(self):
        for i in range(0, len(NODE0_OPTIONS)):
            option = NODE0_OPTIONS[i]
            index = NODE0_INDEXES[i]
            if option == "N":
                continue
            packet = Ether(src = ETH_SRC, dst = ETH_DST, type = ETH_TYPE)/RequestHeader(node_id = NODE_ID_0, index = index, requestType = translate(option))/StateEntryHeader0()/StateEntryHeader1()/StateEntryHeader2()/StateEntryHeader3()
            sendp(packet, iface = VETH)
            time.sleep(0.1)

class Client1(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
    def run(self):
        for i in range(0, len(NODE1_OPTIONS)):
            option = NODE1_OPTIONS[i]
            index = NODE1_INDEXES[i]
            if option == "N":
                continue
            packet = Ether(src = ETH_SRC, dst = ETH_DST, type = ETH_TYPE)/RequestHeader(node_id = NODE_ID_1, index = index, requestType = translate(option))/StateEntryHeader0()/StateEntryHeader1()/StateEntryHeader2()/StateEntryHeader3()
            sendp(packet, iface = VETH)
            time.sleep(0.1)            

class Client2(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
    def run(self):
        for i in range(0, len(NODE2_OPTIONS)):
            option = NODE2_OPTIONS[i]
            index = NODE2_INDEXES[i]
            if option == "N":
                continue
            packet = Ether(src = ETH_SRC, dst = ETH_DST, type = ETH_TYPE)/RequestHeader(node_id = NODE_ID_2, index = index, requestType = translate(option))/StateEntryHeader0()/StateEntryHeader1()/StateEntryHeader2()/StateEntryHeader3()
            sendp(packet, iface = VETH)
            time.sleep(0.1)

class Client3(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
    def run(self):
        for i in range(0, len(NODE3_OPTIONS)):
            option = NODE3_OPTIONS[i]
            index = NODE3_INDEXES[i]
            if option == "N":
                continue
            packet = Ether(src = ETH_SRC, dst = ETH_DST, type = ETH_TYPE)/RequestHeader(node_id = NODE_ID_3, index = index, requestType = translate(option))/StateEntryHeader0()/StateEntryHeader1()/StateEntryHeader2()/StateEntryHeader3()
            sendp(packet, iface = VETH)
            time.sleep(0.1)        


if __name__=='__main__':
    client0 = Client0()
    client1 = Client1()
    client2 = Client2()
    client3 = Client3()
    client0.start()
    time.sleep(0.01)
    client1.start()
    time.sleep(0.02)
    client2.start()
    time.sleep(0.03)
    client3.start()
    