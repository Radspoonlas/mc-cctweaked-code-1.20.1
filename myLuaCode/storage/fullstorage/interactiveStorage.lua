local cache={}
local itemSaves={}
local smelters={}
local smeltersPeripheral={peripheral.find("minecraft:furnace")}
smelters.free=0
local output=peripheral.find("minecraft:dropper")
local burntime={
    ["minecraft:coal"]=80,
    ["minecraft:charcoal"]=80,
    ["minecraft:dried_kelp"]=200,
    ["minecraft:lava_bucket"]=1000,
    ["minecraft:coal_block"]=800,
    ["minecraft:blaze_rod"]=120,
    ["minecraft:bamboo_planks"]=15,
    ["minecraft:bamboo"]=2.5,
}

local inputs={peripheral.find("minecraft:chest")}
local storage={peripheral.find("minecraft:barrel")}
local monitor=peripheral.find("monitor")
local monSizeX,monSizeY=monitor.getSize()
local plants={members={"mushroom","seed","pumpkin"
,"melon","carrot","potato","beetroot","wheat"
,"sugar","fruit","kelp"},
color=colors.green}
local wood={members={
    "oak",
    "birch",
    "crimson",
    "warped",
    "acacia",
    "jungle",
    "cherry",
    "spruce"
},color=colors.brown}
local rocks={members={
    "stone",
    "diorit",
    "andesit",
    "granite",
    "tuff",
},color=colors.lightGray}
local ressource={members={
    "iron",
    "copper",
    "diamond",
    "gold",
    "emerald",
    "lapis"
},color=colors.yellow}
local redstuff={
    members={
        "redstone",
        "piston",
        "observer",
        "dropper",
        "hopper",
        "repeater",
        "sensor"
    }
}
local coolegories={plants,rocks,redstuff,ressource,wood}
local completion = require "cc.completion"
local cmdHistory={"monitor","getCount","storeItems","searchItem minecraft:"}
local cmdChoices={"searchItem minecraft:","storeItems","monitor","getCount minecraft:"}
local sortedList={}

local function searchItem(itemName,cnt)
    for _,barrel in pairs(storage) do
        for i,item in pairs(barrel.list()) do
            if item and item.name==itemName then
               local pulled=peripheral.find("minecraft:dropper").pullItems(peripheral.getName(barrel),i,cnt)
               print("found Item")
               if pulled==cnt then
                return
               end
            end
        end
    end
    print("found no more of that item")
end

local function getItemPos(itemName)
    for _,barrel in pairs(storage) do
        for i,item in pairs(barrel.list()) do
            if item and item.name==itemName then
                local pos={["name"]=peripheral.getName(barrel),["slot"]=i}
               return pos
            end
        end
    end
end


local function monitorClear()
    print("called monitorClear")
    local posx,posy=monitor.getCursorPos()
    monitor.setCursorPos(1,1)
    local _,y=monitor.getCursorPos()
    while y<monSizeY+1 do
        monitor.clearLine()
        monitor.setCursorPos(1,y+1)
        _,y=monitor.getCursorPos()
    end
    monitor.setCursorPos(posx,posy)
end



local function monitorGraph(list)
    monitor.setBackgroundColor(colors.lime)
    monitorClear()
    monitor.setCursorPos(monSizeX-3,0)
    monitor.write("G")
    monitor.setCursorPos(monSizeX-1,0)
    monitor.setBackgroundColor(colors.red)
    monitor.write("X")
    monitor.setCursorPos(0,0)
    monitor.setBackgroundColor(colors.lime)
    monitor.setCursorPos(0,monSizeY)
    return
end

local function monitorColoring(name)
    for _, category in pairs(coolegories) do
        for _, member in pairs(category.members) do
            if name:match(member) then
                return category.color
            end
        end
    end
    return colors.orange
end


