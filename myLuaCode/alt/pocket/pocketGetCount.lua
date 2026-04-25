local args={...}
local myChannel=2206
local storageChannel=22065
if not args[1] then
    print("no arguments given")
end
local name="minecraft:" .. args[1]
local modem=peripheral.find("modem") or error("no modem",0)
modem.open(myChannel)

local function wait_for_sleep()
    os.sleep(5)
    print("timeout")
    return
end
local function wait_for_reply()
    local event, side, channel, replyChannel, message, distance=os.pullEvent("modem_message")
    print("got reply")
    for i,v in pairs(message) do
        print(i,v)
    end
    if message.count then
        print(message.count)
        return
    else
        if message.error then
            print(message.error)
            return
        end
    end
    wait_for_reply()
end
modem.open(storageChannel)
modem.transmit(storageChannel,myChannel,{cmd="getCount",name=name})
parallel.waitForAny(wait_for_reply,wait_for_sleep)
modem.close(storageChannel)
