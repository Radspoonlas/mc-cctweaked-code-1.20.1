local modemManager={properties={isWireless=false},channels={},wlm=nil,wm=nil,openChannels={}}

local defaultchannelfile="myChannels.txt"

function modemManager:init(o)
    o=o or {}
    setmetatable(o,self)
    self.__index =self
    return o
end
function modemManager:send(channel,replyChannel,contents)
    assert(type(channel)=="number")
    assert(type(replyChannel)=="number")
    assert(type(contents)=="table")
    if self.wlm then
        self.wlm.open(channel)
        self.wlm.transmit(channel,replyChannel,contents)
        self.wlm.close(channel)
    end
end
function modemManager:openChannel(channel)
    self.wlm.open(channel)
end
function modemManager:newWireless(o)
    o=o or {}
    setmetatable(o,self)
    self.__index =self
    local modems={peripheral.find("modem")}
    for i,m in ipairs(modems) do
        if m.isWireless() then
            self.wlm=m
            return o
        else
            self.wm=m
        end
    end
    return false
end
function modemManager:new()
    self.wm=peripheral.find("modem")
    return self.newWireless() or self.wm
end

function modemManager:addChannel(channel,channelName)
    table.insert(self.channels,{name=channelName or ("channel:"..tostring(channel)),channel=channel})
end

function modemManager:removeChannel(channel,channelName)
    for i,entry in pairs(self.channels) do
        if entry.channel==channel or entry.name==channelName then
            table.remove(self.channels,i)
            return true
        end
    end
    return false
end

return modemManager