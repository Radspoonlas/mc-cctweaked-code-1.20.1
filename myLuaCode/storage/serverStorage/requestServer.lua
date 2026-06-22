--imports
local modem=require "modemManager"
local eventHandler=require "eventHandler"
local expect=require "cc.expect"

--modem configuration

modem:newWireless()


local channels={
    ["storage"]=22065,
    ["oven"]=22063,
    ["monitor"]=22068,
    ["pocket"]=2206,
    ["server"]=22061,
    ["gps"]=65534,
    ["crafting"]=22069
}
modem:openChannel(channels.server)

--monitor
local monitor=peripheral.find("monitor")
if not monitor then
    print("no monitor attached")
end



--functions

--smeltrequesthandler
local function requestSmelting(itemName,itemCount)
    print("gotSmeltingRequest")
    modem.open(ovenChannel)
    modem.transmit(ovenChannel,serverChannel,{itemName,itemCount})
    modem.close(ovenChannel)
end

--craftingrequesthandler
local function requestCrafting(itemName,itemCount)
    print("got Craftingrequest")
    modem:send(channels.crafting,channels.server,{cmd='craft',itemName,itemCount})

end

--requester for itemCount
local function requestGetItemCount(itemName)
    print("got itemCountrequest")
    modem:send(channels.storage,channels.server,{'getItemCount',itemName})
end

local function requestItemPush(inventory,slot)
    print("got sortrequest")
    modem:send(channels.storage,channels.server,{'push',inventory,slot})
    return true
end

--function to handle itempullrequests
local function requestItemPull(replyChannel,itemName,itemCount,toInv,toSlot)
    print("got itemrequest")
    modem:send(channels.storage,channels.server,{cmd='pull',inventory=toInv,slot=toSlot,name=itemName,count=itemCount})
end

--updater for monitor
local function updateMonitor(itemList)
    print("got itemList update")
    modem:send(channels.monitor,channels.server,{list=itemList})
end

--sleep 10
local function wait_for_sleep()
    os.sleep(10)
    return
end


--requester for itemList
local function requestItemList()
    print("getting itemList...")
    modem:send(channels.storage,channels.server,{"itemList"})
    print("out of requestitemList")
end

print("starting server")
print("starting while")

--EventManager
local handles={
    {name="smelt",fun=requestSmelting},
    {name="craft",fun=requestCrafting},
    {name="pull",fun=requestItemPull},
    {name="push",fun=requestItemPush},
    {name="getCount",fun=requestGetItemCount},
    {name="itemList",fun=updateMonitor},
    {name="getItemList",fun=requestItemList}
}
    eventHandler:makeHandle(handles)
while true do
    parallel.waitForAll(function () eventHandler:wait_for_workEvent() end,function() eventHandler:wait_for_Event() end)
end