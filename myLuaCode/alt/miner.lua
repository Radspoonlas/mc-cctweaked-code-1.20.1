_,info=turtle.inspect()
if(not info.name=='minecraft:chest') then
    print("cant start without chest")
    return
end
distanceToBase={
    x=0,
    z=0,
    y=0,
    direction=0
}

function forward(n)
    if(not n) then
        n=1
    end
    for i = 1, n do
        if(not turtle.forward()) then
            print('something is hindering my march')
            turtle.dig()
        end 
    end
    if(distanceToBase.direction==0)then
        distanceToBase.x=distanceToBase.x+1
    elseif distanceToBase.direction==1 then
        distanceToBase.y=distanceToBase.y+n
    elseif distanceToBase.direction==2 then
        distanceToBase.x=distanceToBase.x-n
    else
        distanceToBase.y=distanceToBase.y-n
    end

end

function rise(n)
    if not n then n=1 end
    for i = 1, n, 1 do
        if(not turtle.up()) then
            print('path above obstructed')
            turtle.digUp()
            turtle.attackUp()
        end
    end
end



function returnToBase(x,z,y)
    if direction==0 then
        turtle.turnRight()
        turtle.turnRight()
    end
    if direction==1 then
        turtle.turnRight()
    end
    if direction==3 then
        turtle.turnLeft()
    end
    forward(x)
    rise(z)
    if not y then
        y=0
    end
    if(y<0) then
        turtle.turnLeft()
        forward(y)
        turtle.turnRight()
    else 
        turtle.turnRight()
        forward(y)
        turtle.turnLeft()
    end
    turtle.turnRight()
    turtle.turnRight()
end

function updateDirection(n)
    if(direction==4 and n>0) then
        direction=0
    elseif direction==0 and n<0 then
        direction=4
    else
        direction=direction+n
    end
end
while true do
    for i=1,16 do
        turtle.select(i)
        if(turtle.getItemDetail()) then
            if(turtle.getItemDetail().name=='minecraft:coal') then
                while(turtle.getFuelLimit()-8>turtle.getFuelLevel or not turtle.getItemDetail()) do
                    turtle.refuel(1)
                end
                
            end
        end
        
    end
    turtle.select(1)
    if(turtle.getFuelLevel()<100) then
        print("non sufficiant fuel level")
        return
    end
    while(turtle.getFuelLevel()>distanceToBase.x+distanceToBase.z+distanceToBase.y and not turtle.getSelectedSlot()==16) do
        if turtle.getFuelLevel()>math.abs( distanceToBase.x )+math.abs(distanceToBase.z)+1+math.abs( distanceToBase.y ) then returnToBase() end
        if (not turtle.digDown()) then
            info=turtle.inspectDown()
            if info.name=='minecraft:bedrock' then
                returnToBase(distanceToBase.x,distanceToBase.z,distanceToBase.y,distanceToBase.direction)
                distanceToBase.x=0
                distanceToBase.y=0
                distanceToBase.z=0
                distanceToBase.direction=0
                break
            end
        end
        distanceToBase.z=distanceToBase.z-1
        for i = 1, 16 do
            for i = 1, 16 do
                forward(1)
                
                if(turtle.getItemDetail()) then
                    turtle.select(turtle.getSelectedSlot()+1)
                end
            end
            if(direction==0)then  
                updateDirection(1) 
                turtle.turnRight()
                turtle.forward(1)
                updateDirection(1)
                turtle.turnRight()
                
            else
                updateDirection(-1)
                turtle.turnLeft()
                turtle.forward(1)
                updateDirection(-1)
                turtle.turnLeft()
                
            end
        end
        updateDirection(-1)
        turtle.turnLeft()
        updateDirection(-1)
        turtle.turnLeft()
        for i = 1, 16, 1 do
            turtle.forward(1)
        end
        updateDirection(1)
        turtle.turnRight()
    end
    print('returning to base')
    returnToBase(x,y,z)
    for i=1,16 do
        turtle.select(i)
        if(turtle.getItemDetail()) then 
            if(not(turtle.getItemDetail().name=='minecraft:coal')) then
                turtle.drop()
            end
        end
    end
end