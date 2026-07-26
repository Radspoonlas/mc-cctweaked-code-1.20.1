local EventHandler={statistics={totalRequests=0,currentRequests=0,deadRequests=0},EventList={},handler={}}
local debugMODE=false
function EventHandler:new(o)
    o=o or {}
    setmetatable(o,self)
    self.__index =self
    print(#self.handler)
    return o
end

function EventHandler:add(Event)
    if debugMODE then print("ADDED EVENT TO EVENTLIST!!!!!!!!!!!!!!")end
    table.insert(Event,os.clock())
    table.insert(self.EventList,Event)
    self.statistics.totalRequests=self.statistics.totalRequests+1
end

function EventHandler:getEvent()
    return table.remove(self.EventList)
end

function EventHandler:getStatistics()
    return {self.statistics.totalRequests,self.statistics.currentRequests,self.statistics.deadRequests}
end


function EventHandler:wait_for_Event()
    while true do
         if debugMODE then print("looking for Events")end
        local Event={os.pullEvent("modem_message") }
         if debugMODE then print("FOUND EVENT")end
        if Event then
            EventHandler:add(Event)
        end
    end
end


function EventHandler:makeHandle(handle)
    for i,entry in pairs(handle) do
        table.insert(self.handler,entry)
    end
     if debugMODE then print("made handler:",#self.handler)end
end

function EventHandler:wait_for_workEvent()
    while true do
        if #EventHandler.EventList==0 then
            os.sleep(1)
        else
            local Event= EventHandler:getEvent()
            local event, side, channel, replyChannel, message, distance = table.unpack(Event)
             if debugMODE then print("trying to find handler for: ",message.cmd)end
            for i,entry in ipairs(self.handler) do
                if entry.name==message.cmd then
                      if debugMODE then print("working event: ",entry.name)end
                    entry.fun({channel=channel,replyChannel=replyChannel,count=message.count,name=message.name,inventory=message.inventory,slot=message.slot,list=message.list})
                     if debugMODE then print("found eventHandler for Event ",entry.name)end
                    break
                end
            end
             if debugMODE then print("finished")end
        end
    end
end


return EventHandler