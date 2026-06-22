local function findGold()
    local detail=turtle.getItemDetail(1)
    for i = 1, 16, 1 do
        detail=turtle.getItemDetail(1)
        if detail and detail.name and detail.name=="minecraft:gold_ingot" then
            turtle.select(i)
            return true
        end
    end
    return false
end

while true do
    if findGold() then
        turtle.drop()
    else
        turtle.select(1)
        turtle.dropDown()
        turtle.suckUp(1)
        turtle.drop()
    end
    os.sleep(10)
    turtle.suck()
end



turtle.select()