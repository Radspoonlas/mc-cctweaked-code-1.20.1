local function searchBucket()
    for i=1,16 do
        local info=turtle.getItemDetail(i)
        if info then
            if info.name=="minecraft:bucket" then
                turtle.select(i)
                return true
            end
        end
    end
    return false
end


function lavaRefuel()
    print("FuelLevel: ",turtle.getFuelLevel(),"/",turtle.getFuelLimit())
    if turtle.getFuelLevel==turtle.getFuelLimit() then
        return true
    end
    local _,info=turtle.inspectUp()
    if info then
        if info.name=="minecraft:lava" then
            turtle.placeUp()
            turtle.refuel()
        end
    end
    local _,info=turtle.inspectDown()
    if info then
        if info.name=="minecraft:lava" then
            turtle.placeDown()
            turtle.refuel()
        end
    end
    turtle.turnRight()
    local _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:lava" then
            turtle.place()
            turtle.refuel()
            turtle.forward()
            lavaRefuel()
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
    turtle.turnLeft()
    local _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:lava" then
            turtle.place()
            turtle.refuel()
            turtle.forward()
            lavaRefuel()
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
    turtle.turnLeft()
    local _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:lava" then
            turtle.place()
            turtle.refuel()
            turtle.forward()
            lavaRefuel()
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
    turtle.turnLeft()
    local _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:lava" then
            turtle.place()
            turtle.refuel()
            turtle.forward()
            lavaRefuel()
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
    local _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:lava" then
            turtle.place()
            turtle.refuel()
            turtle.forward()
            lavaRefuel()
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
    local _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:lava" then
            turtle.place()
            turtle.refuel()
            turtle.forward()
            lavaRefuel()
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
end
local bucket=searchBucket()
print(bucket)
if not bucket then
    print("missing bucket")
    return
end
lavaRefuel()
turtle.up()