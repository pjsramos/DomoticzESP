-- Starts the module and connect to server. 
print("ds18b20 Domoticz v0.1")

-- variables

local ds=require('ds18b20')

local deviceID = "7"
local server_ip = "192.168.1.110"
local server_port = 8080
local seconds = 60
local pin=3 --GPIO #0

ds.setup(pin)



tmr.alarm(0, 1000 * seconds, 1, function()
		initSocketAndTransmitData()
	end
)


function initSocketAndTransmitData()

print("-->readTemp()")
	
	temperature= ds.read()

	print("got "..temperature)	

    local socket = net.createConnection(net.TCP, 0)
    socket:connect(server_port, server_ip)
    print("-->connect()")
    --once we're connected, send the data
    socket:on("connection", function(conn)
        print("Connected to Domoticz")
        sendStatus(socket)
    end)

    socket:on("receive", function(conn, message)
        if string.match(message, "\"status\" : \"OK\",") then
    
			print ("Got OK, going to sleep for a while now")
        else
		
            print ("Got something else: "..message)
            -- node.restart()
        end
    end)

end


function sendStatus(socket)
    -- local temperature= readTemp()

   tmr.wdclr()
    local json = "GET /json.htm?type=command&param=udevice&idx="..deviceID..
                "&nvalue=0&svalue="..temperature..
                ";0 HTTP/1.1\r\nHost: www.local.lan\r\n"
                .."Connection: keep-alive\r\nAccept: */*\r\n\r\n"
    socket:send(json)
	tmr.wdclr()
end



