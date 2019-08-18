import bluetooth

PORT = 8051

def test():
    server_sock=BluetoothSocket( RFCOMM )
    server_sock.bind(("",PORT))
    server_sock.listen(1)

    port = server_sock.getsockname()[1]

    uuid = "94f39d29-7d6d-437d-973b-fba39e49d4ee"

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

    print("disconnected")

    client_sock.close()
    server_sock.close()


test()