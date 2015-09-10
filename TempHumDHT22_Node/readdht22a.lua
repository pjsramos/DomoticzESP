PIN = 1 --  data pin, GPIO2

dht22 = require("dht22a")
dht22.read(PIN)
t = dht22.getTemperature()
h = dht22.getHumidity()

if h == nil then
  print("Error reading from DHT22")
else
  -- temperature in degrees Celsius  and Farenheit
  -- floating point and integer version:
  print("Temperature: "..((t-(t % 10)) / 10).."."..(t % 10).." deg C")

  -- humidity
  -- floating point and integer version
  print("Humidity: "..((h - (h % 10)) / 10).."."..(h % 10).."%")
end

-- release module
dht22 = nil
package.loaded["dht22a"]=nil