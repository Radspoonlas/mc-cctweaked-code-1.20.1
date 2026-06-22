local args={}

local function findblock(blockName)
    if blockName then
        for i=1,16 do
            local info=turtle.getItemDetail(i)
            if info then
                if info.name==blockName then
                    select(i)
                    return true
                end
            end
            
        end
    else
        for i=1,16 do
            local info=turtle.getItemDetail(i)
            if info then
                select(i)
                return true
            end
        end
    end
    return false
end
local function placeBlock(blockName)
    local _,info=turtle.inspect()
    if info then
        while _ do
            turtle.dig()
            _,info=turtle.inspect()
        end
        if not findblock(blockName) then
            return false
        end
        turtle.place()
    end
    return true
end

local function replaceWall(x,y,z,blockName)
    print("infunction replacewall")
    while true do
        if not placeBlock(blockName) then
            return
        end
        print(turtle.up())
        while turtle.up() do
            if not placeBlock(blockName) then
                return
            end
            
        end
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
        if not placeBlock(blockName) then
            return
        end
        print(turtle.down())
        while turtle.down() do
            if not placeBlock(blockName) then
                return
            end
            
        end
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
    end
end
print(args[1])
if not findblock then
    return
end
if args[1] then
    replaceWall(tostring(args[1]))
end
replaceWall()
while turtle.down() do
    turtle.down()
end