local function monitorScrollItems()
    sortedList={}
    local o=1
    for _,entry in pairs(itemSaves) do
        sortedList[o]=entry
        o=o+1
    end
    table.sort(sortedList,function(a,b) return a.count>b.count end)
    local posx,posy=monitor.getCursorPos()
    while true do
        for j,item in ipairs(sortedList)do
            if (posy>monSizeY) then
                if posx==monSizeX*0.5 then
                    posx=1
                else
                    posx=monSizeX*0.5
                end
                posy=0
            end
            monitor.setBackgroundColor(monitorColoring(item.name))
            for i=0,monSizeX/2-2 do
                monitor.setCursorPos(posx+i,posy)
                monitor.write(" ")
            end
            monitor.setCursorPos(posx,posy)
            monitor.write(item.name:gsub("minecraft:",''))
            if posx>=monSizeX/2 then
                monitor.setCursorPos(posx+monSizeX*0.75,posy)
            else
                monitor.setCursorPos(posx+monSizeX*0.25,posy)
            end
            monitor.write(item.count)
            monitor.setCursorPos(posx,posy+1)
            posx,posy=monitor.getCursorPos()
            os.sleep(1)
        end
    end
end

local function monitorTouch()
    while true do
        local _, _, x, y =os.pullEvent("monitor_touch")
        if (x<monSizeX+1 and x>monSizeX-5) and (y>=0 and y<10) then
            return
        end
        if (x>4 and x<10) and (y>=11 and y<15) then
            monitorGraph()
            return
        end
    end
end

local function button(posx,posy,width,height,fun,symbol,color)
    while true do
    monitor.setCursorPos(posx,posy)
    for i=1,width do
        for j=1,height do
            monitor.setCursorPos(posx+i,posy+j)
            monitor.setBackgroundColor(color)
            monitor.write(" ")
        end
    end
    monitor.setCursorPos(posx+width/2,posy+height/2)
    monitor.write(symbol)
    local = _,_,x,y=os.pullEvent("monitor_touch")
    if (x<=posx+width)and (x>=posx) and (y>=posy) and (y<=posy+heigth) then
        fun
    end
    end
end

local function defaultMenu()
    monitor.setBackgroundColor(colors.lime)
    monitorClear()
    button(monSizeX-1,0,5,5,return,x,colors.red)
    monitor.setCursorPos(0,0)
    monitor.setBackgroundColor(colors.lime)
end
local function manufactureItem()
    print("called manufactureItem")
    defaultMenu()
    local reply=monitorTouch()
    monitor.write("select whwat item you wish to manifacture: ")
    local craftables={}
    local buttons={}
    for i=1,#craftables do
        for i,item in craftables do
            bottons[i]={x=monSizeX/i,y=monSizeY,width=2,height=2,fun=fun,symbol=item,color=colors.lightBlue}
        end
    end
    local reply= parallel.waitForAny(function() for i,v in buttons do button(v.x,v.y,v.width,v.height,v.fun,v.symbol,v.color )end)
    if reply==1 then
        pass--TODO: missing function handling
    end
    return
end

local function viewItems()
    print("called viewItems")
    monitor.setBackgroundColor(colors.lime)
    monitorClear()
    monitor.setBackgroundColor(colors.purple)
    for i=-1,4,1 do
        monitor.setCursorPos(monSizeX,7-i)
        monitor.write(" ")
    end
    monitor.setCursorPos(monSizeX,7)
    monitor.write("G")
    monitor.setBackgroundColor(colors.red)
    for i=-1,4,1 do
        monitor.setCursorPos(monSizeX,3-i)
    end
    monitor.setCursorPos(monSizeX,3)
    monitor.write("X")
    monitor.setCursorPos(1,1)
    monitor.setBackgroundColor(colors.orange)
    monitor.setTextColor(colors.black)
    local outcome=parallel.waitForAny(monitorTouch,monitorScrollItems)--TODO:extend functionality for interaction with monitor
end

local function storeItem(ItemName,slot,fromInv)
    --print("called fun storeItem")
    for j,barrel in pairs(storage) do
        local items=barrel.list()
        for i = 1, 27 do
            if items[i] then
                if items[i].name==ItemName and (items[i].count<barrel.getItemDetail(i).maxCount) then
                    --print("found same item")
                    barrel.pullItems(fromInv,slot)
                    return
                end
            else
                barrel.pullItems(fromInv,slot)
                return
            end
        end
    end
end

