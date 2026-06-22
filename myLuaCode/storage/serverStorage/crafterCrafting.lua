local modem=peripheral.find("modem")
modem.open(27)
local crafter=peripheral.find("crafter")
local function requestItem(itemName,itemCount,slot)
    print("requesting item", itemName ,"in",self,"with count",itemCount)

    modem.transmit(3,27,{'pull',self,slot,itemName,itemCount})
end
local function selectItem(itemName)
    for i=1,16 do
        local _,info=turtle.getItemDetail(i)
        if info then
            if info.name==itemName then
                turtle.select(i)
            end
        end
    end
end
local function requestSortItem()
    print("requesting Sorting of item in ",self)
    modem.transmit(3,27,{'push',self,turtle.getSelectedSlot()})
end
local function craftModem(itemCount)
    if 64<itemCount*8 then
        for i=1,itemCount do
            requestItem("minecraft:stone",8,1)
            requestItem("minecraft:redstone",1,5)
            selectItem("minecraft:redstone")
            turtle.transferTo(6,1)
            selectItem("minecraft:stone")
            turtle.transferTo(2,1)
            turtle.transferTo(3,1)
            turtle.transferTo(5,1)
            turtle.transferTo(7,1)
            turtle.transferTo(9,1)
            turtle.transferTo(10,1)
            turtle.craft()
            requestSortItem()
        end
    else
        requestItem("minecraft:stone",itemCount*8)
        requestItem("minecraft:redstone",itemCount)
    end
    
end
while true do
    local event, side, channel, replyChannel, message, distance=os.pullEvent("modem_message")
    if channel==27 then
        if type(message)=="table" then
            if message[1]=="modem" then
                local itemCount=message[2]
                craftModem(itemCount)
            end 
        end
        
    end
end