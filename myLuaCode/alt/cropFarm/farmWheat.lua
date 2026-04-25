local function dropInventory()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            turtle.dropUp(64)
        end
    end
end
local function selectSeed()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            if detail=="minecraft:wheat_seeds" then
                turtle.select(i)
                return true
            end
        end
    end
end
while true do
    local _,info=turtle.inspect()
    if info then
        if info.state.age==7 then
            turtle.dig()
            selectSeed()
            turtle.place()
            dropInventory()
        end 
    end
    turtle.turnLeft()
end