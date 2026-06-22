local function farmclay()
    print(turtle.getFuelLevel())
    local _,info=turtle.inspectDown()
    if info then
        print(info.name)
        if info.name=="minecraft:clay" then
                turtle.digDown()
                turtle.down()
                farmclay()
                turtle.up()
            
        end
    end
    _,info=turtle.inspect()
    if info then
        print(info.name)
        if info.name=="minecraft:clay" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmclay()
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
        if info.name=="minecraft:clay" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmclay()
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
        if info.name=="minecraft:clay" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmclay()
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
        if info.name=="minecraft:clay" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmclay()
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
        if info.name=="minecraft:clay" then
            while not turtle.up() do
                turtle.digUp()
            end
            turtle.up()
            farmclay()
            turtle.down()
        end
    end
end
farmclay()