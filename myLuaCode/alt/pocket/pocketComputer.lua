local EventList={}
local startUpTime=os.clock()
local modem=peripheral.find("modem")
if not modem then
    print("Fehlgeschlagen modem konnte nicht gefunden werden")
    return
end
local Alarme={}
local Tasten={["t"]="Zeitangabe",["m"]="modemVerbindung",["c"]="craftingJob",["s"]="schmelzen"}
local sockets={[9]="button"}
local server=9
if modem then
    modem.open(2206)
else
    print("Verbindung mit Modem ist Fehlgeschlagen!")
end

local function itemRequest()
    local Ort,item,Anzahl,slot,inventory
    modem.open(server)
    if modem.isOpen() then
        modem.transmit(server,2206,{"push",inventory,slot,itemName,itemAnzahl})
        modem.close(server)
    else
        print("Verbindung fehltgeschlagen")
    end
end





local function createSettings()
    return
end

local function dayTime()
    shell.execute("time")
end

local function runTime()
    return os.clock()
end
dayTime()
local function starting()
    print("System wird hochgefahren...")
    local id=os.setAlarm(0)
    Alarme[id]="Mitternacht"
end

local function bildschirmHandler(button,x,y)
    for i,socket in pairs(sockets) do
        return socket
    end
    return nil
end

local function eventCatcher()
    local counter=1
    while EventList[counter] do
        counter=counter+1
    end
    EventList[counter]={os.pullEvent()}
end
local function countEvents()
    local counter=0
    for index, value in ipairs(EventList) do
        counter=counter+1
    end
    return counter
end

local function waiting()
    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("warte auf Event")
        for i,v in pairs(Tasten) do
            print("druecke: ",i," fuer ",v)
        end
        print(("es sind %d Events die noch bearbeitet werden muessen"):format(countEvents()))
        os.sleep(1)
        term.clear()
        term.setCursorPos(1,1)
        print("warte auf Event.")
        for i,v in pairs(Tasten) do
            print("druecke: ",i," fuer ",v)
        end
        os.sleep(1)
        term.clear()
        term.setCursorPos(1,1)
        print("warte auf Event..")
        for i,v in pairs(Tasten) do
            print("druecke: ",i," fuer ",v)
        end
        os.sleep(1)
        term.clear()
        term.setCursorPos(1,1)
        print("warte auf Event...")
        for i,v in pairs(Tasten) do
            print("druecke: ",i," fuer ",v)
        end
    end
end
local function handleModemMessage(Event)
    local event, side, channel, replyChannel, message, distance=table.unpack(Event)
    print("es wurde eine:",event
    ,"\n von:",side
    ,"\n in channel",channel
    ,"\n mit antwort Channel:",replyChannel
    ,"\n und der Nachricht:",message
    ,"\n aus ",distance,"Bloecken Entfernung Empfangen")
end

local function handleAlarms(Event)
    local event,id=table.unpack(Event)
    for i,alarm in ipairs(Alarme) do
        if id==i then
            print("Es wurde Alarm:",id,"fuer:",alarm,"ausgeloeßt")
            if alarm=="Mitternacht" then
                local id=os.setAlarm(0)
                Alarme[id]="Mitternacht"
            end
        end
    end
end

local function keyHandler(Event)
    local event, key, is_held = table.unpack(Event)
            print(("%s held=%s"):format(keys.getName(key), is_held))
            if keys.getName(key)=="t" then
                runTime()
                dayTime()
            elseif keys.getName(key)=="m" then
                shell.run("modemManager")
            elseif keys.getName(key)=="s" then
                print("s was pressed")
                local schmelzManagerID=shell.openTab("schmelzManager")
                multishell.setTitle(schmelzManagerID,"SchmelzManager")
                multishell.setFocus(schmelzManagerID)
            elseif keys.getName(key)=="i" then
                itemRequest()
            elseif keys.getName(key)=="c" then
                print("c was pressed")
                local craftingManagerID=shell.openTab("craftingManager")
                multishell.setTitle(craftingManagerID,"CraftingManager")
                multishell.setFocus(craftingManagerID)
            elseif keys.getName(key)=="g" then
                print("g was pressed")
                local gpsTrackerID=shell.openTab("gpsTracker")
                multishell.setTitle(gpsTrackerID,"GPS")
                multishell.setFocus(gpsTrackerID)
            elseif keys.getName(key)=="t" then
                print("t was pressed")
                local turtleManagerID=shell.openTab("turtleManager")
                multishell.setTitle(turtleManagerID,"TurtleManager")
                multishell.setFocus(turtleManagerID)
            end
end

local function handleMouseclick(Event)
    local event, button, x, y = table.unpack(Event)
            if button==2 then
                os.shutdown()
            else
                local socket=bildschirmHandler(button,x,y)
                print("du hast:",socket," angeklickt")
            end
end
local function eventHandler()
    local currentEvent
    for i,v in ipairs(EventList) do
        if v then
            currentEvent=v
            EventList[i]=nil
        end
    end
        if currentEvent[1]=="modem_message" then
            handleModemMessage(currentEvent)
        elseif currentEvent[1]=="Alarm" then
            handleAlarms(currentEvent)
        elseif currentEvent[1]=="key" then
            keyHandler(currentEvent)
        elseif currentEvent[1]=="mouse_click" then
            handleMouseclick(currentEvent)
        end
    end
end

while true do
    parallel.waitForAny(eventCatcher,waiting,eventHandler())
end