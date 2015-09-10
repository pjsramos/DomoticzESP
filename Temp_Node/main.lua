-- Starts the module and connect to server. 
print("ds18b20 Domoticz v0.1")

-- variables
--local ds18b20 = 
require('ds18b20')
local deviceID = "7"
local server_ip = "192.168.1.110"
local server_port = 8080
local seconds = 10
local pin=3 --GPIO #0


ds18b20.setup(pin)

ds18b20.read()

tmr.alarm(0, 1000 * seconds, 1, function()
	-- local temperature= ds18b20.read()
    -- print("got "..temperature)
		initSocketAndTransmitData()
	end
)


-- initializes the connection with the DOmoticz server and sends the current data.
-- Once data is sent and an answer is recieved, either restart the node or go into deep sleep
-- (depends on what's the answer from Domoticz)
function initSocketAndTransmitData()
    local socket = net.createConnection(net.TCP, 0)
    socket:connect(server_port, server_ip)
    
    --once we're connected, send the data
    socket:on("connection", function(conn)
        print("Connected to Domoticz")
        sendStatus(socket)
    end)

    -- once we get an answer from Domoticz, either:
    -- go into deep sleep if the command succeeded
    -- restart the node (and send another packet immediatly) if there was an error
    socket:on("receive", function(conn, message)
        if string.match(message, "\"status\" : \"OK\",") then
            print ("Got OK, going to sleep for a while now")
        else
            print ("Got something else: "..message)
            -- node.restart()
        end
    end)


end


-- sends the sensor data (temperature and humidity) to the Domoticz server.
function sendStatus(socket)
	
    local temperature= ds18b20.read()
    print("got "..temperature)
    local json = "GET /json.htm?type=command&param=udevice&idx="..deviceID..
                "&nvalue=0&svalue="..temperature..
                ";0 HTTP/1.1\r\nHost: www.local.lan\r\n"
                .."Connection: keep-alive\r\nAccept: */*\r\n\r\n"
    socket:send(json)
end

