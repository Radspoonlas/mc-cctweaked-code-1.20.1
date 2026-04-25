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

local function mine()
    for i = 1,16 do
        for j=1,16 do
            _,info=turtle.inspect()
            if info then
                if info.name=="minecraft:monster_spawner" then
                    return
                end
            end
            digForward()
        end
        if i%2==0 and i~=16 then
            turtle.turnLeft()
            _,info=turtle.inspect()
            if info then
                if info.name=="minecraft:monster_spawner" then
                    return
                end
            end
            digForward()
            turtle.turnLeft()
        else
            turtle.turnRight()
            if  i~=16 then
                _,info=turtle.inspect()
                if info then
                    if info.name=="minecraft:monster_spawner" then
                        return
                    end
                end
                digForward()
            else
                for k=1,15 do
                    _,info=turtle.inspect()
                    if info then
                        if info.name=="minecraft:monster_spawner" then
                            return
                        end
                    end
                    digForward()
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

_,info=turtle.inspect()

local function stuff()
    checkForFuel()
Flevel=turtle.getFuelLevel()
print(Flevel)

while turtle.down() do
    chestHeight=chestHeight+1
    print(chestHeight)
end
turtle.digDown()
turtle.down()
chestHeight=chestHeight+1
while true do
    mine()
    Flevel=turtle.getFuelLevel()
    print(Flevel)
    itemcnt=countItems()
    for i = 1, chestHeight do
        turtle.up()
    end
    turn()
    emptyInventory()
    turn()
    if not (turtle.getFuelLevel()>16*16+(chestHeight+1)*2) then
        print("missing fuel")
        return
    end
    _,info=turtle.inspectUp()
    if info then
        if info.name=="minecraft:cobblestone" then
            return
        end
    end
    
    for i = 1, chestHeight do
        turtle.down()
    end
    _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:monster_spawner" then
            return
        end
    end
    turtle.digDown()
    turtle.down()
    chestHeight=chestHeight+1
    print(chestHeight)
end
print('stopped with Flevel:',Flevel,'/',16*16,' and itemcnt:',itemcnt,'/',(16*4*4)*0.8)
end
stuff()