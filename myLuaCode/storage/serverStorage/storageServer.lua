local debugMode=true
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
local db={}
local freeSpaces={}
fileManager:new()


--local variables:

local defaultFuel="minecraft:bamboo_plank"
local fuel={}


local inventories={peripheral.find("minecraft:barrel")}

--functions:

local function itemListUpdate(itemName,itemCount,inv,slot )
    expect(1,itemName,"string")
    expect(2,itemCount,"number")
    expect(3,inv,"string")
    expect(4,slot,"number")
    if not itemList[itemName] then
        itemList[itemName]={}
        itemList[itemName].instances={}
        table.insert( itemList[itemName].instances,{inventory=inv,slot=slot})
        if debugMode then assert(inv ~= nil and slot ~= nil,"missing entry" )end
        itemList[itemName].count=itemCount
        itemList[itemName].itemLimit=inv.getItemLimit(slot)
    else
        itemList[itemName].count=itemList[itemName].count+itemCount
        if peripheral.wrap(inv).getItemDetail(slot) and peripheral.wrap(inv).getItemDetail(slot).name==itemName then
            if debugMode then assert(inv~=nil and slot~=nil,"why tf")end
            table.insert( itemList[itemName].instances,{inventory=inv,slot=slot})
            if debugMode then assert(type(inv)=="string"and type(slot)=="number")end
        end
    end
    db[inv][slot]={name=itemName,count=itemCount}
end

