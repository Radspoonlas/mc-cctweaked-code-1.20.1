local args={}
local expect=require "cc.expect"
local expect, field = expect.expect, expect.field
local stackLimit16={"minecraft:bucket","pearl"}
local stackLimit1={"minecraft:lava_bucket","milk_bucket",
"water_bucket","armor","sattel","bed","fishing","enchanted","sword","shovel","hoe"
,"axe","bow","template"}
--mit barrels arbeiten
--buecher in buecherregale sortieren(wenn es denn geht)
--roh erz in ofen tun
--kiste aus der Die items reingezogen werden sollen muss noch spezifiziert werden(dropper).
local completion = require "cc.completion"
local cmdHistory={"get","sort","monitor","getCount"}
local itemHistory={"test"}
local countHistory={"1"}
local cmdChoices={}
local itemChoices={}
local countChoices={}
local cmd={"get","sort","monitor","getCount"}

local freeSpaces={}
local localchannel=0
local EventList={}
local itemList={}
local sortingRoutine
local inventories={peripheral.find("minecraft:barrel")}
---@cast inventories ccTweaked.peripherals.Inventory[]
local modem = peripheral.find("modem") or error("No modem attached", 0)
local inputs={peripheral.find("minecraft:chest")}
---@cast inventories ccTweaked.peripherals.Inventory[]
local outputs={}
local ovens={}
local bookshelves={}
local cache={}
if modem then
    modem.open(localchannel) -- Open localchannel so we can receive replies
else
    print("missing modem")
end


local function itemExists(itemName)
    if not itemList[itemName] then
        return false,"nosuchitem"
    end
    return true
end


