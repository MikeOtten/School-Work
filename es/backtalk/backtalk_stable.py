from luma.core.interface.serial import spi, noop
from luma.core.render import canvas
from luma.led_matrix.device import max7219
from luma.core.legacy import text, show_message
from luma.core.legacy.font import proportional
from luma.core.virtual import viewport
from PIL import ImageFont
import time
from bluetooth import *

PORT = 8051

def btsetup():
    server_sock=BluetoothSocket( RFCOMM )
    server_sock.bind(("",PORT))
    server_sock.listen(1)
 
    port = server_sock.getsockname()[1]
 
    uuid="e8c72146-d376-4a86-8267-1a721d07fa57"
 
    advertise_service( server_sock, "Backtalk_the_Magnificent",
                    service_id = uuid,
                    service_classes = [ uuid, SERIAL_PORT_CLASS ],
                    profiles = [ SERIAL_PORT_PROFILE ], 
    #                   protocols = [ OBEX_UUID ] 
                        )
                     
    print("Waiting for connection on RFCOMM channel %d" % port)
 
    client_sock, client_info = server_sock.accept()
    print("Accepted connection from ", client_info)
 
    try:
        while True:
            data = client_sock.recv(1024)
            if len(data) == 0: break
            print("received [%s]" % data)
    except IOError:
        pass
 
    #print("disconnected")
 
    #client_sock.close()
    #server_sock.close()

def cleanup():
    print("disconnected")
 
    client_sock.close()
    server_sock.close()

def getmsg():
    try:
        msg = client_sock.recv(1024)
        if (len(msg) != 0):return msg
        return ""
    except IOError:
        pass


def display(msg):
    serial = spi(port=0, device=0, gpio=noop())
    device = max7219(serial,height=16,width=96,block_orientation=-90)
    myFont = ImageFont.truetype("pixelmix.ttf", 16)
    #msg="            Hello World!!!"
    virtual = viewport(device, width=myFont.getsize(msg)[0]+192, height=device.height) #192 = 96 *2
    
    with canvas(virtual) as draw:
        draw.rectangle(device.bounding_box, outline="black", fill="black")
        draw.text((96,-1),msg,fill="white",font=myFont)
    
    try:
        for x in range(virtual.width-device.width):
                virtual.set_position((x, 0))
                time.sleep(0.1)
    except KeyboardInterrupt:
        pass
    
    #https://luma-led-matrix.readthedocs.io/en/latest/

btsetup()
ot = time.time()
print("Finished setup")
while(True):
    if(time.time() - ot>=30):
        ot = time.time()
        msg = getmsg()
        if(len(msg) != 0):display(msg)
cleanup()

 
