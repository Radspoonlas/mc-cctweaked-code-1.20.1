local function dropInventory()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            turtle.dropUp(64)
        end
    end
end

local function searchSeed()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            if string.match(detail.name,"seed") then
                turtle.select(i)
                return
            end
        end
    end
end

while true do
    local _,info=turtle.inspect()
    if info then
        if info.state.age==3 then
            turtle.dig()
            searchSeed()
            turtle.place()
            dropInventory()
            turtle.select(1)
        end
    end
    turtle.turnLeft()
end