local function newOpenSpace(itemName)
    expect(1,itemName,"string")
    local inventory
    local slot
    --print(#freeSpaces)
    for t,space in pairs(freeSpaces) do
        inventory=space[1]
        slot=space[2]
        --print("in new openSpace itemdetailcount:",itemDetailCount(inventory,slot))
        freeSpaces[t]=nil
        assert(inventory~=nil and slot~=nil)
        itemList[itemName].LastAccessInventory,itemList[itemName].LastAccessSlot=inventory,slot
        itemList[itemName].LastAccessCount=0
        return true
    end
    print("no available spaces",#freeSpaces)

    return false
end

local function updatefreeSpaces()
    print("making freeSpaces")
    local start=os.clock()
    local counter=1
    for i,inventory in pairs(inventories) do
        for freespace=1,27 do
            table.insert(freeSpaces,{inventory,freespace})
        end
        local slotstaken={}
        for slot,item  in pairs(inventory.list()) do
            table.insert(slotstaken,slot)
        end
        for v,slot in pairs(slotstaken) do
            for pos,value in pairs(freeSpaces) do
                if value[1]==inventory then
                    if slot==value[2] then
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
    print("took: ",timer-start,"time")
    print("finishes making freespaces")
    print("found:",counter,"/",#inventories*27," open slots")
    return counter
end

local function createNewEntry(item,inventory,slot)
    --print(item.name," requires new entry")
    itemList[item.name]={}
    itemList[item.name].maxCount=inventory.getItemLimit(slot)
    itemList[item.name].count=item.count
    itemList[item.name].LastAccessCount=0
    itemList[item.name].instances={}
    if item.count==inventory.getItemLimit(slot) then
        table.insert(itemList[item.name].instances,{inventory,slot})
        newOpenSpace(item.name)
        assert( itemList[item.name].LastAccessInventory~=nil)
    else
        itemList[item.name].LastAccessInventory,itemList[item.name].LastAccessSlot=inventory,slot
        itemList[item.name].LastAccessCount=item.count
    end
    return true
end

local function updateItem(item,itemdiff)
    if type(item)=="String" then
        item.name=item
    end
    --print("updating: ",item.name,"count",itemList[item.name].count,"LastCount",itemList[item.name].LastAccessCount,"itemdiff:",itemdiff)
    itemList[item.name].count=itemList[item.name].count+itemdiff
    itemList[item.name].LastAccessCount=itemList[item.name].LastAccessCount+itemdiff
    --print("LastAccessCount,maxCount",itemList[item.name].LastAccessCount,itemList[item.name].maxCount,itemList[item.name].LastAccessCount==itemList[item.name].maxCount)
    if itemList[item.name].LastAccessCount==itemList[item.name].maxCount then
        table.insert(itemList[item.name].instances,{itemList[item.name].LastAccessInventory,itemList[item.name].LastAccessSlot})
        newOpenSpace(item.name)
    end
    return true
end

local function getLastAccess(itemName)
    expect(1,itemName,"string")
    assert(type(itemList[itemName])=="table")
    assert(type(itemList)=="table")
    --print("itemName",itemName)
    --print("itemList[itemName]",itemList[itemName])
    --print("itemList[itemName].LastAccessInventory",itemList[itemName].LastAccessInventory)
    return peripheral.getName(itemList[itemName].LastAccessInventory),itemList[itemName].LastAccessSlot
end

local function adjustEntry(item,inventory,slot)
    local itemsPushed=0
    local lastinv,lastSlot=getLastAccess(item.name)
    itemList[item.name].count=itemList[item.name].count+item.count
    if item.count==itemList[item.name].maxCount then
        --ueberprueft ob der stack voll ist
        table.insert(itemList[item.name].instances,{inventory,slot})
    else
        --stack nicht voll
        itemsPushed=inventory.pushItems(lastinv,slot,item.count,lastSlot)
        if itemsPushed<item.count then
            --print("itemcountif",item.count,itemList[item.name].LastAccessCount,itemsPushed)
            itemList[item.name].instances[#itemList[item.name].instances]={lastinv,lastSlot}
            itemList[item.name].LastAccessInventory,itemList[item.name].LastAccessSlot=inventory,slot
            itemList[item.name].LastAccessCount=item.count-itemsPushed
        else
            --print("itemcountelse",item.count,itemList[item.name].LastAccessCount,itemsPushed)
            itemList[item.name].LastAccessCount= itemList[item.name].LastAccessCount+itemsPushed
            if  itemList[item.name].LastAccessCount==itemList[item.name].maxCount then
                table.insert(itemList[item.name].instances,{inventory,slot})
                newOpenSpace(item.name)
            end
        end
    end
end

local function updateItemList()
    print("making ItemList:")
    local start=os.clock()
    for i,inventory in pairs(inventories) do
        for slot,item in pairs(inventory.list()) do
            term.clear()
            term.setCursorPos(1,1)
            print("at inv:",i,"/",#inventories,"slot:",slot,"/",inventory.size())
            if itemExists(item.name) then
                --case für item existiert
                adjustEntry(item,inventory,slot)
            else
                --case für item existiert nicht
                --print("name",item.name,"count:",item.count,"maxC",item.maxCount,"Limit",inventory.getItemLimit(slot))
                createNewEntry(item,inventory,slot)
            end
        end
    end
    local timer=os.clock()
print("took: ",timer-start,"time")
    print("finishes making itemList")
    return true
end

local function pullRequest(itemName,itemCount,inventory,slot,modem)
    itemCount=tonumber(itemCount)
    expect(1,itemName,"string")
    expect(2,itemCount,"number")
    if not inventory then
        print("missing input")
        return 0,"noInventory"
    end
    itemName="minecraft:"..itemName
    if itemExists(itemName) then
        if itemCount>itemList[itemName].count then
            print("not enough items ejecting max Items")
            itemCount=itemList[itemName].count
        elseif itemCount<0 then
            print("tried to pull negative Items?")
            return 0
        else
            local lastInv,lastSlot=getLastAccess(itemName)
            assert(type(lastSlot)=="number")
            if itemList[itemName].LastAccessCount==0 then
                itemList[itemName].LastAccessInventory,itemList[itemName].LastAccessSlot=table.remove(itemList[itemName].instances)
            end
            local pulledItems=inventory.pullItems(lastInv,lastSlot,itemCount,slot)
                print("pulled:",pulledItems,"of:",itemName)
                assert(type(pulledItems)=="number")
                updateItem(itemName,-pulledItems)
                if pulledItems<itemCount then
                    pulledItems=pulledItems+pullRequest(itemName,itemCount-pulledItems,inventory,slot,modem)
                end
            assert(itemCount-pulledItems==0)
            return pulledItems
        end
    else
        print("no such entry in itemList")
        return 0, "noSuchItem"
    end
end

local function sortItems(input)
    for slot,item in pairs(input.list()) do
        print("at item:",item.name," slot: ",slot)
        if itemExists(item.name) then
            local lastInv,lastSlot=getLastAccess(item.name)
            local itemCountPushed=input.pushItems(lastInv,slot,item.count,lastSlot)
            if itemCountPushed then 
                print("no items were moved")
            end
            updateItem(item,itemCountPushed)
            if itemCountPushed<item.count then
                --print("too little itemspushed:",itemCountPushed,itemList[item.name].LastAccessCount)
                table.insert(itemList[item.name].instances,{lastInv,lastSlot})
                newOpenSpace(item.name)
                sortItems(input)
                break
            end
        else
            createNewEntry(item,input,slot)
            print("required new entry")
            assert(itemList[item.name].LastAccessCount~=64)
        end
    end
    return true
end

local function getItem(itemName,itemCount)
    local output={peripheral.find("minecraft:dropper")}
    if not pullRequest(itemName,itemCount,output[1]) then
        print("pull request failed")
        return false
    end
    return true
end

local function updateHistory(history,msg)
    table.insert(history,msg)
end

local function makeChoice(arg,item)
    if arg=="cmd" then
        cmdChoices={}
        for i,command in pairs(cmd) do
            table.insert(cmdChoices,(command))
        end
        return
    elseif arg=="item" then
        itemChoices={}
        for i,itemName in pairs(itemList) do
            table.insert(itemChoices,(string.gsub(i,"minecraft:","")))
            table.sort(itemChoices)
        end
        return
    elseif arg=="count" then
        if item then
            if itemList[item].count>64 then
                countChoices={"1","64",tostring(itemList[item].count)}
            elseif itemList[item].count>32 then
                countChoices={"1","32",tostring(itemList[item].count)}
            elseif itemList[item].count>16 then
                countChoices={"1","16",tostring(itemList[item].count)}
            end
        end
        return
    end
    makeChoice("cmd")
    makeChoice("item")
    makeChoice("count")
end
local function wait_for_input()
    --term.clear()
    --term.setCursorPos(1,1)
    print("Gib ein Kommando ein:")
    term.write("> ")
    local msg=read(nil,cmdHistory,function(text) return completion.choice(text,cmdChoices) end,nil)
    local command=msg
    updateHistory(cmdHistory,command)
    if command=="sort" then
        --sortieren
        for i,input in pairs(inputs) do
            sortItems(input)
        end
        return
    elseif command=="monitor" then
        --monitor zeug
        return
    end

   print("Gib ein Item ein:")
   term.write("> ")
    msg=read(nil,itemHistory,function(text) return completion.choice(text,itemChoices)end,nil)
    local item=msg
    if command=="getCount" then
        updateHistory(countHistory,item)
        item="minecraft:"..item
        if itemList[item] then
            print(item,itemList[item].count)
            print(itemList[item].count)
            return
        end
        print("couldnt find item")
        return
    end
    print("Gib eine Anzahl ein:")
    term.write("> ")
    msg=read(nil,countHistory,function(text) return completion.choice(text,countChoices)end,nil)
    local itemCount=msg
    if command=="get" then
        getItem(item,itemCount)
    end
end

--Raw items,kelp,fuel,anderes
local function checkForOven()
end

local function wait_for_event()
    local Event=os.pullEvent()
    local n=1
    while EventList[n] do
        n=n+1
    end
    EventList[n]=Event
end

local function wait_for_workEvent()
    for i,v in ipairs(EventList) do
        if v[1]=="modem_message" then

        elseif v[1]=="timer" then
            if v[2]==sortingRoutine then
                sortingRoutine=os.startTimer(10)
                for i,v in ipairs(inputs) do
                    sortItems(v)
                end
            end
        end
    end
end

--setup fuer lagerverteilung

updatefreeSpaces()
if not updateItemList() then
    print("failed making ItemList")
    return 
end
makeChoice()
print("itemList:",itemList,#itemList,"inventories",#inventories)

local function wait_for_sleep()
    os.sleep(100)
    return
end
modem=nil
if modem then
    while true do
        parallel.waitForAny(wait_for_event,wait_for_workEvent)
    end
else
    while true do
        parallel.waitForAny(wait_for_input,wait_for_sleep)
        os.sleep(5)
    end
end