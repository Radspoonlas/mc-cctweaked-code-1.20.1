local itemList
local monitorchannel=22068
local storageChannel=22065
local localChannel=22069
local modems={peripheral.find("modem")}
local modem
for i,m in ipairs(modems) do
    if m.isWireless() then
        modem=m
        print("found modem...")
    end
end
if modem then
    modem.open(localChannel)
end

local textSize=2
modem.open(monitorchannel)

local function getItemColour(itemName)
    local default=colors.white
    local wood={"oak","spruce","birch","acacia","cherry"}
    local plants={"seed","mushroom","sapling","sugar"}
    local rocks={"granite","andesite","diorite","cobble","tuff"}
    local redstone={"rail","redstone","piston","observer"}
    if string.match(itemName,"copper") then
        return colors.orange
    elseif string.match(itemName,"diamond") then
        return colors.cyan
    elseif string.match(itemName,"default") then
        return default
    elseif string.match(itemName,"gold") then
        return colors.yellow
    end
    for i,word in ipairs(plants) do
        if string.match(itemName,word) then
            return colors.lime
        end
    end
    for i,word in ipairs(wood) do
        if string.match(itemName,word) then
            return colors.brown
        end
    end
    for i,word in ipairs(rocks) do
        if string.match(itemName,word) then
            return colors.lightGray
        end
    end
    for i,word in ipairs(redstone) do
        if string.match(itemName,word) then
            return colors.red
        end
    end
    return default
end


local function showItems()
    print("now in ShowItems")
    local monitors={peripheral.find("monitor")}
    local monitor=monitors[1]
    while not monitor do
        print("found no monitor")
        os.sleep(10)
        monitors={peripheral.find("monitor")}
        monitor=monitors[1]
    end
    monitor.setTextScale(textSize)
    monitor.setTextColor(colors.black)
    local posX,posY=1,1
    local maxX,maxY=monitor.getSize()
    local sortedList={}
    for item,count in pairs(itemList) do
        table.insert(sortedList,{item,count})
    end
    table.sort(sortedList,function(a,b) return  a[2]>b[2] end)
    monitor.setCursorPos(1,1)
    print(#sortedList)
    while true do
        if #sortedList==0 then
            monitor.setCursorPos(math.random(maxX),math.random(maxY))
            monitor.write("xD")
            os.sleep(1)
        end
        for i,values in pairs(sortedList) do
            monitor.setCursorPos(posX,posY)
            monitor.clearLine()
            monitor.setBackgroundColor(getItemColour(values[1]))
            monitor.write(string.gsub(values[1],"minecraft:",""))
            monitor.setCursorPos(maxX/2,posY)
            monitor.write(values[2])
            monitor.setBackgroundColor(getItemColour("default"))
           
            posY=posY+1
            if posY>maxY then
                posY=1
            end
            os.sleep(0.5)
        end
    end
    print("/////////////// WHAT HAPPENED HERE //////////")
end

local function checkStorageDiff()
    print("itemListCount",#itemList)
   if not next(itemList) then
    print("sent request")
    modem.open(storageChannel)
    modem.transmit(storageChannel,monitorchannel,"itemList")
    modem.close(storageChannel)
   end
   print("expecting itemList...")
    local Event={os.pullEvent("modem_message")}
    local eve, side, channel, replyChannel, message, distance=table.unpack(Event) 
    itemList=message.list
    os.sleep(1)
    if not next(itemList) then
        os.sleep(10)
        return
    end
    print("gotItemList: ",#itemList)
end


while true do  
    parallel.waitForAny(checkStorageDiff,showItems)
end