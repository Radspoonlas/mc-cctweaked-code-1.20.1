local args={...}
local myChannel=2206
local storageChannel=22065
if not args[1] then
    print("no arguments given")
end
local name="minecraft:" .. args[1]
local count=1
if args[2] then
    count=tonumber(args[2])
end
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
    if replyChannel==storageChannel then
        if message.reply then
            print(message.reply)
            return
        else
            if message.error then
                print(message.error)
                return
            end
        end
    end
    wait_for_reply()
end
modem.open(storageChannel)
modem.transmit(storageChannel,myChannel,{cmd="getItem",name=name,count=count})
parallel.waitForAny(wait_for_reply,wait_for_sleep)
modem.close(storageChannel)


