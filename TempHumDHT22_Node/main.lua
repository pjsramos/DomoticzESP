-- Starts the module and connect to server. 
print("DHT22 Domoticz v0.1")

-- variables
local pin = 1
local led = 4
--local dht22 = require("dht22")
local deviceID = "6"
local server_ip = "192.168.1.110"
local server_port = 8080
local seconds = 60

gpio.mode(led, gpio.OUTPUT)


tmr.alarm(0, 1000 * seconds, 1, function()
	gpio.write(led, 0)
	initSocketAndTransmitData()
	gpio.write(led, 1)
	--print("heap="..node.heap())
	collectgarbage();
	end
)

function initSocketAndTransmitData()
	local socket = net.createConnection(net.TCP, 0)
	socket:connect(server_port, server_ip)

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
	
	socket:on("disconnection", function(conn, message)
		--socket:close();
		--collectgarbage();
		print("disconnect")
	end)

return
end

-- sends the sensor data (temperature and humidity) to the Domoticz server.
function sendStatus(socket)
	local dht22 = require("dht22")
	dht22.read(pin)
	local t = dht22.getTemperature()
	local h = dht22.getHumidity()
	
	local temperatureAndHumidity = ((t-(t % 10)) / 10).."."..(t % 10)..";"..((h - (h % 10)) / 10).."."..(h % 10)
	
	
	
	print("got "..temperatureAndHumidity)
	local json = "GET /json.htm?type=command&param=udevice&idx="..deviceID..
				"&nvalue=0&svalue="..temperatureAndHumidity..
				";0 HTTP/1.1\r\nHost: www.local.lan\r\n"
				.."Connection: keep-alive\r\nAccept: */*\r\n\r\n"
	socket:send(json)
	
	dht22 = nil
	t=nil
	h=nil
	temperatureAndHumidity=nil
	json=nil
	package.loaded["dht22"]=nil
	return 
	
end
