--brennstoff fuellstand ueberpruefen und automatisch nachfuellen lassen
--aktuelle Brennstoff stand ueberpruefen(Kelp)
--änder 3 zu 42
local ovenList
function ovenList:burnTimer()
end
function ovenList:ofenQueue()
end
function ovenList:ofenBelegt()
end

---@diagnostic disable-next-line:param-type-mismatch
local oefen={peripheral.find("minecraft:furnace")}
---@cast oefen ccTweaked.peripherals.Inventory[]
function ovenList:requestItem(itemName,itemCount,ofen,slot)
    if not itemCount then
        itemCount=1
    end
        modem.open(storageChannel)
        modem.transmit(storageChannel,oefenChannel,{'moveItem',inventory=ofen,slot=slot,name=itemName,count=itemCount})
        modem.close(storageChannel)
end

function  ovenList:requestSortItem(ofen)
    print("requesting Sorting of item")
    modem.open(storageChannel)
    modem.transmit(storageChannel,oefenChannel,{cmd='sortItem',inventory=peripheral.getName(ofen),slot=3})
    modem.close(storageChannel)
end

function ovenList:status()
    for i,v in ipairs(oefen) do
        print("burnTimer:",burnTimer[i],peripheral.getName(v))
        print("ofenBelegt",ofenBelegt[i],peripheral.getName(v))
        print("in:",v.getItemDetail(1))
        print("fuel:",v.getItemDetail(2))
        print("out:",v.getItemDetail(3))
    end
end

function oefen:requestFuel(inv,fuelCount)
    print("requesting fuel for: ",inv)
    modem.open(storageChannel)
    modem.transmit(storageChannel,oefenChannel,{cmd='getFuel',inventory=peripheral.getName(inv),count=fuelCount})
    modem.close(storageChannel)
end

function ovenList:schmelz(item,itemCount,ofen)
    assert(type(item)=="string")
    assert(type(itemCount)=="number")
    assert(type(ofen)=="string")
    local furnace=peripheral.wrap(ofen)
    local itemDetail=furnace.getItemDetail(2)
    if not itemDetail then
        requestFuel(ofen,itemCount)--slot 2
    end
    requestItem(item,itemCount,ofen,1)--slot 1
    burnTimer[ofen]=os.startTimer(itemCount*10)
    print("smelting item",item," with ID:",burnTimer[ofen],ofen)
end

function ovenList:checkFurnaces()
    for i, ofen in ipairs(oefen) do
        if ofen.getItemDetail(3) then
            requestSortItem(ofen)
        end
        if ofen.getItemDetail(1) then
            ofenBelegt[i]=true
            burnTimer[i]=os.startTimer(ofen.getItemDetail(1).count*10)--game ticks 200=10s
            print("init burnTimer:",burnTimer[i],i)
            if not ofen.getItemDetail(2) then
                print("requestFuel")
                requestFuel(ofen,ofen.getItemDetail(1).count)--slot 2
            end
        else
            ofenBelegt[i]=false
        end
    end
end

function ovenList:emptyQueue()
    local lastOpenFurnace=1
    for i, ofen in ipairs(ofenQueue) do
        while ofenBelegt[lastOpenFurnace] do
            if not ofenBelegt then
                if ofen.count>20 then
                    schmelz(ofen.item,20,oefen[i])
                    ofen.count=ofen.count-20
                    ofenBelegt[i]=true
                    break
                else
                    schmelz(ofen.item,ofen.count,oefen[i])
                    ofen=nil
                    ofenBelegt[i]=true
                    break
                end
            end
            lastOpenFurnace=lastOpenFurnace+1
        end
    end
end



function ovenList:reqSmelt(itemName,itemCount)
    for i,ofen in ipairs(ofenBelegt) do
        if not ofenBelegt[i] then
            schmelz(itemName,itemCount,peripheral.getName(oefen[i]))
            ofenBelegt[i]=true
            burnTimer[i]=os.startTimer(oefen[i].getItemDetail(1).count*10)--game ticks 200=10s
            print("init burnTimer:",burnTimer[i],i)
            return true
        end
    end
    return false
end
return {ovenList}