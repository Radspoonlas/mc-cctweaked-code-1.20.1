local cache={}
local itemSaves={}
local output=peripheral.find("minecraft:dropper")
local inputs={peripheral.find("minecraft:chest")}
local storage={peripheral.find("minecraft:barrel")}
local monitor=peripheral.find("monitor")
local monSizeX,monSizeY=monitor.getSize()
local plants={"mushroom","seed","pumpkin"
,"melon","carrot","potato","beetroot","wheat"
,"sugar","fruit","kelp"}
local completion = require "cc.completion"
local cmdHistory={"monitor","getCount","storeItems","searchItem minecraft:"}
local cmdChoices={"searchItem minecraft:","storeItems","monitor","getCount minecraft:"}
local sortedList={}

local function searchItem(itemName)
    for i,barrel in pairs(storage) do
        for i,item in pairs(barrel.list()) do
            if item and item.name==itemName then
               peripheral.find("minecraft:dropper").pullItems(peripheral.getName(barrel),i,64)
               --print("found Item")
               return
            end
        end
    end
end




local function monitorClear()
    print("called monitorClear")
    local posx,posy=monitor.getCursorPos()
    monitor.setCursorPos(1,1)
    local x,y=monitor.getCursorPos()
    while y<monSizeY+1 do
        monitor.clearLine()
        monitor.setCursorPos(1,y+1)
        x,y=monitor.getCursorPos()
    end
    monitor.setCursorPos(posx,posy)
end

local function manufactureItem()
    print("called manufactureItem")
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
    local posx,posy=monitor.getCursorPos()
    monitor.setCursorPos(0,monSizeY)
    return
end
local function monitorColoring(name)
    if name:match("iron") then
        return colors.white
    end
    if name:match("gold") then
        return colors.yellow
    end
    if name:match("diamond") then
        return colours.lightBlue
    end
    if name:match("plank") or name:match("log") or name:match("stick") or name:match("chest") then
        return colors.brown
    end
    if name:match("lapis") then
        return colors.blue
    end
    if name:match("stone") or name:match("diorite") or name:match("andesite")or name:match("granite")then
        
        return colors.lightGray
    end
    for i,plant in pairs(plants) do
        if name:match(plant) then
            return colors.green
        end
    end
    return colors.orange
end


local function monitorScrollItems()
    sortedList={}
    local o=1
    for e,entry in pairs(itemSaves) do
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
        local event, side, x, y =os.pullEvent("monitor_touch")
        if (x<monSizeX+1 and x>monSizeX-5) and (y>=0 and y<10) then
            return
        end
        if (x>4 and x<10) and (y>=11 and y<15) then
            monitorGraph()
            return
        end
    end
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
        monitor.setCursorPos(monSizeX,3)
    end
    monitor.setCursorPos(monSizeX,3)
    monitor.write("X")
    monitor.setCursorPos(1,1)
    monitor.setBackgroundColor(colors.orange)
    local i=0
    local posx,posy=monitor.getCursorPos()
    monitor.setTextColor(colors.black)
    local outcome=parallel.waitForAny(monitorTouch,monitorScrollItems)
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

end



local function monitorFillLine(character)
    print("called monitorFillLine")
   local posx,posy=monitor.getCursorPos()
   monitor.setCursorPos(0,posy)
   local x,y=monitor.getCursorPos()
   while x<monSizeX do
        monitor.write(character)
        monitor.setCursorPos(x+1,posy)
        x,y=monitor.getCursorPos()
        print(x)
   end
   monitor.setCursorPos(posx,posy)
end

local function monitorFillVertical(character)
    print("called monitorFillvertical")
   local posx,posy=monitor.getCursorPos()
   monitor.setCursorPos(posx,0)
   local x,y=monitor.getCursorPos()
   while y<monSizeY do
        monitor.write(character)
        monitor.setCursorPos(posx,y+1)
       x,y=monitor.getCursorPos()
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
    monitor.setTextScale(1)
    monitor.setCursorPos(monSizeX*0.25,monSizeY*0.25)
    monitor.write("storeItems")
    monitor.setCursorPos(monSizeX*0.75,monSizeY*0.25)
    monitor.write("searchItem")
    monitor.setCursorPos(monSizeX*0.75,monSizeY*0.75)
    monitor.write("manufactureItem")
    monitor.setCursorPos(monSizeX*0.25,monSizeY*0.75)
    monitor.write("viewItems")
    monitor.setTextScale(1)
    monitor.setTextColor(colors.white)
    monitor.setBackgroundColor(colors.orange)
end
local function monitorWaiting()
    print("called monitorWaiting")
    local event, side, x, y =os.pullEvent("monitor_touch")
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
            print("searching for:")
            print(msg)
            searchItem(msg)
        elseif msg:match('getCount') then
            msg=msg:gsub("getCount ",'')
            print(itemSaves[msg].count)
        end
    end
    
end

itemSavesCreate()
monitorMainMenu()
monitor.setCursorBlink(true)
while true do
    parallel.waitForAll(monitorWaiting,handleInput) 
end