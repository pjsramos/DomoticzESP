
pin = 1

local query_data

local recv_lines

-- setup I2c and connect display
function init_i2c_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     sda = 5 -- GPIO14
     scl = 6 -- GPIO12 
     sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
	 disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end


local function connect (conn, data)
   

   conn:on ("receive",
      function (cn, req_data)
		disp:drawStr(0,0 * 11," ... ")
        query_data = get_http_req (req_data)
		print("data received")
        cn:send ("Hello World from ESP8266 and NodeMCU!!")
         -- Close the connection for the request
		 
		 if (query_data ~= nil ) then
		 print("display")
		 disp:firstPage()

		 repeat
			lines = 0
			
			for k,v in pairs(query_data) do
				print(k.."="..v)
				disp:drawStr(0,(k-1) * 11,v)
				lines=lines+1
			end
			
		 until disp:nextPage() == false
		 end
		 cn:close ( )
      end)
end

-- Build and return a table of the http request data
function get_http_req (request)
    local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
    if(method == nil)then
         _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
    end
    local _GET = {}
		if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
				--print(k.."="..v)
            end
		else
		return nil
        end
	return _GET
end


init_i2c_display()

--disp:firstPage()
--disp:drawStr(0,0 * 11,"DISPLAY")
--disp:drawStr(0,1 * 11,"NODE")

svr = net.createServer (net.TCP, 30)

-- Server listening on port 80, call connect function if a request is received
svr:listen (80, connect)

tmr.alarm(0,5000,1,function() 
--print("timer")

--if (query_data ~= nil)then
--print("firstPage")
--disp:firstPage()

 --       print("text")
--		 repeat
		 
		
--		  print("repeat")
--			lines = 0
			
--			for k,v in pairs(query_data) do
--				print(k.."="..v)
--				disp:drawStr(0,lines * 11,k..v)
--				lines=lines+1
--			
--			end
--			
--		 until disp:nextPage() == false
--	query_data=nil	 
--end
end)