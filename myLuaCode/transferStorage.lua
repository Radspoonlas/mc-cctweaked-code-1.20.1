local cache={}
local function searchItem(itemName)
    local storage={peripheral.find("minecraft:barrel")}
    for i,barrel in pairs(storage) do
        for i,item in pairs(barrel.list()) do
            if item and item.name==itemName then
               peripheral.find("minecraft:dropper").pullItems(peripheral.getName(barrel),i,64)
               print("found Item")
               return
            end
        end
    end
end

local function storeItem(ItemName,slot)
    local storage={peripheral.find("minecraft:barrel")}
    local index=cache[ItemName] or 1
    for j=index,#storage do
        local items=storage[j].list()
        print("at chest: "..j.." / "..#storage)
        local input=peripheral.find("minecraft:chest")
        local cnt=storage[j].pullItems(peripheral.getName(input),slot)
        if cnt>0 then
            cache[ItemName]=j
            return
        end
    end
end
local input=peripheral.find("minecraft:chest")
while true do
    for i,item in pairs(input.list()) do
            print(i,item)
            print(item.name)
            storeItem(item.name,i)
        end
end

