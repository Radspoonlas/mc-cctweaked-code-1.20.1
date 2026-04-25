local localChannel=22065
local monitorChannel=22068
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
if modem then
    modem.open(localChannel)
end
local expect=require "cc.expect"
local expect, field = expect.expect, expect.field
local inventories={peripheral.find("minecraft:barrel")}
local freeSpaces={}



local function findItemPos(itemName)
    assert(1,itemName,"string")
    if itemList[itemName] then
        local values=table.remove(itemList[itemName].instances)
        return values.inventory,values.slot
    end
    return nil
end

local function makeItemList()
    print("making itemList and freeSpaces")
    local start=os.clock()
    for i,inventory in pairs(inventories) do
        for space=1,27 do
            table.insert(freeSpaces,{inventory=inventory,slot=space})
            assert(inventory ~= nil and space ~= nil )
        end
        local slotstaken={}
        for slot,item  in pairs(inventory.list()) do
            if  itemList[item.name] then
                itemList[item.name].count=item.count+itemList[item.name].count
                table.insert(itemList[item.name].instances,{inventory=inventory,slot=slot})
                assert(inventory ~= nil and slot ~= nil )
            else
                itemList[item.name]={}
                itemList[item.name].instances={}
                table.insert( itemList[item.name].instances,{inventory=inventory,slot=slot})
                assert(inventory ~= nil and slot ~= nil )
                itemList[item.name].count=item.count
                itemList[item.name].itemLimit=inventory.getItemLimit(slot)
            end
            table.insert(slotstaken,slot)
        end
        for v,slot in pairs(slotstaken) do
            for pos,value in pairs(freeSpaces) do
                if value.inventory==inventory then
                    if slot==value.slot then
                        table.remove(freeSpaces,pos)
                    end
                end
            end
        end
        term.clear()
        term.setCursorPos(1,1)
        print("openSpaces:",#freeSpaces," maxSpaces: ",i*27)
        print("inv:",i,"/",#inventories)
    end
    local timer=os.clock()
    term.clear()
    print("took: ",timer-start,"time")
    print("finishes making freespaces")
    print("openSpaces:",#freeSpaces," maxSpaces: ",#inventories*27)
    return itemList
end
local function checkinstances(itemName)
    for o,v in pairs(itemList[itemName].instances) do
        assert(v.inventory.getItemDetail(v.slot)~=nil)
    end
end

local function pullRequest(itemName,itemCount,output,toSlot)
    expect(1,itemName,"string")
    expect(2,itemCount,"number")
    if not itemList[itemName] then
        print("noSuchItem")
        return
    end
    if itemList[itemName].count==0 then
        print("no more of that item")
        return false
    end
    local space,slot=findItemPos(itemName)
    assert(space ~= nil and slot ~= nil )
    print("count",itemList[itemName].count)
    --print(space,slot)
    local pushedCount=space.pushItems(output,slot,itemCount,toSlot)
    itemList[itemName].count=itemList[itemName].count-pushedCount
    print("assert 0")
    checkinstances(itemName)
    if space.getItemDetail(slot) then
        assert(space.getItemDetail(slot)~=nil)
        print(space.getItemDetail(slot).name, space.getItemDetail(slot).count)
       table.insert(itemList[itemName].instances,{space,slot})
       checkinstances(itemName)
       assert(space ~= nil and slot ~= nil )
    end
    print("assert 1")
    checkinstances(itemName)
    if not pushedCount then
        print("couldnt push Item")
        return false
    end
    if pushedCount<itemCount then
        if pushedCount==0 then
            return false
        end
        pullRequest(itemName,itemCount-pushedCount,output,toSlot)
    end
    print("assert 2")
    checkinstances(itemName)
    return true
end


local function getItem(itemName,itemCount)
    local output={peripheral.find("minecraft:dropper")}
    if itemList[itemName] then
        if pullRequest(itemName,itemCount,peripheral.getName(output[1])) then
            return true
        end
    end
   return false
end

local function wait_for_Event()
    print("waiting for Event...")
    local Event={os.pullEvent("modem_message")}
    local n=1
    while EventList[n] do
        n=n+1
    end
    EventList[n]=Event
    --print(Event[1])
end

local function sendItemList(channel)
    modem.open(channel)
    modem.transmit(channel,localChannel,{"itemList",list=itemList})
    modem.close(channel)
end

local function sortItemSlot(inv,slot,count)
    if not count then
        count=64
    end
    local out={peripheral.find("minecraft:chest")}
    print(out)
    local pulled=out[1].pullItems(inv,slot,count)
    print(pulled)
end

local function sortItems(inputs)
    for n,inventory in pairs(inputs) do
        for slot,item in pairs(inventory.list()) do
            local pushedItems=0
            if itemList[item.name] then
                itemList[item.name].count=item.count+ itemList[item.name].count
                local foundInstance=false
                for i,values in pairs(itemList[item.name].instances) do
                    print(values.inventory,values.slot)
                    print(values.inventory.getItemDetail(values.slot))
                    if values.inventory.getItemDetail(values.slot).count<itemList[item.name].itemLimit then
                        pushedItems=inventory.pushItems(peripheral.getName(values.inventory),slot,item.count,values.slot)+pushedItems
                        if pushedItems==item.count then
                            break
                        end
                    end
                end
                if pushedItems<item.count then
                    local space=table.remove(freeSpaces)
                    inventory.pushItems(peripheral.getName(space.inventory),slot,item.count,space.slot)
                    table.insert(itemList[item.name].instances,{inventory=space.inventory,slot=space.slot})
                    assert(space.inventory~=nil and space.slot~=nil )
                end
            else
                itemList[item.name]={}
                itemList[item.name].count=item.count
                itemList[item.name].instances={}
                table.insert( itemList[item.name].instances,{inventory=inventory,slot=slot})
                assert(inventory~=nil and slot~=nil )
                itemList[item.name].itemLimit=inventory.getItemLimit(slot)
                local space=table.remove(freeSpaces)
                inventory.pushItems(peripheral.getName(space.inventory),slot,item.count,space.slot)
            end
        end
    end
end

local function sendCount(itemName,channel)
    print(itemName)
    print(next(itemList))
    if itemList[itemName] then
        print("found item")
        modem.open(channel)
        modem.transmit(channel,localChannel,{cmd="getCount",count=itemList[itemName]})
        modem.close(channel)
       return true
        
    else
        print("no such item")
        modem.open(channel)
        modem.transmit(channel,localChannel,{cmd="getCount",count=0})
        modem.close(channel)
        return true
    end
    return false
end
makeItemList()
local function wait_for_workEvent()
    print("working on EventList",math.random(10))
    for i,Event in ipairs(EventList) do
        print("at: ",i,"EventType: ",Event[1])
        if Event[1]=="modem_message" then
            local event, side, channel, replyChannel, message, distance = table.unpack(Event)
            if message.cmd=="getCount" then
                sendCount(message.name,replyChannel)
            elseif message.cmd=="sortItem" then
                sortItemSlot(message.inventory,message.slot,message.count)
            elseif message.cmd=="moveItem" then
                if pullRequest(message.name,message.count,message.inventory,message.slot) then
                    modem.open(replyChannel)
                    modem.transmit(replyChannel,localChannel,{reply=true})
                    modem.close(replyChannel)
                else
                    modem.open(replyChannel)
                    modem.transmit(replyChannel,localChannel,{reply=false,error="noSuchItem"})
                    modem.close(replyChannel)
                end
            elseif message.cmd=="getItem" then
                if getItem(message.name,message.count) then
                    modem.open(replyChannel)
                    modem.transmit(replyChannel,localChannel,{reply=true})
                    modem.close(replyChannel)
                else
                    modem.open(replyChannel)
                    modem.transmit(replyChannel,localChannel,{reply=false,error="noSuchItem"})
                    modem.close(replyChannel)
                end
            elseif message.cmd=="itemList" then
                sendItemList(replyChannel)
            end
        end
        EventList[i]=nil
    end
    os.sleep(10)
    local inputs={peripheral.find("minecraft:chest")}
    sortItems(inputs)
end

--setup fuer lagerverteilung


while true do
    parallel.waitForAny(wait_for_Event,wait_for_workEvent)
end 
