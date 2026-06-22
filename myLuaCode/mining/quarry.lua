local itemcnt=0
local chestHeight=0
local function turn()
    turtle.turnLeft()
    turtle.turnLeft()
end
local function digForward()
    while not turtle.forward() do
        turtle.dig()
    end
end
local _,info

local function emptyInventory()
    print("inside emptyInventory")
    local _,info=turtle.inspect()
    print(info.name)
    if string.match( info.name,"chest") then
        for slot=1,16 do
            print("empying slot:",slot,turtle.getItemDetail(slot))
            turtle.select(slot)
            turtle.drop()
        end
    end
end

local function countItems()
    itemcnt=0
    for i = 1, 16 do
        if(turtle.getItemDetail(i)) then
             itemcnt=itemcnt+turtle.getItemCount(i)
        end 
        print('itemcnt:',itemcnt,'/',(16*4*4)*0.8)
     end
    return itemcnt
end
local function blockBreak()
    _,info=turtle.inspectUp()
    if info then
        if info.name=="minecraft:monster_spawner" then
            return
        end
    end
    turtle.digUp()
    _,info=turtle.inspectDown()
    if info then
        if info.name=="minecraft:monster_spawner" then
            return
        end
    end
    turtle.digDown()
    _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:monster_spawner" then
            return
        end
    end
    digForward()
end

local function mine()
    for i = 1,16 do
        for j=1,16 do
            blockBreak()
        end
        if i%2==0 and i~=16 then
            turtle.turnLeft()
            blockBreak()
            turtle.turnLeft()
        else
            turtle.turnRight()
            if  i~=16 then
                blockBreak()
            else
                for k=1,15 do
                    blockBreak()
                end
            end
            turtle.turnRight()
        end
    end
end



local function checkForFuel()
    for i = 1, 16, 1 do
       if(turtle.getItemDetail(i)) then
            if(turtle.getItemDetail(i).name=='minecraft:coal' or turtle.getItemDetail(i).name=='minecraft:charcoal') then
                print('found fuel at:',i)
                if(turtle.getFuelLimit()-turtle.getFuelLevel()>turtle.getItemCount(i)*8) then
                    turtle.select(i)
                    turtle.refuel(turtle.getItemCount())
                    print(turtle.getItemCount(i)-turtle.getFuelLimit()/8+turtle.getFuelLevel()/8)
                else
                    turtle.select(i)
                    turtle.refuel(turtle.getItemCount()-turtle.getFuelLimit()/8+turtle.getFuelLevel()/8)
                    print(turtle.getItemCount(i)-turtle.getFuelLimit()/8+turtle.getFuelLevel()/8)
                end
            end
       end
    end
    turtle.select(1)
end

local function moveDown(currentHeight)
    for i=1,currentHeight do
        turtle.down()
    end
    turtle.digDown()
    turtle.down()
    turtle.digDown()
    turtle.down()
    return currentHeight+2
end
local function moveUp(currentHeight)
    for i=1,currentHeight do
        turtle.up()
    end
end
checkForFuel()
local function getStop(fuelLevel)
    if not (fuelLevel>16*16+(chestHeight+2)*2) then
        print("missing fuel")
        return true
    end
    return false
end

local function quarry()
    while true do
        if chestHeight==0 then
            while turtle.down() do
                chestHeight=chestHeight+1
            end
            turtle.digDown()
            turtle.down()
            chestHeight=chestHeight+1
            turtle.digDown()
            turtle.down()
            chestHeight=chestHeight+1
        else
            chestHeight=moveDown(chestHeight)
        end
        mine()
        moveUp(chestHeight)
        turn()
        emptyInventory()
        turn()


        if getStop(turtle.getFuelLevel()) then
            print(getStop(turtle.getFuelLevel()))
            print("missing Fuel")
            return
        end
        _,info=turtle.inspectUp()
        if info then
            if info.name=="minecraft:cobblestone" then
                print("found cobblestone")                
                return
            end
        end
    end
end
quarry()
print('stopped with Flevel:',turtle.getFuelLevel(),'/',16*16)