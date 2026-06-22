local grid={1,2,3,5,6,7,9,10,11}
local function emptyInventory()
    for i = 1, 16, 1 do
        turtle.select(i)
        if not turtle.dropUp() then
            turtle.drop()
        end
    end
end
local function craftGold()
    local detail=turtle.getItemDetail(1)
    for i = 1, 16, 1 do
        detail=turtle.getItemDetail(i)
        if detail and detail.name and detail.name=="minecraft:gold_nugget" then
            turtle.select(i)
            break
        end
    end
    for i = 1, 9, 1 do
        turtle.transferTo(grid[i],detail.count/9)
    end
    if detail.count%9~=0 then
         turtle.transferTo(1)
    end
    if not turtle.craft() then
        emptyInventory()
    end
end
local function checkInv()
    local gold=false
    local goldIngot=true
    for i = 1, 16, 1 do
        local detail=turtle.getItemDetail(i)
        if detail and detail.name and detail.name=="minecraft:gold_nugget" then
            if detail.count>=9 then
                gold=true
            end
        elseif detail and detail.name and detail.name=="minecraft:gold_ingot" then
            turtle.select(i)
            turtle.dropDown()
        else
            if detail and detail.name then
                 turtle.select(i)
                turtle.drop()
            end
        end
    end
    if gold then
        craftGold()
    else
        turtle.suckUp()
    end
end
while true do
    checkInv()
end