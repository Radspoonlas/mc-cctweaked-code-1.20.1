local args={...}
local maxDistance
if args[1] then
    maxDistance=tonumber(args[1])
end

local relevanteBloecke={"minecraft:ancient_debris","minecraft:nether_quartz_ore","minecraft:nether_gold_ore","minecraft:blackstone"}
local function checkForLava()
    local _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:lava" then
            return true
        end
    end
     _,info=turtle.inspectUp()
    if info then
        if info.name=="minecraft:lava" then
            return true
        end
    end
     _,info=turtle.inspectDown()
    if info then
        if info.name=="minecraft:lava" then
            return true
        end
    end
    return false
end

local function goBack()
    turtle.turnLeft()
    turtle.turnLeft()
    for i=1,16 do
        while not turtle.forward() do
            turtle.dig()
        end
    end
end

local function checkForBlocks(block)
    if not block then
        return false
    end
    for i,v in ipairs(relevanteBloecke) do
        if v==block.name then
            return true
        end
    end
    return false
end

local function emptyInventory()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            if detail.name=="minecraft:netherrack" then
                turtle.select(i)
                turtle.drop(64)
            end
        end
    end
end

local function mine()
    if checkForLava() then
        goBack()
    end
    local _,info=turtle.inspectUp()
    if checkForBlocks(info) then
        emptyInventory()
    end
    while turtle.digUp() do
        turtle.digUp()
    end
     _,info=turtle.inspectDown()
    if checkForBlocks(info) then
        emptyInventory()
    end
    turtle.digDown()
    _,info=turtle.inspect()
    if checkForBlocks(info) then
        emptyInventory()
    end
    while turtle.dig() do
        turtle.dig()
    end
end

if maxDistance then
    for i=1,maxDistance do
        mine()
        turtle.forward()
    end
else
    while true do
        mine()
        turtle.forward()
    end
end