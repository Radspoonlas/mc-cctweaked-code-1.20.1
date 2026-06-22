local function dropInventory()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            turtle.dropUp(64)
        end
    end
end

while true do
    local _,info=turtle.inspect()
    if info then
        turtle.dig()
        dropInventory()
    end
    turtle.turnLeft()
end