local args={...}
local modem=peripheral.find("modem")
if not modem then
    print("fehlende verbindung")
    return "connection"
end
local server=42
local completion=require "cc.completion"
local history={"cooked_potato","stick",}

local Item=nil
local Anzahl=nil
local rightclick=false

local function itemSchmelzen(itemName,itemAnzahl)
    if not itemAnzahl and not itemName then
        print("fehlendes argument")
        return
    end
    modem.open(server)
    modem.transmit(server,2206,{"schmelzen",itemName,itemAnzahl})
    modem.close(server)
end

local function prepareBackground()
    term.setBackgroundColor(colours.orange)
    term.setTextColour(colours.black)
    term.clear()
    local x,y=term.getSize()
    for i=1,y do
        term.setCursorPos(1,i)
        print("")
    end
end


local function schmelzen()
    local EingabeErlaubnis=true
    term.clear()
    prepareBackground()
    term.setCursorPos(1,2)
    term.write("gib einen ItemNamen ein:")
    Item=tostring(read(nil,history,function(text) return completion.choice(text,history) end))
    term.setCursorPos(1,3)
    print(Item)
    term.write(Item)
    Item="minecraft:" .. Item
    term.setCursorPos(1,5)
    term.write("gib die Anzahl an:")
    Anzahl=read()
    Anzahl=tonumber(Anzahl)
    itemSchmelzen(Item,Anzahl)
    print("smelting",Item,Anzahl)
    os.sleep(5)
end

local function listener()
    while not rightclick do
        local Event=os.pullEvent("mouse_click")
        if Event[2]==2 then
            print(Event[2])
            rightclick=true
            return
        end
    end
end

while not rightclick do
    parallel.waitForAny(listener,schmelzen)
end



