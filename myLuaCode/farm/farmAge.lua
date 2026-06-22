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
        if info.state.age==7 then
            turtle.dig()
            turtle.place()
            dropInventory()
        end
    end
    turtle.turnLeft()
end