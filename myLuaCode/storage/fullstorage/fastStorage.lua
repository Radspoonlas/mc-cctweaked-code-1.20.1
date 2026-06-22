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
    assert(1,itemName,"string")
    if itemList[itemName] then
        for i,v in pairs(itemList[itemName].instances) do
            print(i,v)
            return v.inventory,v.slot
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
                itemList[item.name].count=item.count+itemList[item.name].count
                table.insert(itemList[item.name].instances,{inventory=inventory,slot=slot})
            else
                itemList[item.name]={}
                itemList[item.name].instances={}
                table.insert( itemList[item.name].instances,{inventory=inventory,slot=slot})
                itemList[item.name].count=item.count
                itemList[item.name].itemLimit=inventory.getItemLimit(slot)
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
        print(space)
        print("no more of that item")
        return false
    end
    print(space,slot)
    local pushedCount=output.pullItems(peripheral.getName(space),slot,itemCount,toSlot)
    itemList[itemName].count= itemList[itemName].count-pushedCount
    if not space.getItemDetail(slot) then
        for i,v in pairs(itemList[itemName].instances) do
            v=nil
            break
        end
    end
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
    return true
end

local function sortItems(inputs)
    for n,inventory in pairs(inputs) do
        for slot,item in pairs(inventory.list()) do
            local pushedItems=0
            if itemList[item.name] then
                itemList[item.name].count=item.count+ itemList[item.name].count
                table.insert(itemList[item.name].instances,{inventory=inventory,slot=slot})
                for i,values in pairs(itemList[item.name].instances) do
                    print(values.inventory,values.slot)
                    if values.inventory.getItemDetail(values.slot).count<itemList[item.name].itemLimit then
                        pushedItems=inventory.pushItems(peripheral.getName(values.inventory),slot,item.count,values.slot)+pushedItems
                        if pushedItems==item.count then
                            break
                        end
                    end
                end
                if pushedItems<item.count then
                    local space=table.remove(freeSpaces)
                    inventory.pushItems(peripheral.getName(space[1]),slot,item.count,space[2])
                    table.insert(itemList[item.name].instances,{inventory=inventory,slot=slot})
                end
            else
                itemList[item.name]={}
                itemList[item.name].count=item.count
                itemList[item.name].instances={}
                table.insert( itemList[item.name].instances,{inventory=inventory,slot=slot})
                itemList[item.name].itemLimit=inventory.getItemLimit(slot)
                local space=table.remove(freeSpaces)
                inventory.pushItems(peripheral.getName(space[1]),slot,item.count,space[2])
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
            print("itemCount of: ",item,"is: ",itemList[item].count)
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


local function wait_for_sleep()
    os.sleep(60*2)
    local inputs={peripheral.find("minecraft:chest")}
    sortItems(inputs)
    return
end


--setup fuer lagerverteilung

updatefreeSpaces()
while true do
        print("inside accesspoint")
        parallel.waitForAny(wait_for_input,wait_for_sleep)
end