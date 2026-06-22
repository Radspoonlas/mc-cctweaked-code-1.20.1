--EventHandler
local eventHandler=require 'EventHandler'

local myModem=peripheral.find("modem")
eventHandler.modem=myModem
myModem.open(eventHandler.myChannel)

--internal stuff
local inputs=peripheral.find("minecraft:chest")
local storage={peripheral.find("minecraft:barrel")}
table.sort(storage)
local lastEmptyPos={1,1}

--functions
local function updateDB(msg)
     myModem.transmit(eventHandler.myChannel,eventHandler.myChannel,msg)
end

local function findNextOpenSlot()
    for i=lastEmptyPos,#storage do
        for slot,item in pairs(storage[i].list()) do
            if not storage[i].getItemDetail() then
                lastEmptyPos={i,slot}
                return true
            end
        end
    end
    for i=1,lastEmptyPos do
        for slot,item in pairs(storage[i].list()) do
            if not storage[i].getItemDetail() then
                lastEmptyPos={i,slot}
                return true
            end
        end
    end
    lastEmptyPos={0,0}
    return false
end

local function pullItem(message)
    local input=message.inv
    local inputPos=message.pos
    local limit=message.count or 64
    local cnt=1
    while cnt<64 do
        if findNextOpenSlot() then
            local storagePos=lastEmptyPos
            local inventory=peripheral.wrap(storage[lastEmptyPos[1]])
            local pulled=inventory.pullItem(input,inputPos,limit,lastEmptyPos[2]) 
            updateDB({
                cmd='update',
                itemName=message.item,
                count=message.count,
                pos=storagePos
            })
            if message.count and pulled<message.count then
                cnt=cnt+1
            else
                cnt=64
            end
        else
            eventHandler.sendAnswer({cmd='reply',err="no more open space",suc=false})
            return
        end
    end
    EventHandler.sendAnswer({cmd='reply',suc=true})
end

local function pushItem(message)
    EventHandler.sendAnswer({cmd='getItemPos',})
    updateDB({
        cmd='update',
        itemName=message.item,
        count=message.count,
        pos=message.pos
    })
end

local function getItemCount(message)
    myModem.transmit(eventHandler.myChannel,
    eventHandler.myChannel,
    {
        cmd=getItemCount,
        itemName=message.item,
        replyChannel=eventHandler.myChannel
    })
end

--main
eventHandler.messageHandlerList={msgDB=updateDB,sort=pullItem,getItem=pushItem,getCount=getItemCount,}
