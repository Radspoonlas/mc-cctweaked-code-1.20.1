

local function prepareBackground()
    term.setBackgroundColor(colours.blue)
    term.setTextColour(colours.white)
    term.clear()
    local x,y=term.getSize()
    for i=1,y do
        term.setCursorPos(1,i)
        print("")
    end
end

local landmarks={}
local rightclick=false
local leftclick=false
local middleclick=false
local function listener()
    while true do
        local Event={os.pullEvent("mouse_click")}
        if Event[2]==2 then
            rightclick=true
            return
        elseif Event[2]==1 then
            leftclick=true
        elseif Event[2]==3 then
            middleclick=true
        end
    end
end

local function gpsUpdate( ... )
    sleep(0)
    local x,y,z=gps.locate()
    term.clear()
    print(("distance to gps x: %d y:%d z:%d "):format(x,y,z))
    for i,v in ipairs(landmarks)do
        print(("distance to %s x: %d y:%d z:%d "):format(x,y,z))
    end
end

local function createLandmark( ... )
    print("Bitte gebe den Namen des Eintrags ein:")
    local landmark=read()
    print(landmark)
    print("bitte gib den Channel an durch welchen dieses angepingt werden kann.")
    local channel=tonumber(read())
    landmarks[landmark]=channel
    print(("landmark %s wurde erstellt mit channel %d"):format(landmark,channel))
    print("nutze rechtsklick um zuruekkehren zu koennen")
    sleep(10)
end

local function undo()
    local Event={os.pullEvent("mouse_click")}
    if Event[2]==2 then
        return
    end
end

local function pingChannel(landmark)
    local modem=peripheral.find("modem")
    if not modem then
        print("failed connection")
        return
    end
    modem.open(landmark)
    while true do
        modem.transmit(landmark,2206,{"distance"})
        local Event=os.pullEvent "modem_message"
        local event, side, channel, replyChannel, message, distance = table.unpack(Event)
        term.clear()
        term.setCursorPos(1,1)
        term.write(("Distanz zur Sehenswürdigkeit ist:%d"):format(distance))
    end
   
    modem.close(landmark)
end

local function chooseLandmark()
    local mX,mY=term.getSize()
    term.clear()
    term.setCursorPos(1,1)
    print("Bitte Waehle eine Sehenswürdigkeit aus:")
    local count=0
    for i,landmark in pairs(landmarks) do
        if i%2==0 then
            term.setBackgroundColour(colours.cyan)
            term.setCursorPos(mX/2,(mY/#landmarks*count)+1)
            print(i)
        else
            term.setBackgroundColor(colours.lightBlue)
        end
    end
    local count=0
    local Event={os.pullEvent("mouse_click")}
    if Event[2]==2 then
        local x,y=Event[3],Event[4]
        for i,v in pairs(landmarks) do
            if y==(mY/#landmarks*count)+1 then
                pingChannel(landmarks)
                return
            end
        end
    end
    sleep(10)
end


while not rightclick do
    if leftclick then
        parallel.waitForAny(undo,chooseLandmark)
    end
    if middleclick then
        parallel.waitForAny(undo,createLandmark)
    end
    parallel.waitForAny(listener,gpsUpdate)
end