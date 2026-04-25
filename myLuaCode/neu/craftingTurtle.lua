local messageInv="minecraft:trapped_chest_0"
local myChannel=22063
local storageChannel=22065
local modem=peripheral.find("modem") or error
modem.open(myChannel)

local grid={5,6,7,9,10,11,13,14,15}
local standardPlank="minecraft:bamboo_plank"

local chest=peripheral.find("minecraft:trapped_chest") or error
local function plank()
    return standardPlank
end
local craftables={
    ["minecraft:stick"]={plank(),"nil","nil",plank(),"nil","nil","nil","nil","nil"},
    ["minecraft:dried_kelp_block"]={"minecraft:dried_kelp","minecraft:dried_kelp","minecraft:dried_kelp","minecraft:dried_kelp","minecraft:dried_kelp","minecraft:dried_kelp","minecraft:dried_kelp","minecraft:dried_kelp","minecraft:dried_kelp",},
    ["minecraft:modem"]={"minecraft:stone","minecraft:stone","minecraft:stone","minecraft:stone","minecraft:redstone","minecraft:stone","minecraft:stone","minecraft:stone"},
    ["minecraft:bamboo_block"]={"minecraft:bamboo","minecraft:bamboo","minecraft:bamboo","minecraft:bamboo","minecraft:bamboo","minecraft:bamboo","minecraft:bamboo","minecraft:bamboo","minecraft:bamboo"},
    ["minecraft:bamboo_plank"]={"minecraft:bamboo_block","nil","nil","nil","nil","nil","nil","nil","nil"}
}
local function inventoryIsEmpty()
    for i=1,16 do
        local _,info=turtle.getItemDetail(i)
        if info then
            return false
        end
    end
    return true
end


local function emptyInventory()
    local pos=turtle.getSelectedSlot()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            turtle.select(i)
            turtle.dropDown(64)
        end
    end
    turtle.select(pos)
    return true
end

local function getNextEmptySlot(slot)
    for i=slot or 1,16 do
        local _,info=turtle.getItemDetail(i)
        if not info then
            return i
        end
    end
end

local function selectItem(itemName)
    for slot=1,16 do
        local _,info=turtle.getItemDetail(slot)
        if info and info.name==itemName then
            turtle.select(slot)
            return true
        end
    end
    return false
end

local timeout=false
local function wait_for_sleep()
    os.sleep(60)
    print("got no reply, trying again")
    timeout=true
    return
end

local function wait_for_reply()
    local event, side, channel, replyChannel, message, distance=os.pullEvent("modem_message")
    if replyChannel==storageChannel then
        if message.reply then
            print(message.reply)
        else
            print(message.error)
        end
    end
    return message
end

local function checkMaterials(itemMap)
    local requiredMaterials={}
    for i,v in itemMap do
        if not requiredMaterials[i] then
            requiredMaterials[i]=1
        else
            requiredMaterials[i]=requiredMaterials[i]+1
        end
    end
    for i=1,16 do
        local materialcnt=0
        if turtle.getItemDetail(i) then
            for j,v in pairs(itemMap) do
                if turtle.getItemDetail().name==j then
                    materialcnt=materialcnt+1
                end
            end
            if materialcnt<requiredMaterials[turtle.getItemDetail(i).name] then
                return false
            end
        end
    end
    return true
end

local function requestMaterials(itemMap)
    assert(type(itemMap)=="table")
    local items={}
    for i,itemName in pairs(itemMap) do
        if not items[itemName] then
            items[itemName]=1
        else
            items[itemName]=1+items[itemName]
        end
    end
    for item,count in pairs(items) do
        modem.open(storageChannel)
        modem.transmit(storageChannel,myChannel,{cmd="getCount",name=item})
        modem.close(storageChannel)
        local message
        repeat message=(wait_for_reply())
        until message.cmd=="getCount"
        if message.count<count then
            return false,item
        end
        modem.open(storageChannel)
        modem.transmit(storageChannel,myChannel,{cmd="pushRequest",name=itemName,inventory=messageInv,count=1})
        modem.close(storageChannel)
        print("send request for:",item)
        parallel.waitForAny(wait_for_reply,wait_for_sleep)
        if timeout then
            error("request failed")
        end
    end
    return true
end



local function craftItem(itemName)
    turtle.select(1)
    print(itemName)
    assert(type(itemName=="string"))
    
    assert(type(craftables[itemName])=="table")
    repeat local suc,missingItem=requestMaterials(craftables[itemName])
        if not suc then
            print(suc,missingItem)
            if not craftItem(missingItem) then
                return false
            end
        end
    until suc

    for i=1,9 do
        local cnt=turtle.suckDown()
        if not cnt then
            break
        end
    end
    checkMaterials(craftables[itemName])
    local slot=0
    for item,v in pairs(craftables[itemName]) do
        slot=slot+1
        for i=1,16 do
            if turtle.getItemDetail(i) and turtle.getItemDetail(i).name then
                if turtle.getItemDetail(grid[slot]) then
                    turtle.select(grid[slot])
                    turtle.transferTo(getNextEmptySlot(grid[slot]))
                end
                turtle.select(i)
                turtle.transferTo(grid[slot])
                break
            end
        end
    end
    turtle.craft(1)
    emptyInventory()
    modem.transmit(storageChannel,myChannel,{cmd="sortItem",inventory=messageInv,slot=1})
    return true
end

local function replyInvalidMessage(channel)
    modem.transmit(channel,myChannel,{cmd="craftItem",reply=false,error="illegalArguments"})
    print("sentDeny")
end

local function expectingRequest()
    print("waiting for message...")
    local Event={os.pullEvent("modem_message")}
    local event, side, channel, replyChannel, message, distance=table.unpack(Event)
    if message.cmd and message.name then
        print("got Event:",event,"side", side,"channel", channel,"replyChannel", replyChannel,"messagecmd:", message.cmd,"item:", message.name,"distance", distance)
        return Event
    else
        print("got invalid message")
        replyInvalidMessage(replyChannel)
        return nil
    end
end


local function acceptJob(channel)
    modem.transmit(channel,myChannel,{cmd="craftItem",reply=true,'craftingJobAccepted'})
    print("sentAccept")
end

local function checkForKnownRecipy(message)
    for itemName,itemMap in pairs(craftables) do
        if itemName==message.name then
            return true
        end
    end
    return false
end

local function lockMaterials(storageChannel)
    modem.transmit(storageChannel,myChannel,{cmd="lockMaterial",name=itemName})
end
local function sendMsg(channel,msg)
    modem.transmit(channel,myChannel,msg)
end
local function startProcess(Event)
    local event, side, channel, replyChannel, message, distance=table.unpack(Event)
    for i=1,message.count do
        local crafted,craftError=craftItem(message.name)
        if craftError then
            sendMsg(replyChannel,{cmd=message.cmd,reply=false,error=craftError})
        end
    end
    sendMsg(replyChannel,{cmd=message.cmd,reply=true,msg="success"})
end
emptyInventory()
while true do
    Event=expectingRequest()
    if Event then
        local event, side, channel, replyChannel, message, distance=table.unpack(Event)
        if checkForKnownRecipy(message) then
            acceptJob(replyChannel)
            startProcess(Event)
        end
    end
end