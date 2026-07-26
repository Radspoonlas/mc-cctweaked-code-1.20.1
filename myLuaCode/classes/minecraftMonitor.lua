local requests={}
local monitor
local channelMonitor
--gets default channel from systemfiles
local function getDefaultChannel()
    return settings.get(channelMonitor)
end

--handles default channel requests
local function channels(struct)
    if struct == "monitor" then
        return getDefaultChannel()
    end
end

--requests itemList
local function requestItemList(modem)
    modem.transmit(channels("storage"),channels("monitor"))
end

--this function executes message requests
local function work_message()
    while true do
        Event=requests[#requests]
        requests[#requests]=nil
        local event, side, channel, replyChannel, message, distance = table.unpack(Event)
        if channel ==  channels("monitor") then
            print(("got message: %s , at side: %s, from: %d , from: %d blocks away"):format(message,side,replyChannel,distance))

        end
        os.sleep(0)
    end
end

--waiting for messages
local function receive_message()
    while true do
        requests[#requests+1]=os.pullEvent("modem_message")
    end
end

--calls simultaniusly receive and work message
local function handleMessages()
    parallel.waitForAny(receive_message,work_message)
end


--opens channel
local function  openChannel(modem,channel)
    assert(modem)
    if not channel then
        channel=getDefaultChannel()
    end
    if modem.isOpen(channel) then
        return true
    else
        modem.open(channel)
        return true
    end
end
local function findModem()
    local modem=peripheral.find("modem")
    assert(modem)
    return modem
end

local function textColours(theme)
    if theme=="default" then
        settings.get(textColoursDefault)
    elseif theme == "waiting" then
        settings.get(textColoursWaiting)
    elseif theme == "startup" then
        settings.get(textColoursStartup)
    end
end

local function settingsSetDefault(topic,options,set)
    settings.define(topic,{description=options.description,default=options.default,type=options.type})
    if set then
        settings.set(topic,set)
    end
    
end

local function backGroundColors(theme)
    if theme=="default" then
        settings.get(backGroundDefault)
    elseif theme == "waiting" then
        settings.get(backGroundWaiting)
    elseif theme == "startup" then
        settings.get(backGroundStartup)
    end
end


local function displayWaitingForItemlist(monitor)
    setUpDisplay("waiting")
end

local function setUpDisplay(theme)
    
    backGroundColors(theme)
    textColours(theme)
end


local function checkDefaults()
    local topics={
        backGroundDefault=colors.orange,
        backGroundStartup=colors.gray,
        backGroundWaiting=colors.blue,
        textColorDefault=colors.black,
        textColorStartup=colors.black,
        textColorWaiting=colors.white,
        channelMonitor=22068,
        channelStorage=22065
    }
    local options={
        description="This is a default text, to change this text redefine setting",
        default=colors.white,
    }
    if not settings.get(backGroundDefault) then
        for i,topic in topics do
            options.default=topics[i]
            settingsSetDefault(topic, options)
        end
    end
end

local function setUpMonitor()
    monitor = peripheral.find("monitor")
    assert(monitor)
    checkDefaults()
    setUpDisplay("startup")
end

local function callFunction(myFunctions)
    parallel.waitForAny(handleMessages,table.unpack(myFunctions))
end

local function displayInterface()
    
end

local function handleMonitorInterface()
    while true do
        local event, side, x, y = os.pullEvent("monitor_touch")
    end

end

local function init()
    local itemList
    openChannel(findModem(),channels("home"))
    callFunction({setUpMonitor})
    while not itemList do
        itemList = callFunction(requestItemList)
        callFunction({function() os.sleep(10) end,displayWaitingForItemlist})
    end
    callFunction({displayInterface,handleMonitorInterface})
end
init()
