local function breakBlocks()
    local _,info=turtle.inspect()
    if info then
        if string.match(info.name or "test","dirt") then
            turtle.dig()
        end
    end
    local _,infoDown=turtle.inspectDown()
    if infoDown then
        if string.match(infoDown.name or "test","dirt") then
            turtle.digDown()
            turtle.down()
            breakBlocks()
        end
    end
    if info then
        if string.match(info.name or "test","dirt") then
            turtle.forward()
            breakBlocks()
        end
    end
    turtle.turnLeft()
    local _,info=turtle.inspect()
    if info then
        if string.match(info.name or "test","dirt") then
            turtle.dig()
            turtle.forward()
            breakBlocks()
        end
    end
    turtle.turnLeft()
    local _,info=turtle.inspect()
    if info then
        if string.match(info.name or "test","dirt") then
            turtle.dig()
            turtle.forward()
            breakBlocks()
        end
    end
    turtle.turnLeft()
    local _,info=turtle.inspect()
    if info then
        if string.match(info.name or "test","dirt") then
            turtle.dig()
            turtle.forward()
            breakBlocks()
        end
    end
end
breakBlocks()