local function overrideStorage()
    shell.run("rm data.txt")
    print("making itemList,db and freeSpaces")
    local start=os.clock()
    local cntSlotsTaken=0
    for i=1,#inventories do
        local inventory=inventories[i]
        db[peripheral.getName(inventory)]=inventory.list()
        local items=inventory.list()
        for j=1,#items   do
            local item=items[j]
            if item then
                if  itemList[item.name] then
                    itemList[item.name].count=item.count+itemList[item.name].count
                    table.insert(itemList[item.name].instances,{inventory=peripheral.getName(inventory),slot=j})
                     if debugMode then assert(inventory ~= nil and j ~= nil,"missing entry" )end
                else
                    itemList[item.name]={}
                    itemList[item.name].instances={}
                    table.insert( itemList[item.name].instances,{inventory=peripheral.getName(inventory),slot=j})
                     if debugMode then assert(inventory ~= nil and j ~= nil,"missing entry" )end
                    itemList[item.name].count=item.count
                    itemList[item.name].itemLimit=inventory.getItemLimit(j)
                end
                cntSlotsTaken=cntSlotsTaken+1
            else
                table.insert(freeSpaces,{inventory=peripheral.getName(inventory),slot=j})
            end
        end
        term.clear()
        term.setCursorPos(1,1)
        print("openSpaces:",i*27-cntSlotsTaken," maxSpaces: ",i*27," taken: ",cntSlotsTaken)
        print("filledperc = ",(cntSlotsTaken/(27*#inventories))*100," %")
        print("inv: ",i," / ",#inventories)
    end
    local timer=os.clock()
    term.clear()
    print("took: ",timer-start,"time")
    print("finishes making freespaces")
    print("openSpaces:",#freeSpaces," maxSpaces: ",#inventories*27)

    --fileManager:saveList(storageFile,itemList)
    return itemList
end

local function findItemPos(itemName)
    expect(1,itemName,"string")
    if itemList[itemName] then
        
        if debugMode then
            for i=1,#itemList[itemName].instances do
                print(itemList[itemName].instances[i])
                if itemList[itemName].instances[i] then
                    print(itemList[itemName].instances[i].inventory,itemList[itemName].instances[i].slot)
                end
            end
            print("number of instances: ",#itemList[itemName].instances)

        end
        local values,value2=table.remove(itemList[itemName].instances)
        print(values,"  -  ",value2)
         if debugMode then 
            assert(values.inventory~=nil and values.slot~=nil,print(values.inventory,values.slot))
            assert(itemList[itemName].instances[#itemList[itemName].instances].inventory~=nil,"no value? "..itemList[itemName].instances[#itemList[itemName].instances].inventory)
         end
        
         return values.inventory,values.slot
    else
        print("no knowledge of that item")
        return nil
    end
end

local function sendCraftingJob(args)
    local itemName,itemCount,channel,replyChannel=args.name,args.count,args.channel,args.replyChannel
    modem.send(channel,replyChannel,{cmd="craftItem",name=itemName,count=itemCount})
end

local function pullRequest(name,cnt,inv,slot)
    expect(1,name,"string")
    expect(2,cnt,"number")
    expect(3,inv,"string")
    if debugMode then print("inside pullrequest")end
    local pos=table.remove(freeSpaces,#freeSpaces)
    if debugMode then print(pos,#freeSpaces)end

    local inventory,invslot=pos.inventory,pos.slot
    if debugMode then assert(type(invslot)=="number","check failed for invslot "..invslot)end
    
    if debugMode then assert(inventory~=nil,print(inventory)) print("post assert pr")end

    inventory=peripheral.wrap(inventory)
    if debugMode then
        assert(inventory.getItemDetail(invslot)==nil,inventory.getItemDetail(invslot))
        assert(peripheral.wrap(inv).getItemDetail(slot)~=nil)
    end
    local pulledItems=inventory.pullItems(inv,slot,cnt,invslot)
    if debugMode then print(pulledItems)end
    itemListUpdate(name,pulledItems,peripheral.getName(inventory),invslot)

    if pulledItems and pulledItems<cnt then
        if debugMode then  print("recursion2")end
        return pullRequest(name,cnt-pulledItems,inv,slot)
    end
    if debugMode then print("outside pullrequest")end
    if not pulledItems or (pulledItems==0) then
        return false
    end
    return true
end

local function pushRequest(name,cnt,inv,slot)
    expect(1,name,"string")
    expect(2,cnt,"number")
    expect(3,inv,"string")
    if debugMode then
        print("inside pushRequest")
    end
    if not itemList[name] then
        print("no such item")
        return 0
    end

    local inventory,invslot=findItemPos(name)
    if debugMode then assert(inventories~=nil and inv~=nil)end
    inventory=peripheral.wrap(inventory)

    local pushedItems=inventory.pushItems(inv,invslot,cnt,slot)
    if debugMode then
        print(pushedItems)
    end
    itemListUpdate(name,pushedItems,peripheral.getName(inventory),invslot)

    if pushedItems and pushedItems<cnt then
        if debugMode then
            print("recursion1")
        end
        return pushRequest(name,cnt-pushedItems,inv,slot)
    end
    return true
end

local function getItem(args)
    if debugMode then
        print("inside getItem")
    end
    local name=args.name
    local count=args.count
    if pushRequest(name,count,peripheral.getName(peripheral.find("minecraft:dropper"))) then
        modem:send(args.replyChannel,storageChannel,{reply="getItem",success=true})
    end
    if debugMode then
    print("out of getItem")
    end
end

local function sortItem(args)
    if debugMode then
    print("inside sortItem")
    end
    local count=args.count
    local inventory=args.inventory
    local slot=args.slot
    assert(type(slot)=="number","not a number?"..(slot))
    if debugMode then print("post assert")end
    if inventory and slot and peripheral.wrap(inventory).getItemDetail(args.slot) then
        if debugMode then print("pullrequest case1")end
        pullRequest(peripheral.wrap(inventory).getItemDetail(args.slot).name,count or 64,inventory,slot)
    elseif inventory then
        for listSlot,item in pairs(peripheral.wrap(inventory).list()) do
            if debugMode then print("pullrequest case2")end
            pullRequest(item.name,item.count,inventory,listSlot)
        end
    else
        local inputs={peripheral.find("minecraft:chest")}
        for i,listInventory in pairs(inputs) do
            for listslot,item in pairs(listInventory.list()) do
                if debugMode then print("pullRequest case3")end
                pullRequest(item.name,item.count,inventory,listslot)
            end
        end
    end
    if debugMode then
        print("outside sortItem")
    end
    return true
end
local function sortChests(args)
    local chests={peripheral.find("minecraft:chest")}
    local chest
    local items
    local item
    for i=1,#chests do
        chest=chests[i]
        items=chest.list()
        for j=1,#items do
            item=items[j]
            if item then
                pullRequest(item.name,item.count,peripheral.getName(chest),j)
            end
        end
    end
end

local function sortDroppers(args)
    local droppers={peripheral.find("minecraft:dropper")}
    for i=1,#droppers do
        local dropper=droppers[i]
        local items=dropper.list()
        for j=1,#items do
            local item=items[j]
            if item then
                pullRequest(item.name,item.count,peripheral.getName(dropper),j)
            end
        end
    end
end
local function sendCount(args)
    local replyChannel=args.channel
    local channel=args.replyChannel
    local name=args.name
    modem:send(channel,replyChannel,{reply="getCount",count=itemList[name].count})
end

local function getFuel(args)
    local fuelCnt=args.count
    local inv=args.inv
    assert(type(fuelCnt)=="number","not a number: "..type(fuelCnt))
    pullRequest(defaultFuel,fuelCnt,inv,2)
end

local function sendItemList(args)
    if debugMode then
    print("got request for itemList")
    end
    local channel=args.channel
    assert(type(channel)=="number")
    local replyChannel=args.replyChannel
    assert(type(replyChannel)=="number","not a number: ")
    assert(modem,"no modem available")
    modem:send(replyChannel,channel,{cmd="itemList",list=itemList})
end
local function pullItem(args)
    local name=args.name
    pullRequest(name,cnt,inv,slot)
end
local function pushItem(args)
    local inv=args.inventory
    if not inv then
        return
    end
    local slot=args.slot
    if not slot then
        slot=1
    end
    local cnt=args.count
    if not cnt then
        cnt=1
    end
    local name=args.name
    if not name or not itemList[name] then
        return
    end
    pushRequest(name,cnt,inv,slot)
end
expect = expect.expect
print("initializing...")

--init
local handle={
    {name="craftItem",fun=sendCraftingJob},
    {name="getFuel",fun=getFuel},
    {name="getItem",fun=getItem},
    {name="sortItem",fun=sortItem},
    {name="getCount",fun=sendCount},
    {name="itemList",fun=sendItemList},
    {name="sortChests",fun=sortChests},
    {name="sortDroppers",fun=sortDroppers},
    {name="pullItem",fun=pullItem},
    {name="pushItem",fun=pushItem},
}
eventHandler:makeHandle(handle)
if not modem:newWireless() then
    print("no modem")
    return
end
modem:openChannel(storageChannel)

--main
parallel.waitForAny(function() eventHandler:wait_for_Event() end,overrideStorage)
print("done initializing.")
modem:send(serverChannel,storageChannel,{cmd="itemList",list=itemList})

print("now waiting for Events...")
parallel.waitForAny(function() eventHandler:wait_for_Event() end,function() eventHandler:wait_for_workEvent() end)