--startup.lua
--shell.execute "interface"
require "storage.lua"
require "ofen.lua"

function init()
    --storage init
end

function selectItem()
    --showItemList of available items
    --scroll
    --/stringinput
end

function selectAmount()
    -- +1,+2+4+8+16+32+64+128+256+516+1024+2048
    -- num
    -- -1 -2 -4 -8 ...

    --/ numberinput
end

function selectFunction()
    --push,pull,smelt
end

function default()

end

function showOvenProgress()
    
end

init()
local modem = peripheral.find("modem") or error("No modem attached", 0)
modem.open(3)
while true do
    
end