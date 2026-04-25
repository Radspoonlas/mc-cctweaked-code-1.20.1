local args={...}
local freeSpaces={}
local localchannel=0
local EventList={}
local completion = require "cc.completion"
local cmdHistory={"get","sort","monitor","getCount"}
local itemHistory={"test"}
local countHistory={"1"}
local countChoices={}
local cmdChoices={"get","sort","monitor","getCount"}
local cmd={"get","sort","monitor","getCount"}
local expect=require "cc.expect"
local expect, field = expect.expect, expect.field
local inventories={peripheral.find("minecraft:barrel")}
local itemList={}
local function findItemPos(itemName)
    for i,inventory in pairs(inventories) do
        for slot,item in pairs(inventory.list()) do
            if item.name==itemName then
                return inventory,slot
            end
        end
    end
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
            if  itemList[item.name] then
                itemList[item.name]=item.count+itemList[item.name]
            else
                itemList[item.name]=item.count
            end
            
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
local function pullRequest(itemName,itemCount,output,toSlot)
    expect(1,itemName,"string")
    expect(2,itemCount,"number")
    local inv,slot=findItemPos(itemName)
    local pushedCount=output.pullItem(peripheral.getName(inv),slot,itemCount,toSlot)
    pullRequest(itemName,itemCount-pushedCount,output,toSlot)
end

local function sortItems(inputs)
    for i,inventory in pairs(inputs) do
        for slot,item in pairs(inventory.list()) do
            local space=table.remove(freeSpaces)
            inventory.pushItems(peripheral.getName(space[1]),slot,item.count,space[2])
            if itemList[item.name] then
                itemList[item.name]=item.count+ itemList[item.name]
            else
                itemList[item.name]=item.count
            end
        end
    end
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
        local cmdChoices={}
        for i,command in pairs(cmd) do
            table.insert(cmdChoices,(command))
        end
        return
    elseif arg=="item" then
        local itemChoices={}
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
        local inputs={peripheral.find("minecraft:chest")}
        sortItems(inputs)
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
        print("itemCount of: ",item,"is: ",getItemCount(item))
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
makeChoice()

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