
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

tmr.alarm(0,3000,1,function() --A timer, which used to run the following program 
    wifi.sta.getap(function(t) 
         disp:firstPage()
         repeat
            lines = 0
            for k,v in pairs(t) do
                disp:drawStr(0,lines * 11,k.." "..v:sub(3,5).."dbi") --Print the data out
                lines = lines + 1
            end
        until disp:nextPage() == false
    end)
end)