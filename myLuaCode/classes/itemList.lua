
local item=require("item")
local itemList={items={},totalItems=0}
local defaultFile="data.txt"

local function printAll(o)
    if type(o)==table then
        for i,v in pairs(o) do
            print(i..":")
            printAll(v)
        end
    else
        print(o)
    end
end
function itemList:init(o)
    print(o)
    print(type(o))
    printAll(o)
    o=o or {items={},totalItems=0}
    setmetatable(o,self)
    self.__index =self
    print("inside init",#self.items)
    return o
end

function itemList:lastAccess(name)
    for i,entry in pairs(self.items) do
        if entry:getName()==name then
            return entry.lastAccess
        end
    end
    return false
end

function itemList:update(itemName,count,inv,slot)
    local lastAccess
    if inv.getItemDetail(slot) and inv.getItemDetail(slot).count<inv.getItemLimit(slot) then
        lastAccess={inventory=inv,slot=slot}
    end
    for i,v in pairs(self.items) do
        if v.getName()==itemName then
            v:add(count)
            v.lastAccess=lastAccess
            table.insert(v.instances,{inventory=inv,slot=slot})
        end
    end
end

function itemList:newEntry(localitem,inv,slot)
    local lastAccess={}
    if inv.getItemDetail(slot) and inv.getItemDetail(slot).count<inv.getItemLimit(slot) then
        lastAccess={inventory=peripheral.getName(inv),slot=slot}
    end
    local entry=item:new({properties={name=localitem.name,count=localitem.count,limit=inv.getItemLimit(slot)},instances={{inventory=peripheral.getName(inv),slot=slot}},lastAccess=lastAccess})
    assert(type(entry)=="table")
    table.insert( self.items,entry)
    print(#self.items)
end

function itemList:override(storage)
    print("inside override:")
    assert(type(storage)=="table")
    itemList.depleted={}
    local start=os.clock()
    print("now checking storage with starttime:",start)
    for i,container in pairs(storage) do
        
        for slot,listitem in pairs(container.list()) do
            print("inside for loop")
            if itemList:hasItem(listitem.name) then
                print("updating Entry:",listitem.name)
                itemList:update(listitem.name,listitem.count,container,slot)
            else
                print("making new Entry for:",listitem.name)
                itemList:newEntry(listitem,container,slot)
            end
            --term.clear()
            --term.setCursorPos(1,1)
            print("inv:",i,"/",#storage)
        end
    end
    local timer=os.clock()
    --term.clear()
    print("took: ",timer-start,"time")
end

function itemList:pos(itemName)
    for i,entry in pairs(self.items) do
        if entry:getName()==itemName then
            return entry:locate()
        end
    end
end

function itemList:getCount(itemName)
    for i,entry in pairs(self.items) do
        if entry:getName()==itemName then
            return entry:getCount()
        end
    end
end


function itemList:getList()
    return self.items
end

function itemList:depleted(itemName)

end

function itemList:hasItem(itemName)
    for i,entry in pairs(itemList.items) do
        assert(type(entry)=="table")
        if entry:getName()==itemName then
            return true
        end
    end
    return false
end
return itemList
