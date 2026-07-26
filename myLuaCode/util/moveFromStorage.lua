local output =peripheral.find("minecraft:hopper")
local inputs = {peripheral.find("minecraft:barrel")}
local function findItemPos(itemName)
    for i,inventory in pairs(inputs) do
        print("at: "..peripheral.getName(inventory))
        for slot,item in pairs(inventory.list()) do
            if item.name==itemName then
                return true,inventory,slot
            end
        end
    end
    return false
end
while true do
    os.sleep(10)
    local hasItem,inv,slot=findItemPos("minecraft:stone")
    if not hasItem then
        hasItem,inv,slot=findItemPos("minecraft:cobblestone")
        if not hasItem then
            print("we ran into issue no items found")
            return
        end
    end
    output.pullItems(peripheral.getName(inv),slot,64,1)
end