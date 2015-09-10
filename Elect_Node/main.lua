local pin = 1

local min_pw_ms = 250
local upload_rate = 60

local pulse_detected = 0
local timestamp = 0
local counter = 0
local watts = 0

local deviceID = "8"
local server_ip = "192.168.1.110"
local server_port = 8080

gpio.mode(pin, gpio.INT)


function initSocketAndTransmitData()

    socket = net.createConnection(net.TCP, 0)
    socket:connect(server_port, server_ip)
   
    socket:on("connection", function(conn)
		tmr.wdclr()
        print("Connected to Domoticz")
        sendStatus(socket)
    end)

    socket:on("receive", function(conn, message)
        if string.match(message, "\"status\" : \"OK\",") then
			tmr.wdclr()
			counter=0
            print ("Got OK, going to sleep for a while now")
        else
			tmr.wdclr()
            print ("Got something else: "..message)
            -- node.restart()
        end
    end)


end

function sendStatus(socket)
   
    local json = "GET /json.htm?type=command&param=udevice&idx="..deviceID..
                "&nvalue=0&svalue="..watts..
                ";0 HTTP/1.1\r\nHost: www.local.lan\r\n"
                .."Connection: keep-alive\r\nAccept: */*\r\n\r\n"
    socket:send(json)
	tmr.wdclr()
end


function pin1up(level)
 pulse_detected = 1
end

function maintask()
        print("Counter is:"..counter)
		
		watts = counter*60
		print("Watts is:"..watts)
    
            --gpio.write(led, gpio.HIGH)
            print("Uploading to server...")
            initSocketAndTransmitData()
			
end

function pulsetask()
 timestamp = timestamp + 1
 if pulse_detected == 1 then
 print("pulse="..counter)
  counter = counter + 1
  pulse_detected = 0
 end
end

gpio.trig(pin, "up", pin1up)
tmr.alarm(0, upload_rate * 1000, 1, maintask);
tmr.alarm(1, min_pw_ms,      1, pulsetask);

maintask();