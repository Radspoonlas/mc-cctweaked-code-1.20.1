EventHandler={myChannel=2206,messageHandlerList={},modem=nil}
local EventList={}

--empfaengt messages
function EventHandler.message_receive()
    while true do
        Event={os.pullEvent("modem_message")}
        table.insert(EventList,Event)
    end
end

--gibt Antwort
function EventHandler.sendAnswer(msg,replyChannel)
    EventHandler.modem.open(replyChannel)
    EventHandler.modem.transmit(EventHandler.myChannel,replyChannel,msg)
    if replyChannel==EventHandler.myChannel then
       return
    end
    EventHandler.modem.close(replyChannel)
end

--nimmt message aus der EventListe und arbeitet diese ab
function EventHandler.message_work()
    while true do
        local Event=table.remove(EventList)
        if Event then
            local event, side, channel, replyChannel, message, distance = table.unpack(Event)
            if channel==EventList.myChannel then
                for i,fun in EventHandler.messageHandler do
                    if message.cmd==i then
                        EventHandler.sendAnswer(fun(message),replyChannel)
                    end
                end
            end
        end
         os.sleep(1)
    end
end


-- ruft receiver und worker parralel auf
function EventHandler.messageHandler()
    parallel.waitForAny(EventHandler.message_receive,EventHandler.message_work)
end

return EventHandler
