local args={...}
local storageChannel=22065
local localChannel=2206
local EventList={}
local modems={peripheral.find("modem")}
local modem
local itemList={}
for i,m in ipairs(modems) do
    if m.isWireless() then
        modem=m
        print("found modem...")
    end
end
local expect=require "cc.expect"
local completion = require "cc.completion"
local cmdHistory={"get","sort","getCount"}
local itemHistory={}
local countHistory={"1"}
local countChoices={}
local itemChoices={}
local cmdChoices={"get","sort","monitor","getCount"}
local cmd={"get","sort","getCount"}

local function sendGetItemRequest(itemName,itemCount)
    modem.open(storageChannel)
    modem.open(localChannel)
    modem.transmit(storageChannel,localChannel,{cmd="getItem",name=itemName,count=itemCount})
    modem.close(storageChannel)

    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    modem.close(localChannel)
    if message.error then
        print( message.error)
        return false
    else
        print(message.reply)
        return true
    end
end
local function sendGetCountRequest(itemName)
    modem.open(storageChannel)
    modem.open(localChannel)
    modem.transmit(storageChannel,localChannel,{cmd="getCount",name=itemName})
    modem.close(storageChannel)

    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    modem.close(localChannel)
    if message.error then
        print( message.error)
        return false
    else
        print(message.count)
        return true
    end
end
local function sendSortRequest()
    modem.open(storageChannel)
    modem.open(localChannel)
    modem.transmit(storageChannel,localChannel,{cmd="sortItem",name=itemName,count=itemCount})
    modem.close(storageChannel)

    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    modem.close(localChannel)
    if message.error then
        print( message.error)
        return false
    else
        print(message.reply)
        return true
    end
end

local function updateHistory(history,msg)
    table.insert(history,msg)
end

local function makeChoice(arg,item)
    if arg=="cmd" then
        local cmdChoices={}
        for i,command in pairs(cmd) do
            table.insert(cmdChoices,(command))
        end
        return
    elseif arg=="item" then
        for i,itemName in pairs(itemList) do
            table.insert(itemChoices,(string.gsub(i,"minecraft:","")))
            table.sort(itemChoices)
        end
        return
    elseif arg=="count" then
        if item then
            if itemList[item]>64 then
                countChoices={"1","64",tostring(itemList[item])}
            elseif itemList[item]>32 then
                countChoices={"1","32",tostring(itemList[item])}
            elseif itemList[item]>16 then
                countChoices={"1","16",tostring(itemList[item])}
            end
        end
        return
    end
end

local function sendItemListRequest()
    modem.open(storageChannel)
    modem.open(localChannel)
    while true do
        modem.transmit(storageChannel,localChannel,{cmd="itemList"})
        os.sleep(5)
    end
end
local function receiveItemList()
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    while not message.list do
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        print(channel,message,distance)
    end
    itemList=message.list
    print("gotItemList")
    modem.close(storageChannel)
    modem.close(localChannel)
    return true
end
local function wait_for_input()
    --term.clear()
    --term.setCursorPos(1,1)
    print("Gib ein Kommando ein:")
    term.write("> ")
    makeChoice("cmd")
    local msg=read(nil,cmdHistory,function(text) return completion.choice(text,cmdChoices) end,nil)
    local command=msg
    updateHistory(cmdHistory,command)
    if command=="sort" then
        sendSortRequest()
        return
    end
    print("Gib ein Item ein:")
    term.write("> ")
    makeChoice("item")
    msg=read(nil,itemHistory,function(text) return completion.choice(text,itemChoices)end,nil)
    local item=msg
    item="minecraft:"..item
    if command=="getCount" then
        updateHistory(itemHistory,item)
        sendGetCountRequest(item)
        return
    end
    print("Gib eine Anzahl ein:")
    term.write("> ")
    makeChoice("count")
    msg=read(nil,countHistory,function(text) return completion.choice(text,countChoices)end,nil)
    local itemCount=msg
    if command=="get" then
        sendGetItemRequest(item,itemCount)
    end
end
parallel.waitForAny(sendItemListRequest,receiveItemList)
while true do
    wait_for_input()
end