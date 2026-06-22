

function inspectIfChest( ... )
    print("inspecting if Chest")
    turtle.turnLeft()
    turtle.turnLeft() 
    local _,info=turtle.inspect() 
    if info.name=='minecraft:chest' then
        turtle.turnLeft()
        turtle.turnLeft()
        return true 
    end
    turtle.turnLeft()
    turtle.turnLeft() 
    return false
end

function findWater()
    print("now in findWater")
    local distanceToShore=0
    local levelToShore=0 
    local _,info=turtle.inspectDown()
    while info.name~="minecraft:water" do
        print(_)
        if not _ then
            turtle.down()
            levelToShore=levelToShore+1
            _,info=turtle.inspectDown()
        end
        _,info=turtle.inspect()
        print(_)
        if not _ then
            turtle.forward()
            distanceToShore=distanceToShore+1
            _,info=turtle.inspectDown()
        end
    end
    return distanceToShore,levelToShore
end

function farmKelp()
    print("now in farmKelp")
    local _,info=turtle.inspectDown()
    print(info.name)
    if info.name=="minecraft:kelp_plant" then
        turtle.digDown()
        turtle.down()
        findKelp()
        turtle.up()
    end
    _,info=turtle.inspect()
    print(info.name)
    if info.name=="minecraft:kelp_plant" or info.name~="minecraft:kelp_plant" then
        turtle.dig()
        turtle.forward()
        findKelp()
        turtle.turnLeft()
        findKelp()
        turtle.turnLeft()
        findKelp()
        turtle.forward()
        findKelp()
        turtle.turnLeft()
        turtle.turnLeft()
    end
    turtle.turnLeft()
     _,info=turtle.inspect()
    print(info.name)
    if info.name=="minecraft:kelp_plant" or info.name~="minecraft:kelp_plant" then
        turtle.dig()
        turtle.forward()
        findKelp()
        turtle.turnLeft()
        findKelp()
        turtle.turnLeft()
        findKelp()
        turtle.forward()
        findKelp()
        turtle.turnLeft()
        turtle.turnLeft()
    end
    turtle.turnLeft()
    _,info=turtle.inspect()
    print(info.name)
    if info.name=="minecraft:kelp_plant" or info.name~="minecraft:kelp_plant" then
        turtle.dig()
        turtle.forward()
        findKelp()
        turtle.turnLeft()
        findKelp()
        turtle.turnLeft()
        findKelp()
        turtle.forward()
        findKelp()
        turtle.turnLeft()
        turtle.turnLeft()
    end
    turtle.turnLeft()
    local _,info=turtle.inspectDown()
    print(info.name)
    if info.name~="minecraft:kelp_plant" or info.name~="minecraft:kelp_plant" then
        turtle.dig()
        turtle.forward()
        findKelp()
        turtle.turnLeft()
        findKelp()
        turtle.turnLeft()
        findKelp()
        turtle.forward()
        findKelp()
        turtle.turnLeft()
        turtle.turnLeft()
    end
    turtle.turnLeft()
end

function goToShore(x,y,z1)
    print("in goToShore")
    for i = 1, y do
        while not turtle.up() do
            turtle.digUp()
            turtle.attackUp()
        end
    end
    for i = 1, y do
        while not turtle.up() do
            turtle.digUp()
            turtle.attackUp()
        end
    end
    turtle.turnLeft()
    turtle.turnLeft()
    for i = 1, x do
        while not turtle.forward() do
            turtle.dig()
            turtle.attack()
        end
    end
    turtle.turnLeft()
    turtle.turnLeft()
end

local chestAvailable=inspectIfChest()
while true do
   local x,y=findWater()
   local _,info=turtle.inspect()
    while info.name~="minecraft:kelp_plant" or info.name~="minecraft:kelp_plant" do
        local _,info=turtle.inspectDown()
        if info.name=="minecraft:water" then
            turtle.down()
            y=y+1
        end
        local _,info=turtle.inspect()
        if info.name=="minecraft:water" then
            turtle.forward()
            x=x+1
        end
        local _,info=turtle.inspect()
        print(info.name)
        local _,info=turtle.inspectDown()
        print(info.name)
    end
    farmKelp()
   goToShore(x,y)
end

