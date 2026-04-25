local EventHandler={statistics={totalRequests=0,currentRequests=0,deadRequests=0},EventList={},handler={}}

function EventHandler:new(o)
    o=o or {}
    setmetatable(o,self)
    self.__index =self
    print(#self.handler)
    return o
end

function EventHandler:add(Event)
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
        print("waiting...")
        Event={os.pullEvent("modem_message") }
        if Event then
            EventHandler:add(Event)
        end
        print("did Event")
    end
end


function EventHandler:makeHandle(handle)
    for i,entry in pairs(handle) do
        table.insert(self.handler,entry)
    end
    
    print("made handler:",#self.handler)
end

function EventHandler:wait_for_workEvent()
    while true do
        if #EventHandler.EventList==0 then
            os.sleep(1)
            --print("waiting for work...")
        else
            print("handling Event:")
            local Event= EventHandler:getEvent()
            local event, side, channel, replyChannel, message, distance = table.unpack(Event)
            print("msg:",message.cmd)
            print(#self.handler)
            for i,entry in ipairs(self.handler) do
                if entry.name==message.cmd then
                    print(entry.name)
                    entry.fun({channel=channel,replyChannel=replyChannel,count=message.count,name=message.name,inventory=message.inventory,slot=message.slot})
                    break
                end
            end
        end
    end
end


return EventHandler