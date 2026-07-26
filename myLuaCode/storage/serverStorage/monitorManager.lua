--imports
local modem=require "modemManager"
local eventHandler=require "eventHandler"
local expect=require "cc.expect"

--channels(hardcoded)
local monitorChannel=22068
local serverChannel=22061

--colors hardcoded
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

local itemList

--monitor init
local monitors={peripheral.find("monitor")}
local monitor
local biggestx,biggesty=0,0
for i,mon in pairs(monitors) do 
    local monsizex,y=mon.getSize()
    if monsizex>biggestx then
        monitor=mon
    end
end

--default values hardcoded
local maxX,maxY=monitor.getSize()
local header={x1=1,x2=maxX,y1=1,y2=3}
local body={x1=1,x2=maxX,y1=header.y2+1,y2=maxY}
local textSize=1

--functions
--returns correct Itemcolor for item itemName
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

--aufteilung des monitors
local function monitorDistribution()
    for i,v in pairs(distr) do
    end
    local distr={header,body}
    return distr
end

--soll items in ItemList über x1,y1 bis x2,y2 anzeigen
local function showItems(format)
    print("now in showItems")

    monitor.setTextScale(textSize)
    monitor.setTextColor(colors.black)
    local posX,posY=format.x1,format.y1

    local sortedList={}
    for item,values in pairs(itemList) do
        print(item,values)
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

local function setItemList(args)
    for i,v in pairs(args) do   
        print(i,v)
        if i=="list" or v=="list" then
            print("this is itemlist:")
            for j,s in pairs(v) do
                print(j,s)
            end
            print("end of itemList")
        end
    end
    itemList=args.list
end

local function getItemList()
    while not itemList do
        modem:send(serverChannel,monitorChannel,{cmd="getItemList"})
        os.sleep(10)
    end
end
--init
if not monitor then
    error("no monitor")
    return
end
local handle={
    {name="itemList",fun=setItemList},
}
eventHandler:makeHandle(handle)
modem:newWireless()
modem:openChannel(monitorChannel)
--main
print("requesting ItemList...")
    while not itemList do
        parallel.waitForAny(function () eventHandler:wait_for_Event()end,
        function() eventHandler:wait_for_workEvent() end,getItemList)
    end
    print("got ItemList!")
    while true do
        parallel.waitForAny(function () eventHandler:wait_for_Event()end,
        function() eventHandler:wait_for_workEvent() end,Screen)
    end
