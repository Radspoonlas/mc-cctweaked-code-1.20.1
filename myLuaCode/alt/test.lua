local itemList={}
local inventories={peripheral.find("minecraft:barrel") }
local freeSpaces={}
local modem=peripheral.find("modem")
modem.open(22061)
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
    modem.open(22061)
    modem.transmit(22061,22065,{"itemList",list=itemList})
    modem.close(22061)
    return counter
end
local function receiveitemList()
    local Event=os.pullEvent("modem message")
    local event, side, channel, replyChannel, message, distance,time=Event
    print(event)
    if message[1]=="itemList" then
        print("got ItemList!")
    end
end
local function whilereceive()
    while true do
        receiveitemList()
    end
end
local function msg()
    local modem = peripheral.find("modem") or error("No modem attached", 0)
    modem.open(22068)
    
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        print(("Message received on side %s on channel %d (reply to %d) from %f blocks away with message %s"):format(
            side, channel, replyChannel, distance, tostring(message)
        ))
    end
end
--updatefreeSpaces()
--whilereceive()
msg()
print("done")