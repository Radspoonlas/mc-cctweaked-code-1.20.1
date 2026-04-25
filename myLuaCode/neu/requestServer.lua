local modem=peripheral.find("modem")
local monitor=peripheral.find("monitor")
local storageChannel=22065
local ovenChannel=22063
local monitorChannel=22068
local serverChannel=22061
local pocketChannel=2206
--local gpsChannel=65534
local craftingTurtle=22069
local messageList={}
local itemList
if not modem then
    print("missing modem")
    return
end
if not monitor then
    print("no monitor attached")
end
modem.open(serverChannel)


local function wait_for_messages()
    local counter=1
    while messageList[counter] do
        counter=counter+1
    end
    messageList[counter]={os.pullEvent "modem_message"},os.clock()
    local event, side, channel, replyChannel, message, distance,time=messageList[counter]
    print("got message:",message[1]," at: ",os.clock())
end


local function requestSmelting(itemName,itemCount)
    print("gotSmeltingRequest")
    modem.open(ovenChannel)
    modem.transmit(ovenChannel,serverChannel,{itemName,itemCount})
    modem.close(ovenChannel)
end

local function requestCrafting(itemName,itemCount)
    print("got Craftingrequest")
    modem.open(craftingTurtle)
    modem.transmit(craftingTurtle,serverChannel,{itemName,itemCount})
    modem.close(craftingTurtle)
end
local function requestGetItemCount(itemName)
    print("got itemCountrequest")
    modem.open(storageChannel)
    modem.transmit(storageChannel,serverChannel,{'getItemCount',itemName})
    modem.close(storageChannel)
    return message
end

local function requestSortItem(inventory,slot)
    print("got sortrequest")
    modem.open(storageChannel)
    modem.transmit(storageChannel,serverChannel,{'push',inventory,slot})
    modem.close(storageChannel)
    return true
end

local function requestItem(replyChannel,itemName,itemCount,toInv,toSlot)
    print("got itemrequest")
    modem.open(storageChannel)
    modem.transmit(storageChannel,serverChannel,{cmd='pull',inventory=toInv,slot=toSlot,name=itemName,count=itemCount})
    modem.close(storageChannel)
    return true
end

local function checkLifetime( ... )
    local currentTime=os.clock()
    for i,v in ipairs(messageList) do
        if messageList[i].TTL<currentTime-10 then
            modem.transmit(messageList[i].replyChannel,42,{"message_died"})
            messageList[i]=nil
        end
    end
    return true
end
local function updateMonitor(itemList)
    print("got itemList update")
    modem.open(monitorChannel)
    modem.transmit(monitorChannel,serverChannel,{list=itemList})
    modem.close(monitorChannel)
    return true
end

local function wait_for_sleep()
    os.sleep(10)
    return
end
local function requestItemList()
    print("getting itemList...")
    modem.open(monitorChannel)
    modem.transmit(storageChannel,serverChannel,{"itemList"})
    modem.close(monitorChannel)
end

local function work_list()
    for i,Event in ipairs(messageList) do
        local event, side, channel, replyChannel, message, distance=table.unpack(Event)
        if channel==ovenChannel then
            if message[1]=="push" then  --anweisung
            elseif message[1]=="pull" then
                local inventory,slot,itemName,itemCount=table.unpack(message)
                requestItem(replyChannel,itemName,itemCount,inventory,slot)
            elseif message[1]=="getItemCount" then
                requestGetItemCount(message[2])  
            end
        elseif channel==storageChannel then
            if message[1]=="itemList" then  --anweisung
                updateMonitor(message.list())
            end
        elseif channel==pocketChannel then
            if message[1]=="smelting" then
                local itemName,itemCount=message[2],message[3]
                requestSmelting(itemName,itemCount)
            elseif message[1]=="crafting" then
                local itemName,itemCount=message[2],message[3]
                requestCrafting(itemName,itemCount)
            elseif message[1]=="getItemCount" then
                requestGetItemCount(message[2])
            end
        end
        messageList[i]=nil
    end
end
print("starting server")
while true do
    parallel.waitForAll(wait_for_messages,work_list,checkLifetime)
end