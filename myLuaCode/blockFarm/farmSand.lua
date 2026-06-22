local function farmsand()
    print(turtle.getFuelLevel())
    local _,info=turtle.inspectDown()
    if info then
        print(info.name)
        if info.name=="minecraft:sand" then
                turtle.digDown()
                turtle.down()
                farmsand()
                turtle.up()
        end
    end
    _,info=turtle.inspect()
    if info then
        print(info.name)
        if info.name=="minecraft:sand" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmsand()
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.forward()
            turtle.turnLeft()
            turtle.turnLeft()
        end
    end
    turtle.turnRight()
    _,info=turtle.inspect()
    if info then
        print(info.name)
        if info.name=="minecraft:sand" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmsand()
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.forward()
        turtle.turnLeft()
        turtle.turnLeft()
        end
    end
    turtle.turnRight()
    _,info=turtle.inspect()
    if info then
        print(info.name)
        if info.name=="minecraft:sand" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmsand()
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.forward()
        turtle.turnLeft()
        turtle.turnLeft()
        end
    end
    turtle.turnRight()
    _,info=turtle.inspect()
    if info then
        print(info.name)
        if info.name=="minecraft:sand" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmsand()
        turtle.turnLeft()
        turtle.turnLeft()
        turtle.forward()
        turtle.turnLeft()
        turtle.turnLeft()
        end
    end
    turtle.turnRight()
    local _,info=turtle.inspectUp()
    if info then
        print(info.name)
        if info.name=="minecraft:sand" then
            while not turtle.up() do
                turtle.digUp()
            end
            turtle.up()
            farmsand()
            turtle.down()
        end
    end
end
farmsand()