local function storeItems()
    --print("got into storeitems")
    monitor.setBackgroundColor(colors.brown)
    monitorClear()
    monitor.setCursorPos(monSizeX/2,monSizeY/2)
    monitor.write("storing items...")
    for i,item in pairs(output.list()) do
        print(i,item)
        print(item.name)
        storeItem(item.name,i,peripheral.getName(output))
    end
    for key,smelter in pairs(smelters) do 
        local item=smelter.getItemDetail(3)
        if item and item.name then
            storeItem(item.name,3,peripheral.getName(smelter))
        end
    end
    --print(#inputs,inputs[1])
    for n=1,#inputs do
        --print(#inputs[n].list(),inputs[n].list())
        for i=1,#inputs[n].list() do
            local item=inputs[n].getItemDetail(i)
            if item then
                storeItem(item.name,i,peripheral.getName(inputs[n]))
            end
        end
    end

end

local function loadSearchBar()
    local abc={}
    for i,24 do
            abc={}
    end
    local word=""
    while true do

    local reply= parallel.waitForAny(function() for i,v in buttons do button(v.x,v.y,v.width,v.height,v.fun,v.symbol,v.color )end)
    --TODO> implementation of writing selected text on screen and saving + being able to search for item through touch
        word=word..toString(reply)
        if reply==25 then
            return word
        end
    end
end



local function monitorFillLine(character)
    print("called monitorFillLine")
   local posx,posy=monitor.getCursorPos()
   monitor.setCursorPos(0,posy)
   local x,_=monitor.getCursorPos()
   while x<monSizeX do
        monitor.write(character)
        monitor.setCursorPos(x+1,posy)
<<<<<<< HEAD:myLuaCode/storage/fullstorage/interactiveStorage.lua
        x,_=monitor.getCursorPos()
        print(x)
=======
        x,y=monitor.getCursorPos()
        --print(x)
>>>>>>> 8cb6df9690f1b563db0e687acaac501d3d21a90b:myLuaCode/interactiveStorage.lua
   end
   monitor.setCursorPos(posx,posy)
end

local function monitorFillVertical(character)
    print("called monitorFillvertical")
   local posx,posy=monitor.getCursorPos()
   monitor.setCursorPos(posx,0)
   local _,y=monitor.getCursorPos()
   while y<monSizeY do
        monitor.write(character)
        monitor.setCursorPos(posx,y+1)
       _,y=monitor.getCursorPos()
   end
   monitor.setCursorPos(posx,posy)
end

local function monitorMainMenu()
    print("called monitorMainMenu")
    monitor.setBackgroundColor(colors.orange)
    monitorClear()
    monitor.setCursorPos(monSizeX/2,monSizeY/2)
    monitor.write("+")
    monitorFillLine("-")
    monitorFillVertical("|")
    monitor.setBackgroundColor(colors.white)
    monitor.setTextColor(colors.black)
    monitor.setTextScale(1.4)
    buttons={{monSizeX*0.25,monSizeY*0.25,1,1,storeItems,"storeItems",colors.green},
    {monSizeX*0.75,monSizeY*0.25,1,1,searchItem,"searchItem",colors.lightBlue},
    {monSizeX*0.75,monSizeY*0.75,1,1,manufactureItem,"manufactureItem",colors.orange},
    {monSizeX*0.25,monSizeY*0.75,1,1,viewGraph,"viewIems",colors.yellow}}
    local reply= parallel.waitForAny(function() for i,v in buttons do button(v.x,v.y,v.width,v.height,v.fun,v.symbol,v.color )end)
    if reply==1 then
        --TODO: implementation of handling of functions or smth
    end
    monitor.setTextScale(1)
    monitor.setTextColor(colors.white)
    monitor.setBackgroundColor(colors.orange)
end
<<<<<<< HEAD:myLuaCode/storage/fullstorage/interactiveStorage.lua
local function monitorWaiting()
    print("called monitorWaiting")
    local _, _, x, y =os.pullEvent("monitor_touch")
    if x<monSizeX/2 then
        if y<monSizeY/2 then
            storeItems()
        else
            viewItems()
        end
    else
        if y<monSizeY/2 then
            loadSearchBar()
            searchItem("kekw")
        else
            manufactureItem()
        end
    end
    monitorMainMenu()
    monitorWaiting()
end
=======

>>>>>>> 8cb6df9690f1b563db0e687acaac501d3d21a90b:myLuaCode/interactiveStorage.lua
local function monitorLoadingBar(frac)
    monitor.setTextScale(1.4)
    monitor.setBackgroundColor(colors.green)
    monitorClear()
    monitor.setCursorPos(monSizeX-1,monSizeY/2)
    monitor.write("]")
    monitor.setCursorPos(1,monSizeY/2)
    monitor.write("[")
    for i=2,frac*monSizeX do
        monitor.write("#")
        monitor.setCursorPos(i,monSizeY/2)
    end
    monitor.setTextScale(1)
    monitor.setTextScale(1)
end
-- jeder ofen bekommt einen eigenen  füllzustand,fueltyp,timer für die fuelmenge(und füllmenge),seinen peripheral table 
local function checkFurnacesAvailability()
    for index, smelter in ipairs(smeltersPeripheral) do
        smelters[peripheral.getName(smelter)]={}
        smelters[peripheral.getName(smelter)].name=peripheral.getName(smelter)
        if not smelter.getItemDetail(1) and not smelter.getItemDetail(1).name then
            smelters.free=smelters.free+1

            smelters[peripheral.getName(smelter)].fuel={}
            smelters[peripheral.getName(smelter)].fuel.name=""
            smelters[peripheral.getName(smelter)].fuel.count=0
             smelters[peripheral.getName(smelter)].fuel.limit=0
             smelters[peripheral.getName(smelter)].item={}
             smelters[peripheral.getName(smelter)].item.name=""
            smelters[peripheral.getName(smelter)].item.count=0
             smelters[peripheral.getName(smelter)].item.limit=0

             smelters[peripheral.getName(smelter)].timerID=0
            smelters[peripheral.getName(smelter)].available=true
        else
            local itemDetail=smelter.getItemDetail(2)
            smelters[peripheral.getName(smelter)].fuel={}
            smelters[peripheral.getName(smelter)].fuel.name=itemDetail.name
            smelters[peripheral.getName(smelter)].fuel.count=itemDetail.count
             smelters[peripheral.getName(smelter)].fuel.limit=smelter.getItemLimit(2)
             smelters[peripheral.getName(smelter)].item={}
             smelters[peripheral.getName(smelter)].item.name=itemDetail.name
            smelters[peripheral.getName(smelter)].item.count=itemDetail.count
             smelters[peripheral.getName(smelter)].item.limit=itemDetail

             smelters[peripheral.getName(smelter)].timerID=os.startTimer(burntime[itemDetail.name]*itemDetail.count)
            smelters[peripheral.getName(smelter)].available=false
        end
    end
end

local function smeltItem(item,count)
    if count<=0 then
        print("hahaha ur such a JOKEster")
        return
    end
    if smelters.free==0 then
        print("no smelters available srry :(")
        return
    end
    if itemSaves[item]==0 then
        print("no more of that item")
        return
    end
    if itemSaves[item].count<count then--check if available items is more than requested
        count=itemSaves[item].count
    end
    local draw=count
    for k, smelter in pairs(smelters) do
        if smelter.item.name==item then--check if the same item is already smelting
            if smelter.item.count<smelter.item.limit then-- check if slot is full
                local furnace=peripheral.wrap(smelter.name)--current furnace
                local burnAmount=burntime[smelter.fuel.name]/10 --amount of items that can be burned with one measure of fuel
                
                if draw>=burnAmount and burnAmount<=(smelter.item.limit-smelter.item.count) then
                    local pulled=furnace.pullItems(getItemPos(),draw-draw%burnAmount,1)
                    --TODO FUEL
                    while (pulled<(smelter.item.count-smelter.item.limit)) do
                        local pos=getItemPos()
                        pulled=pulled+furnace.pullItems(pos)
                    end
                    smelter.item.count=smelter.item.count+pulled
                    itemSaves=itemSaves-pulled
                    --check fuel count
                    if smelter.item.count==0 then
                        return
                    end
                end
            end
        end
    end
    for k, smelter in pairs(smelters) do
        if smelter.available then
            local furnace=peripheral.wrap(smelter.name)
            local pulled=furnace.pullItems(getItemPos())
            while (pulled<(smelter.item.count-smelter.item.limit)) do
                local pos={table.unpack(getItemPos()),count,1}
                if pos.slot==0 then
                    print("no more of that item")
                    return
                end
                pulled=pulled+furnace.pullItems(pos)
            end
            smelter.item.count=smelter.item.count-pulled
            if smelter.item.count==0 then
                return
            end
        end
    end
end

local function itemSavesCreate()
    print("called itemSavesCreate")
    for i,inv in pairs(storage) do
        for j,item in pairs(inv.list()) do
            term.clear()
            term.setCursorPos(1,1)
            print("at inventory: "..i.." / "..#storage.." and slot: "..j.." / 27")
            monitorLoadingBar((i/#storage))
            term.setCursorPos(50,4)
            term.write("]")
            term.setCursorPos(1,4)
            term.write("[")
            for h=3,(i/#storage)*100 do
                term.setCursorPos(h/2,4)
                term.write("|")
            end
            if itemSaves[item.name] then
                itemSaves[item.name].count=itemSaves[item.name].count+item.count
            else
                itemSaves[item.name]={}
                itemSaves[item.name].count=item.count
                itemSaves[item.name].name=item.name
            end
        end
    end
end

local function handleInput()
    while true do
        print("please enter either: 'storeItems' or 'searchItem itemName'")
        term.write(">")
        local msg=read(nil,cmdHistory,function(text) return completion.choice(text,cmdChoices) end,nil)
        print(msg)
        if msg:match('storeItems') then
            --print("got into storeitems")
            local output=peripheral.find("minecraft:dropper")
            local inputs={peripheral.find("minecraft:chest")}
            for i,item in pairs(output.list()) do
                print(i,item)
                print(item.name)
                storeItem(item.name,i,peripheral.getName(output))
            end
            --print(#inputs,inputs[1])
            for n=1,#inputs do
                --print(#inputs[n].list(),inputs[n].list())
                for i=1,#inputs[n].list() do
                    local item=inputs[n].getItemDetail(i)
                    if item then
                        storeItem(item.name,i,peripheral.getName(inputs[n]))
                    end
                end
            end
        elseif msg:match('searchItem') then
            msg=msg:gsub("searchItem ",'')
            print("count?: ")
            local cnt=read(nil,{"64"},function(text) return completion.choice(text,{"1","16","64"}) end,nil)
            if not cnt then
                cnt="64"
            end
            cnt=tonumber(cnt)
            if type(cnt)~="number" then
                cnt="64"
            end
            print("searching for:")
            print(msg .. " ".. cnt)
            searchItem(msg,cnt)
        elseif msg:match('getCount') then
            msg=msg:gsub("getCount ",'')
            print(itemSaves[msg].count)
        elseif msg:match('smelt') then
            msg=msg:gsub("smelt ",'')
            print("count?: ")
            local cnt=read(nil,{"64"},function(text) return completion.choice(text,{"1","16","64"}) end,nil)
            if not cnt then
                cnt="64"
            end
            cnt=tonumber(cnt)
            if type(cnt)~="number" then
                cnt="64"
            end
            smeltItem(msg,cnt)
        end
    end
end

local function updateSmelters()
    while true do
        for index, smelter in ipairs(smelters) do
            smelter.fuel.count=smelter.fuel.count-1
            if smelter.fuel.count==0 then
                smelter.fuel.limit=0
                smelter.fuel.name=""
                smelter.item.limit=0
                smelter.item.count=0
                smelter[peripheral.getName(smelter)].available=true
                smelters.free=smelters.free+1
            else
                smelters.fuel.count=smelters.fuel.count-1
                smelters.item.count=smelters.item.count-burntime[smelters.fuel.name]/10
                smelters.timerID=os.startTimer(burntime[smelters.fuel.name])
            end
        end
    end
end

local function storeItemsTimer()
    while true do
        os.sleep()
        storeItems()
    end
end
local function updater()
     parallel.waitForAll(updateSmelters,storeItemsTimer) 
end
itemSavesCreate()
monitorMainMenu()
checkFurnacesAvailability()
monitor.setCursorBlink(true)
while true do
<<<<<<< HEAD:myLuaCode/storage/fullstorage/interactiveStorage.lua
    parallel.waitForAll(monitorWaiting,handleInput,updater) 
end
=======
    parallel.waitForAll(monitorWaiting,handleInput) 
end
>>>>>>> 8cb6df9690f1b563db0e687acaac501d3d21a90b:myLuaCode/interactiveStorage.lua
