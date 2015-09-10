--init.lua, something like this
print("Will run main.lc/main.lua in 5000ms")
tmr.alarm(0,5000,1,function()
  tmr.stop(0)
  local s,err
  if file.open("main.lc") then
    file.close()
    s,err = pcall(function() dofile("main.lc") end)
  else
    s,err = pcall(function() dofile("main.lua") end)
  end
  if not s then print(err) end
end)