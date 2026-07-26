local args={...}
local myChannel=2206
local storageChannel=22065
if not args[1] then
    print("no arguments given")
end

local modem=peripheral.find("modem") or error("no modem",0)
modem.open(myChannel)

modem.open(storageChannel)
modem.transmit(storageChannel,myChannel,{cmd="sortChests"})
modem.close(storageChannel)
