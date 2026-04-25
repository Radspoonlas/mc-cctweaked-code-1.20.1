
print(turtle.getFuelLevel(),"/",turtle.getFuelLimit())
local modems={peripheral.find("modem")}
print("found: ",#modems," modems!")
local modem
for i,m in ipairs(modems) do
    if m.isWireless() then
        modem=m
        break
    end
end
if modem then
    print("found wireless modem: ",modem)
end
local monitors={peripheral.find("monitor")}
print("found: ",#monitors," monitors!")
local monitor
for i,mon in ipairs(monitors) do
    print(mon)
    monitor=mon
end
print("clock:",os.clock)
print("time: ",os.time())
print("date: ",os.date())