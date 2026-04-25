
--dependencies:
local expect=require "cc.expect"

--fileNames (hardcoded)
--channels hardcoded
local storageChannel=22065
--inits:
local itemList={}
local freeSpaces={}
local EventList={}
local Fuel={}
local modem
local inventories={peripheral.find("minecraft:barrel")}

local totalRequests,currentRequests,deadRequests=0,0,0
expect = expect.expect
--local variables:

local defaultFuel="minecraft:bamboo_plank"
local defaultChannel=storageChannel




local function itemListUpdate(itemName,itemCount,inv,slot )
    -- body
    local inventory=inv
    if type(inv)=="string" then
        inventory=peripheral.wrap(inv)
    end
    itemList[itemName].count=itemList[itemName].count+itemCount
    if inventory.getItemDetail(slot) and inventory.getItemDetail(slot).name==itemName then
        table.insert( itemList[itemName].instances,{inventory=peripheral.getName(inventory),slot=slot})
    end
end


local function send(channel,replyChannel,contents)
    assert(type(channel)=="number")
    assert(type(replyChannel)=="number")
    assert(type(contents)=="table")
    if  modem then
        modem.open(channel)
        modem.transmit(channel,replyChannel,contents)
        modem.close(channel)
    end
end

local function newWireless()
    local modems={peripheral.find("modem")}
    for i,m in ipairs(modems) do
        if m.isWireless() then
            modem=m
            return modem
        end
    end
    return false
end
--functions:
local function overrideStorage()
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
                table.insert(itemList[item.name].instances,{inventory=peripheral.getName(inventory),slot=slot})
                assert(inventory ~= nil and slot ~= nil )
            else
                itemList[item.name]={}
                itemList[item.name].instances={}
                table.insert( itemList[item.name].instances,{inventory=peripheral.getName(inventory),slot=slot})
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
    --saveList(storageFile,itemList)
    return itemList
end

local function findItemPos(itemName)
    assert(1,itemName,"string")
    if itemList[itemName] then
        local values=table.remove(itemList[itemName].instances)
        return values
    end
    return false
end

local function sendCraftingJob(args)
    local itemName,itemCount,channel,replyChannel=args.name,args.count,args.channel,args.replyChannel
    modem.send(channel,replyChannel,{cmd="craftItem",name=itemName,count=itemCount})
end

local function pullRequest(name,cnt,inv,slot)
    expect(1,name,"string")
    expect(2,cnt,"number")
    if type(inv)=="table" then
        inv=peripheral.getName(inv)
    end
    assert(type(inv)=="string")

    local pos=table.remove( freeSpaces )
    assert(pos~=nil)
    local pulledItems=pos.inventory.pullItems(inv,slot,cnt,pos.slot)
    itemListUpdate(name,pulledItems,pos.inventory,pos.slot,pos.inventory,pos.slot)
    if not pulledItems or (pulledItems==0) then
        print(pulledItems)
        return false
    end
    if pulledItems and pulledItems<cnt then
        return pullRequest(name,cnt-pulledItems,pos.inventory,slot)
    end
    return true
end

local function pushRequest(name,cnt,inv,slot)
    expect(1,name,"string")
    expect(2,cnt,"number")
    if type(inv)=="table" then
        inv=peripheral.getName(inv)
    end
    local pos=findItemPos(name)
    if not pos then
        print("no more of that item")
        return
    end
    assert(pos~=nil)
    local inventory=peripheral.wrap(pos.inventory)
    local pushedItems=inventory.pushItems(inv,pos.slot,cnt,slot)
    itemListUpdate(name,pushedItems,inventory,pos.slot)
    if pushedItems and pushedItems<cnt then
        return pushRequest(name,cnt-pushedItems,inv,slot)
    end
    return true
end

local function moveItems(args)
    local name=args.name
    local channel=args.replyChannel
    local replyChannel=args.channel
    local count=args.count or 64
    local inventory=args.inventory
    local slot=args.slot
    pushRequest(name,count,inventory,slot)
    send(channel,replyChannel,{cmd="pushRequest",reply=true})
end



local function getItem(args)
    local name=args.name
    local count=args.count
    if pushRequest(name,count,peripheral.getName(peripheral.find("minecraft:dropper"))) then
        send(args.replyChannel,args.channel,{reply="getItem",success=true})
    end
end

