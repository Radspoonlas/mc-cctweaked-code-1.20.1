local args={...}
if not args[1] then
    print("missing item name try:")
    print("pocketCraftItem <item> <count>")
    return
end
if not args[2] then
    print("missing count try:")
    print("pocketCraftItem <item> <count>")
    return
end

local craftingChannel=22063
local myChannel=2206
local modem=peripheral.find("modem") or error("no modem attached...",0)
modem.open(myChannel)

local function wait_for_sleep()
    os.sleep(5)
    return
end
local function wait_for_reply()
    local event, side, channel, replyChannel, message, distance=os.pullEvent("modem_message")
    if message.reply then
        print(message.reply)
        return
    else
        wait_for_reply()
    end
    
end
local function sendCraftingrequest(item,amount)
    modem.open(craftingChannel)
    modem.transmit(craftingChannel,myChannel,{name=item,count=amount})
    print("sent message")
    modem.close(craftingChannel)
    parallel.waitForAny(wait_for_reply,wait_for_sleep)
    return
end
sendCraftingrequest("minecraft:"..args[1],tonumber(args[2]))
