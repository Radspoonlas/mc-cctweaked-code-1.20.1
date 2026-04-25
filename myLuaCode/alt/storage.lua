local args={...}
local freeSpaces={}
local sortingRoutine
local EventList={}
local completion = require "cc.completion"
local cmdHistory={"get","sort","getCount"}
local itemHistory={}
local countHistory={"1"}
local countChoices={}
local itemChoices={}
local cmdChoices={"get","sort","monitor","getCount"}
local cmd={"get","sort","getCount"}
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
    return nil,nil
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
    local space,slot=findItemPos(itemName)
    if not space then
        print("no more of that item")
        return false
    end
    local pushedCount=output.pullItems(peripheral.getName(space),slot,itemCount,toSlot)
    itemList[itemName]= itemList[itemName]-pushedCount
    if not pushedCount then
        return false
    end
    if pushedCount<itemCount then
        if pushedCount==0 then
            return false
        end
        pullRequest(itemName,itemCount-pushedCount,output,toSlot)
    end
    
    return true
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
    pullRequest(itemName,itemCount,output[1]) 
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
        --sortieren
        local inputs={peripheral.find("minecraft:chest")}
        sortItems(inputs)
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
        if itemList[item] then
            print("itemCount of: ",item,"is: ",itemList[item])
        else
            print("no item of that name:",item)
        end
        return
    end
    print("Gib eine Anzahl ein:")
    term.write("> ")
    makeChoice("count")
    msg=read(nil,countHistory,function(text) return completion.choice(text,countChoices)end,nil)
    local itemCount=msg
    if command=="get" then
        if itemList[item] then
            getItem(item,tonumber(itemCount))
        else
            print("nosuchitem")
        end
        
    end
end

local function adjustItems()
    local changeList={}
    for i,inv in ipairs(inventories) do
        for slot,item in pairs(inv.list()) do
            if changeList[item.name] then
                if inv.getItemLimit(slot)<item.count then
                    local count=inv.pushItems(changeList[item.name],slot,64,changeList[item.name].slot)
                    changeList[item.name]={count=item.count-count,inventory=inv,slot=slot}
                end
            else
                if inv.getItemLimit(slot)<item.count then
                    changeList[item.name].count={count=item.count,inventory=inv,slot=slot}
                end
            end
        end
    end
    os.reboot()
end

local function wait_for_sleep()
    os.sleep(60*2)
    local inputs={peripheral.find("minecraft:chest")}
    sortItems(inputs)
    adjustItems()
    return
end


--setup fuer lagerverteilung

updatefreeSpaces()
while true do
        print("inside accesspoint")
        parallel.waitForAny(wait_for_input,wait_for_sleep)
end