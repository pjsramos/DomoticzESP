
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

init_i2c_display()

m=mqtt.Client("displaynode1",60,"","")

m_dis={}
function dispatch(m,t,pl)
	if pl~=nil and m_dis[t] then
		m_dis[t](m,pl)
	end
end

m_dis["/domoticz/out/device/displaynode1"]=topic1func

m:on("connect",function(m) 
	print("connection "..node.heap()) 
	m:subscribe("/domoticz/out/device/displaynode1",0,function(m) print("sub done") end)
	end )
m:on("offline", function(conn)
    print("disconnect to broker...")
    print(node.heap())
end)

function topic1func(m,pl)
	print("get1: "..pl)
	local pack = cjson.decode(pl)
	if pack.content then
		disp:drawStr(0,0 * 11," ... ")
        
		print("data received")
        		 
		 disp:firstPage()

		 repeat
			line = 1
			
			disp:drawStr(0,(line-1) * 11,pack.line1)
			
			--for k,v in pairs(query_data) do
			--	print(k.."="..v)
			--	disp:drawStr(0,(k-1) * 11,v)
			--	lines=lines+1
			--end
			
		 until disp:nextPage() == false
		 end
	
	end

m:on("message",dispatch )

m:connect("rpiserver",1883,0,1)

