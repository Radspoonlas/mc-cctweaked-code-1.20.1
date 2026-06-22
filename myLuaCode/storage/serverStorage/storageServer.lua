
--dependencies:
local fileManager=require "fileManager"
local modem=require "modemManager"
local eventHandler=require "eventHandler"
local expect=require "cc.expect"

--fileNames (hardcoded)
local channelFile="myChannels.txt"
local EventFile="Events.txt"
local storageFile="data.txt"
local freeSpacesFile="savedSpace.txt"
--channels hardcoded
local storageChannel=22065
local serverChannel=22061
--inits:
local itemList={}
local freeSpaces={}
fileManager:new()
if not modem:newWireless() then
    print("no modem")
    return
end
local wmodem
local modems={peripheral.find("modem")}
for i,v in pairs(modems) do 
    if v.isWireless then
        wmodem=v
    end
end
print("found wirelessmodem: ",modem)
print(wmodem.isWireless)
assert(wmodem.isWireless)

--local variables:

local defaultFuel="minecraft:bamboo_plank"
local defaultChannel=storageChannel
local fuel={}

modem:openChannel(storageChannel)
local inventories={peripheral.find("minecraft:barrel")}

--functions:

local function itemListUpdate(itemName,itemCount,inv,slot )
    itemList[itemName].count=itemList[itemName].count+itemCount
    if inv.getItemDetail(slot) and inv.getItemDetail(slot).name==itemName then
        table.insert( itemList[itemName].instances,{inv,slot})
    end
end

local function overrideStorage()
    shell.run("rm data.txt")
    print("making itemList and freeSpaces")
    local start=os.clock()
    for i,inventory in pairs(inventories) do
        for space=1,27 do
            table.insert(freeSpaces,{inventory=peripheral.getName(inventory),slot=space})
            assert(inventory ~= nil and space ~= nil )
        end
        local slotsTaken={}
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
            table.insert(slotsTaken,slot)
        end
        for v,slot in pairs(slotsTaken) do
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
    fileManager:saveList(storageFile,itemList)
    return itemList
end

local function findItemPos(itemName)
    assert(1,itemName,"string")
    if itemList[itemName] then
        local values=table.remove(itemList[itemName].instances)
        return values.inventory,values.slot
    end
    return nil
end

local function sendCraftingJob(args)
    local itemName,itemCount,channel,replyChannel=args.name,args.count,args.channel,args.replyChannel
    modem.send(channel,replyChannel,{cmd="craftItem",name=itemName,count=itemCount})
end

local function pullRequest(name,cnt,inv,slot)
    expect(1,name,"string")
    expect(2,cnt,"number")
    expect(3,inv,"string")
    local pos=findItemPos(itemName)
    local pulledItems=pos.inventory.pullItems(inv,pos.slot,cnt,slot)
    itemListUpdate(name,pulledItems,pos.inventory,pos.slot,pos.inventory,pos.slot)
    if pulledItems and pulledItems<cnt then
        return pullRequest(name,cnt-pulledItems,inv,slot)
    end
    if not pulledItems or (pulledItems==0) then
        return false
    end
    return true
end

local function pushRequest(name,cnt,inv,slot)
    expect(1,name,"string")
    expect(2,cnt,"number")
    expect(3,inv,"string")
    local pos=itemList:pos(name)
    local pushedItems=pos.inventory.pullItems(inv,pos.slot,cnt,slot)
    itemList:update(name,pushedItems,pos.inventory,pos.slot)
    if pushedItems and pushedItems<cnt then
        return pushRequest(name,cnt-pushedItems,inv,slot)
    end
    return true
end

local function getItem(args)
    local name=args.name
    local count=args.count
    if pushRequest(name,count,peripheral.getName(peripheral.find("minecraft:dropper"))) then
        modem:send(args.channel,args.replyChannel,{reply="getItem",success=true})
    end
end

local function sortItem(args)
    local count=args.count
    local inventory=args.inventory
    local slot=args.slot
    for index, value in ipairs(args) do
        print(index,value)
    end
    if inventory and slot and inventory.getItemDetail() then
        pullRequest(inventory.getItemDetail().name,count,inventory,slot)
    elseif inventory then
        for listSlot,item in pairs(inventory.list()) do
            pullRequest(item.name,item.count,inventory,listSlot)
        end
    else
        local inputs={peripheral.find("minecraft:chest")}
        for i,listInventory in pairs(inputs) do
            for listslot,item in pairs(listInventory.list()) do
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
    print(itemList:getCount(name))
    modem:send(channel,replyChannel,{reply="getCount",count=itemList[name].count})
end

local function getFuel(args)
    local fuelCnt=args.count
    local inv=args.inv
    assert(type(fuelCnt)=="number")
    pullRequest(defaultFuel,fuelCnt,inv,2)
end

local function sendItemList(args)
    print("got request for itemList")
    local channel=args.channel
    assert(type(channel)=="number")
    local replyChannel=args.replyChannel
    assert(type(replyChannel)=="number")
    assert(modem)
    modem:send(channel,replyChannel,{reply="itemList",list=itemList})
end

local function showEventList()
    term.clear()
    term.setCursorPos(1,1)
    while true do
        for i,item in pairs(eventHandler.EventList) do
            term.write(item)
        end
        os.sleep(1)
    end
end

parallel.waitForAny(eventHandler.wait_for_Event,overrideStorage )


expect = expect.expect

--functionsliste fuer den Eventhandler
local handle={{name="",fun=sendCraftingJob},
{name="getFuel",fun=getFuel},
{name="getItem",fun=getItem},
{"sortItem",fun=sortItem},
{name="getCount",fun=sendCount},
{name="itemList",fun=sendItemList}}
eventHandler:makeHandle(handle)
wmodem.transmit(2206,22065,{reply="itemList",list=itemList})
--main
parallel.waitForAny(function() eventHandler:wait_for_Event() end,function() eventHandler:wait_for_workEvent() end,showEventList)