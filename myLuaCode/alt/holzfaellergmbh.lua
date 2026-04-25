
function fullTurn()
    turtle.turnLeft()
    turtle.turnLeft()
end

function checkFuel()
   if turtle.getFuelLevel()<100 then
        for i=1,16 do
            turtle.select(i)
            _,info=turtle.getItemDetail()
            if info then
                if info.name=="minecraft:oak_log" then
                    turtle.refuel(64)
                    checkFuel() 
                end
            end
        end
    end
    return true
end
function chopTree()
    checkFuel()  
    local _,info=turtle.inspectUp()
    if info.name=='minecraft:oak_log'  then
        turtle.digUp()
        turtle.up() 
        chopTree()
        turtle.down()
    end
    _,info=turtle.inspect()
    if info.name=='minecraft:oak_log' then
        turtle.dig()
        turtle.forward()
        chopTree()
        fullTurn()
        turtle.forward()
        fullTurn()
    end
    turtle.turnLeft()
    _,info=turtle.inspect()
    if info.name=='minecraft:oak_log' then
        turtle.dig()
        turtle.forward()
        chopTree()
        fullTurn()
        turtle.forward()
        fullTurn()
    end
    turtle.turnRight()
    
    turtle.turnRight()
    _,info=turtle.inspect()
    if info.name=='minecraft:oak_log'  then
        turtle.dig()
        turtle.forward()
        chopTree()
        fullTurn()
        turtle.forward()
        fullTurn()
    end
    turtle.turnLeft()
    print('found no more wood')
end
local hasSapling=0
local function selectSapling()
    for i = 1, 16 do
        turtle.select(i)
        if turtle.getItemDetail() then
            if turtle.getItemDetail().name=='minecraft:sapling' then
                return
            end
        end
    end
end
local function plantSapling(n)
    if not n then
        n=0
    end
    for i=1,n do
        local _,info=turtle.inspectDown()
        if info.name=='minecraft:dirt' or 'minecraft:grass' then
            turtle.forward()
            selectSapling()
        elseif not _ then
            turtle.down()
            plantSapling(n-i)
            turtle.up()
            fullTurn()
            for j=1,i do
                turtle.forward()
            end
            fullTurn()
            break
            
        end
    end
end




local function holzfaeller()
    local counter=0
    local _,info=turtle.inspect()
    print(info.name,string.match(info.name,"log"))

    while string.match(info.name or "test","log") do
        turtle.dig()
        turtle.forward()
        counter=counter+1
        _,infoUp=turtle.inspectUp()
        while string.match(infoUp.name or "test","log") do
            turtle.digUp()
            turtle.up()
            _,infoUp=turtle.inspectUp()
        end
        while turtle.down() do
            turtle.down()
        end
        _,info=turtle.inspect()
        if not info then
            info.name="test"
        end
    end
end
while true do
    holzfaeller()
    turtle.turnRight()
end

--turtle.turnLeft()
--turtle.turnLeft()


--chopTree()
--plantSapling()
