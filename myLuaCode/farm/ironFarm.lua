--this Code is meant to be used for sorting when you dont use crafter or a automatic sorting system
local function craftIron( ... )
    
    turtle.transferTo(2,1)
        turtle.transferTo(3,1)
        turtle.transferTo(5,1)
        turtle.transferTo(6,1)
        turtle.transferTo(7,1)
        turtle.transferTo(9,1)
        turtle.transferTo(10,1)
        turtle.transferTo(11,1)
        turtle.craft() 
        turtle.turnLeft()
        turtle.drop()
        turtle.turnRight()
end
local function dropPoppy()
    for i = 1, 16, 1 do
        local detail=turtle.getItemDetail(i)
        if detail and detail.name=="minecraft:poppy" then
            turtle.select(i)
            break
        end
    end
    turtle.turnRight()
    turtle.drop()
    turtle.turnLeft()
    turtle.select(1)
end


turtle.select(1)
while true do
    turtle.suck(9)
    local detail=turtle.getItemDetail(1)
    if detail  then
        if detail.name=="minecraft:poppy" then
            dropPoppy()
        end
        if detail.name=="minecraft:iron_ingot" and detail.count==9 then
            craftIron()
        elseif detail.count<9 or detail.count>9 then

            if detail.count<9 then 
                turtle.suck(9-detail.count)
            else
                turtle.drop(detail.count-9)
            end
            local detail2=turtle.getItemDetail(2)
            detail=turtle.getItemDetail(1)
            if detail2 then
                dropPoppy()
            elseif detail.count==9 then
                craftIron()
            else
                os.sleep(1000)
            end
        end
        
    end
end
