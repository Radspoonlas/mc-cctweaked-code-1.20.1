local Flevel=turtle.getFuelLevel()
local Limit=turtle.getFuelLimit()
local function findbucket()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            if detail.name=="minecraft:bucket" then
                turtle.select(i)
                return true
            end
            if detail.name=="minecraft:lava_bucket" then
                turtle.select(i)
                turtle.refuel()
                return true
            end
        end
    end
    return false
end
if not findbucket() then
    print("no bucket")
    return
end
while Flevel<Limit do
    findbucket()
    local _,info=turtle.inspect()
    if info.name=="minecraft:lava_cauldron" then
        turtle.place()
        turtle.refuel()
        Flevel=turtle.getFuelLevel()
        print(Flevel)
    end
end
if turtle.getEquippedLeft()=="minecraft:diamond_pickaxe" or turtle.getEquippedRight()=="minecraft:diamond_pickaxe" then
    while true do
        local _,info=turtle.inspect()
        if info.name=="minecraft:lava_cauldron" then
            turtle.place()
            turtle.placeDown()
            turtle.digDown()
        end
    end
end
