local function farmgravel()
    print(turtle.getFuelLevel())
    local _,info=turtle.inspectDown()
    if info then
        print(info.name)
        if info.name=="minecraft:gravel" then
                turtle.digDown()
                turtle.down()
                farmgravel()
                turtle.up()
            
        end
    end
    _,info=turtle.inspect()
    if info then
        print(info.name)
        if info.name=="minecraft:gravel" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmgravel()
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
        if info.name=="minecraft:gravel" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmgravel()
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
        if info.name=="minecraft:gravel" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmgravel()
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
        if info.name=="minecraft:gravel" then
            while not turtle.forward() do
                turtle.dig()
            end
            farmgravel()
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
        if info.name=="minecraft:gravel" then
            while not turtle.up() do
                turtle.digUp()
            end
            turtle.up()
            farmgravel()
            turtle.down()
        end
    end
end
farmgravel()