local maxLayer=3
local function selectPotato()
    for i=1, 16 do
        local info=turtle.getItemDetail(i)
        if info then
            print("info.name",info.name)
            if info.name=="minecraft:potato" or string.match(info.name,"seed") then
                turtle.select(i)
                return true
            end
        end
    end
    return false
    -- body
end

local function emptyInventory()
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end
end

function farmPotato()
    local _,info=turtle.inspectDown()
    if info.state then
        print(info.state.age)
        if info.state.age==7 then
            turtle.digDown()
        end
    end
    print(info.name)
    if selectPotato() then
        turtle.placeDown()
    end
end

function checkForFuel()
    if turtle.getFuelLevel()>100 then
        return true
    end
    local chest=peripheral.find("minecraft:chest")
    for k, v in pairs(chest.list()) do
        if v.name=="minecraft:coal_block" or v.name=="minecraft:dried_kelp_block" then
            turtle.pullItem(chest,k)
            for i=1, 16 do
                turtle.select(i)
                local _,info=turtle.getItemDetail()
                if info then
                    if info.name=="minecraft:coal_block" or v.name=="minecraft:dried_kelp_block" then
                        turtle.refuel()
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function farming()
    for i=1,4 do
        for k=1,5 do
            for l=1,3 do
                farmPotato()
                turtle.forward()
            end
            if k%2==1 and k~=5 then
                turtle.turnLeft()
                farmPotato()
                turtle.forward()
                turtle.turnLeft()
            elseif k~=5 then
                turtle.turnRight()
                farmPotato()
                turtle.forward()
                turtle.turnRight()
            end
        end
        farmPotato()
        turtle.forward()
        turtle.turnRight()
        print("turning to next quarter")
    end
end

local function waitForGrowth()
    local _,info=turtle.inspect()
    print(info.state.age)
    while info.state.age~=7 do
        _,info=turtle.inspect()
    end
end

local function turn()
    turtle.turnRight()
    turtle.turnRight()
end

local function nextLayer(currentLayer)
    if currentLayer==maxLayer then
        for i=1,maxLayer do
            turtle.down()
            turtle.down()
            turtle.down()
        end
        currentLayer=0
    else
        turtle.up()
        turtle.up()
        turtle.up()
        currentLayer=currentLayer+1
    end
    return currentLayer
end
local baseLayer=1
local layer=baseLayer
local _,info
while true do 
    waitForGrowth()
    turtle.up()
    turtle.forward()
    farming()
    turn()
    turtle.forward()
    turtle.down()
    local Flevel=turtle.getFuelLevel()
    print("checking for refuel:",Flevel,"/",turtle.getFuelLimit()," required: ",9*9)
    _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:chest" then
            emptyInventory()
        end
    end
    turn()
    layer=nextLayer(layer)
end