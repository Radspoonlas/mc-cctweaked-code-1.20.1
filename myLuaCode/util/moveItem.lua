local output =peripheral.find("minecraft:furnace")
local input = peripheral.find("minecraft:chest")
local fuel = peripheral.find("minecraft:hopper")
while true do
    os.sleep(10)
    for i,v in pairs(input.list())do
        if v.name and v.name=="minecraft:stone" then
            output.pullItems(peripheral.getName(input),i,64,1)
        end
    end
    output.pullItems(peripheral.getName(fuel),1,64,2)
    input.pullItems(peripheral.getName(output),3,64)
end