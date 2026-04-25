local eventHandler=require 'EventHandler'
-- returns total item count of item
local function itemCount(message)
    local cnt=0
    local file=io.open(fileName,"w")
    local data=file:lines("a")
    local items=textutils.unserialise(data)
    for i,v in pairs(items) do
        cnt=cnt+v.count
    end
    file:close()
    eventHandler.sendAnswer({cmd='count',count=cnt})
end

-- creates log for differences of what should be in db and what is then updates it
local function logDifferences(message)
    local file=io.open('changeLog',"w")
    local data=file:read("a")
    local log=textutils.unserialise(data)
    table.insert(log,{message.itemName,message.pos,message.count})
    file:write(log)
    file:close()
    return true
end

--updates Entry of item at specified Position to current
local function updateEntry(message)
    local file=io.open(tostring(message.itemName) .. '.txt',"w")
    local data=file:lines("a")
    local items=textutils.unserialise(data)
    if message.remove then
        for i,v in pairs(items) do
            if v.pos==message.pos then
                table.remove(items,i)
            end
        end
    elseif message.add then
        table.insert({message.pos,message.count})
    elseif message.difference then
        for i,v in pairs(items) do
            if v.pos==message.pos then
                v={v.pos,v.count+message.count}
            end
        end
    end
    file:close()
    logDifferences(message)
    return true
end

-- returns Position of Item
local function findItemEntry(message)
    local file=io.open(tostring(message.itemName).. '.txt',"w")
    local data=file:lines("a")
    local items=textutils.unserialise(data)
    file:close()
    return items[#items]
end

EventHandler.messageHandlerList={
    getItemPos=findItemEntry,
    getItemCount=itemCount,
    update=updateEntry
}

local myModem=peripheral.find("modem") or error
EventHandler.modem=myModem
myModem.open(EventHandler.myChannel)

while true do
    EventHandler.messageHandler()
end
