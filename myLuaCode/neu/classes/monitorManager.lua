--Anzeige fuer wie viele Items davon noch existieren
--anstatt alle items anzeigen, recourcen anzeigen lassen wie holz erz stein, dried kelp block
--Liste fuer zu anzeigende Items
local monitorChannel=22068
local storageChannel=22065
local default=colors.white
local Wood={"log","plank","stick","stem","spruce","oak","cherry","acaia","jungle","crimson","warped","birch"}
local iron={"iron"}
local diamond={"diamond"}
local copper={"copper"}
local plant={"sapling","seed","carrot","potato","mushroom","leaf","melon","pumpkin","beetroot","sugar","cocoa","cactus","dye","bamboo","lil","berr"}
local rocks={"stone","deepslate","cobble","granite","diorite","andesite","tuff","obsidian"}
local mobLoot={"bone","flesh","cooked","gun","string","ender","blaze","cream","slime"}
local redstone={"rail","redstone","piston","observer"}
local bgcolours={[Wood]=colors.brown,[rocks]=colors.gray,[iron]=colors.lightGray,
[diamond]=colors.cyan,[copper]=colors.red,[plant]=colors.lime,[default]=colors.lightBlue}
local EventList={}
local itemList={}
local monitor=peripheral.find("monitor")
local modems={peripheral.find("modem")}
local modem
for i,m in ipairs(modems) do
    if m.isWireless() then
        modem=m
        print("found modem...")
    end
end
if modem then
    modem.open(monitorChannel)
end
local maxX,maxY=monitor.getSize()
local header={x1=1,x2=maxX,y1=1,y2=3}
local body={x1=1,x2=maxX,y1=header.y2+1,y2=maxY}

local textSize=2
modem.open(monitorChannel)
local Event
local function getItemColour(itemName)
    if string.match(itemName,"copper") then
        return colors.orange
    elseif string.match(itemName,"diamond") then
        return colors.cyan
    elseif string.match(itemName,"default") then
        return default
    elseif string.match(itemName,"gold") then
        return colors.yellow
    elseif string.match(itemName,"iron") then
        return colors.gray
    end
    for i,word in ipairs(redstone) do
        if string.match(itemName,word) then
            return colors.red
        end
    end
    for i,word in ipairs(plant) do
        if string.match(itemName,word) then
            return colors.lime
        end
    end
    for i,word in ipairs(mobLoot) do
        if string.match(itemName,word) then
            return colors.purple
        end
    end
    for i,word in ipairs(Wood) do
        if string.match(itemName,word) then
            return colors.brown
        end
    end
    for i,word in ipairs(rocks) do
        if string.match(itemName,word) then
            return colors.lightGray
        end
    end
    
    return default
end


local function wait_for_pull()
    Event={os.pullEvent("modem_message")}
    print("got event")
    local eve, side, channel, replyChannel, message, distance=table.unpack(Event) 
    itemList=message.list
end

local function wait_for_sleep()
    os.sleep(60*5)
end

local function wait_for_Event()
    print("itemListCount",#itemList)
    if not next(itemList) then
        print("sent request")
        modem.open(storageChannel)
        modem.transmit(storageChannel,monitorChannel,{cmd="itemList"})
        modem.close(storageChannel)
    end
    print("expecting itemList...")
    local status=parallel.waitForAny( wait_for_sleep,wait_for_pull)
    if status==2 then
        return
    end

end

--aufteilung des monitors
local function monitorDistribution()
    for i,v in pairs(distr) do
    end
    local distr={header,body}
    return distr
end

--soll items in ItemList über x1,y1 bis x2,y2 anzeigen
local function showItems(format)
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
    local posX,posY=format.x1,format.y1
    local maxX,maxY=monitor.getSize()
    local sortedList={}
    for item,values in pairs(itemList) do
        table.insert(sortedList,{item,values.count})
    end
    table.sort(sortedList,function(a,b) return  a[2]>b[2] end)
    monitor.setCursorPos(1,1)
    while true do
        if #sortedList==0 then
            monitor.setCursorPos( math.random(maxX), math.random(maxY) )
            monitor.write("xD")
            os.sleep(1)
        end
        for i,values in pairs(sortedList) do
            monitor.setCursorPos(posX,posY)
            monitor.clearLine()
            monitor.setBackgroundColor(getItemColour(values[1]))
            monitor.write(string.gsub(values[1],"minecraft:",""))
            monitor.setCursorPos(format.x2/2,posY)
            monitor.write(values[2])
            monitor.setBackgroundColor(getItemColour("default"))
           
            posY=posY+1
            if posY>format.y2 then
                posY=format.y1
            end
            os.sleep(0.5)
        end
    end
    print("/////////////// WHAT HAPPENED HERE //////////")
end

--hier muss mit den einstellungen gearbeitet werden um den default für displayDistribution zu setzen und was angezeigt wird

local function showDate(format)
    for i=format.y1,format.y2 do
        monitor.setCursorPos(1,i)
        monitor.clearLine()
    end
    while true do
        monitor.setCursorPos(format.x1,format.y1)
        monitor.clearLine()
        monitor.write(os.date())
        monitor.write("  uptime: ")
        monitor.write(os.clock())
        monitor.setCursorPos(format.x1,format.y1+1)
        monitor.clearLine()
        monitor.write("current Time: ")
        monitor.write(os.time())
        monitor.write("/24")
        monitor.setCursorPos(format.x1,format.y1+2)
        monitor.clearLine()
        monitor.write("current Day: ")
        monitor.write(os.day())
        os.sleep(60)
    end
end


local function wait_for_header()
    showDate(header)
end

local function wait_for_body()
    showItems(body)
end

local function Screen()
    parallel.waitForAny(wait_for_header,wait_for_body)
end

if not monitor then
    error("no monitor")
    return
end

if modem then
    while true do
        parallel.waitForAny(wait_for_Event,Screen)
    end
end