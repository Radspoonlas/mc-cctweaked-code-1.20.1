
local modem
local modems={peripheral.find("modem")}
for i,v in pairs(modems) do
    if v.isWireless() then
        modem=v
    end
end

modem.open(2206)

modem.open(22065)

modem.transmit(22065,2206,{cmd="itemList"})
local  event, side, channel, replyChannel, message, distance=os.pullEvent("modem_message")
for i,v in pairs(message) do
    print(i,v)
end
local itemList=message.list
print(itemList)
for i,item in pairs(itemList) do
    print(i," : ", item or item.name)
end