local function sortInputs()
    while true do
        term.clear()
        term.setCursorPos(1,1)
        term.write("at:")
    local inputs={peripheral.find("minecraft:chest")}
    assert(#inputs>0)
    print(#inputs)
    os.sleep(1)
    for i,input in ipairs(inputs) do
        os.sleep(1)
        term.clear()
        term.setCursorPos(1,1)
        print("at inv:",i," / ",#inputs,"\n")
        for slot,item in pairs(input.list()) do
            term.clearLine()
            term.setCursorPos(2,1)
            print("slot:",slot," / ", input.size()," item: ",string.gsub(item.name,"minecraft:",""),"\n")
            local inv=peripheral.getName(input)
            assert(type(inv)=="string")
            pullRequest(item.name,item.count,inv,slot)
        end
    end
        print("doing pause")
        os.sleep(60*10)
    end
    -- body
end
local function sortItem(args)
    print("sorting item...")
    local count=args.count or 64
    local inventory=args.inventory
    local slot=args.slot
    if type(inventory)=="string" then
        inventory=peripheral.wrap(inventory)
    end
    print("inventory",inventory,"slot:",slot,"count:",count)
    if inventory and slot and inventory.getItemDetail(slot) then
        print("pulling item:",inventory.getItemDetail(slot).name)
        pullRequest(inventory.getItemDetail(slot).name,count,inventory,slot)
    elseif inventory then
        for listslot,item in pairs(inventory.list()) do
            pullRequest(item.name,item.count,inventory,listslot)
        end
    else
        local inputs={peripheral.find("minecraft:chest")}
        for i,listinventory in pairs(inputs) do
            for listslot,item in pairs(listinventory.list()) do
                pullRequest(item.name,item.count,inventory,listslot)
            end
        end
    end
    return true
end

local function sendCount(args)
    local replyChannel=args.channel
    local channel=args.replyChannel
    local name=args.name
    print(name)
    if itemList[name] then
        send(channel,replyChannel,{reply="getCount",count=itemList[name].count})
    else
        send(channel,replyChannel,{reply="getCount",count=0})
    end
    
    
end

local function getFuel(args)
    local fuelCnt=args.count
    local inv=args.inv
    assert(type(fuelCnt)=="number")
    pullRequest(defaultFuel,fuelCnt,inv,2)
end

local function sendItemList(args)
    local channel=args.channel
    assert(type(channel)=="number")
    local replyChannel=args.replyChannel
    assert(type(replyChannel)=="number")
    send(replyChannel,channel,{reply="itemList",list=itemList})
end





--functionsliste fuer den Eventhandler


local function addEvent(Event)
    table.insert(Event,os.clock())
    table.insert(EventList,Event)
    totalRequests=totalRequests+1
    currentRequests=currentRequests+1
end

local function getEvent()
    currentRequests=currentRequests-1
    return table.remove(EventList)
end

local function wait_for_Event()
    while true do
        print("waiting...")
        Event={os.pullEvent("modem_message") }
        print("gotEvent:",Event[1])
        if Event then
            addEvent(Event)
        end
        print(#EventList)
        print("did Event")
    end
end

local EventHandler={{name="pushRequest",fun=moveItems},{name="craftItem",fun=sendCraftingJob},{name="getFuel",fun=getFuel},{name="getItem",fun=getItem},{name="sortItem",fun=sortItem},{name="getCount",fun=sendCount},{name="itemList",fun=sendItemList}}
local function wait_for_workEvent()
    while true do
        if #EventList==0 then
            os.sleep(2)
            --print("waiting for work...")
        else
            Event=getEvent()
            local event, side, channel, replyChannel, message, distance = table.unpack(Event)
            print("handling Event:")
            print("msg:",message.cmd)
            for i,entry in pairs(EventHandler) do
                if entry.name==message.cmd then
                    print(entry.name)
                    print("going into function:")
                    
                    entry.fun({channel=channel,replyChannel=replyChannel,count=message.count,name=message.name,inventory=message.inventory,slot=message.slot})
                    break
                end
            end
            print("finished handling Event")
        end
    end
end




local function loadList(file)
    local list={}
    local handle=io.open(file,"r")
    assert(handle~=nil)
    function Entry(a)
        local entry={}
        for i,v in pairs(a) do
            print(i,v)
            entry[i]=v
        end
        table.insert(list,entry)
    end
    local f=loadfile(file,"t",{Entry=Entry,list=list})
    f()
    return list
end

local function serialize(o,handle)
    --aus der Lua lib:https://www.lua.org/pil/12.1.1.html
    --print(tostring(o))
    if type(o) == "number" then
        handle:write(o)
    elseif type(o) == "string" then
        handle:write(string.format("%q", o))
    elseif type(o) == "table" then
        handle:write("{\n")
        for k,v in pairs(o) do
            handle:write(" [ '", k, "' ]= ")
            serialize(v,handle)
            handle:write(",\n")
        end
        handle:write("}\n")
    else
        --print(o)
        --print(tostring(o))
        --print(type(o))
        error("cannot serialize a " .. type(o))
    end
end

local function saveList(file,list)
    print("saving list in file:")
    local handle=io.open(file,"w")
    assert(handle~=nil)
    for i,Entry in pairs(list) do
        handle:write("Entry")
        print("now serialize")
        serialize(Entry,handle)
    end
    handle:close()
    print("done saving")
end

modem=newWireless()
modem.open(storageChannel)
assert(modem~=nil)
parallel.waitForAny(wait_for_Event,overrideStorage )
--body
parallel.waitForAny(wait_for_Event,wait_for_workEvent,sortInputs)