
local modem
local modems={peripheral.find("modem")}
for i,v in pairs(modems) do
    if v.isWireless() then
        modem=v
    end
end

modem.open(2206)
modem.open(22066)
modem.open(22065)
modem.open(22067)
modem.open(22068)
modem.open(22069)
modem.open(22061)
modem.open(22063)

while true do
    local event, side, channel, replyChannel, message, distance=os.pullEvent("modem_message")
    for i,item in pairs(message) do
        print(i," : ", item)
    end

end

local itemList=msg.list
print(itemList)