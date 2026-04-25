local EventList={}
local currentRequests=0
local totalRequests=0
local myChannel=22069
local ovenList={}
local ovens={peripheral.find("minecraft:furnace")}

local modems={peripheral.find("modem")}
local modem
for i,m in pairs(modems) do
    if m.isWireless() then
        modem=m
        break
    end
end
assert(modem~=nil)
modem.open(22069)
local storageChannel=22065
local function send(channel,replyChannel,contents)
    assert(type(channel)=="number")
    assert(type(replyChannel)=="number")
    assert(type(contents)=="table")
    if  modem then
        modem.open(channel)
        modem.transmit(channel,myChannel,contents)
        modem.close(channel)
    end
end

local function sortRequest(oven)
    send(storageChannel,22069,{cmd="sortItem",inventory=peripheral.getName(oven),slot=3})
end

local function fuelRequest(count,oven)
    send(storageChannel,22069,{cmd="pushRequest",name="minecraft:bamboo_plank",count=count,inventory=peripheral.getName(oven),slot=2})
end

local function ovenCheck()
    print("starting ovenCheck")
    while true do
    for i,oven in pairs(ovens) do
        if oven.getItemDetail(3) then
            print("sending request for:",peripheral.getName(oven),"item:",oven.getItemDetail(3).name)
            sortRequest(oven)
        end
        if oven.getItemDetail(1) then
            ovenList[i]=false
            if not oven.getItemDetail(2) then
                fuelRequest(oven.getItemDetail(1).count,oven)
            end
        else
            ovenList[i]=true
        end
    end
    os.sleep(60)
    end
end



local function pushRequest(channel,replyChannel,itemName,itemCount,Inventory)
    send(channel,replyChannel,{cmd="pushRequest",name=itemName,count=itemCount,inventory=peripheral.getName(Inventory),slot=1})
end

local function countRequest(channel,replyChannel,itemName)
    print("sending count request...")
    send(storageChannel,myChannel,{cmd="getCount",name=itemName})
    local message
    while not message do
        for i,v in pairs(EventList) do
            for j,k in pairs(v) do
                print(j,k)
                if j==5 then
                    for l,f in pairs(k) do
                        print(l,f)
                    end
                end
            end
            if v[4]==storageChannel and v[5] and v[5].count then
                message=v[5]
            end
        end
        os.sleep(1)
    end
    print("got answer:",message.count)
    return message.count
end

local function smeltReply(args)
    local itemName=args.name
    local count=args.count
    local channel=args.replyChannel
    local replyChannel=args.channel
    local itemcnt=countRequest(channel,myChannel,itemName)
    if itemcnt<count then
        count=itemcnt
    end
    print("now checking ovens...")
    print("ovens:",#ovens)
    for i,oven in pairs(ovens) do
        if oven then
            if count>64 then
                print("more than 64 items smelt requested")
                pushRequest(channel,replyChannel,itemName,64,oven)
                print("sending Fuel req")
                fuelRequest(64,oven)
            else
                print("less or 64 items smelt requested")
                pushRequest(channel,replyChannel,itemName,count,oven)
                print("sending Fuel req")
                fuelRequest(count,oven)
                ovenList[i]=true
                break
            end
            ovenList[i]=true
        end
    end
    print("done with smeltReply, sending answer:")
    send(channel,replyChannel,{cmd="smelt",reply=true})
end

local function addEvent(Event)
    table.insert(Event,os.clock())
    table.insert(EventList,Event)
    totalRequests=totalRequests+1
    currentRequests=currentRequests+1
end

local function getEvent()
    currentRequests=currentRequests-1
    return table.remove(EventList)
end

local function wait_for_Event()
    while true do
        print("waiting...")
        Event={os.pullEvent("modem_message") }
        print("gotEvent:",Event[1])
        if Event then
            addEvent(Event)
        end
        print(#EventList)
        print("did Event")
    end
end

local EventHandler={{name="smeltItem",fun=smeltReply}}
local function wait_for_workEvent()
    while true do
        if #EventList==0 then
            os.sleep(2)
            --print("waiting for work...")
        else
            Event=getEvent()
            local event, side, channel, replyChannel, message, distance = table.unpack(Event)
            print("handling Event:")
            print("msg:",message.cmd)
            for i,entry in ipairs(EventHandler) do
                if entry.name==message.cmd then
                    print(entry.name)
                    entry.fun({channel=channel,replyChannel=replyChannel,count=message.count,name=message.name,inventory=message.inventory,slot=message.slot})
                    break
                end
            end
        end
    end
end
parallel.waitForAny(wait_for_Event,wait_for_workEvent,ovenCheck)