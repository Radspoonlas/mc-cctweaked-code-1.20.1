local function findBucket()
    for i=1,16 do
        local detail=turtle.getItemDetail()
        if detail and (detail.name=="minecraft:bucket") then
            turtle.select((i))
            return
        end
    end
end
findBucket()
while true do
    local _,info=turtle.inspect()
    if info and (info.name=="minecraft:lava_cauldron") then
        turtle.place()
        if turtle.getFuelLevel()==turtle.getFuelLimit() then
            turtle.placeDown()
            turtle.digDown()
        else
            turtle.refuel()
        end

    end
end