local crops={"minecraft:potato","minecraft:beet_root","minecraft:carrot"
,"minecraft:wheat","minecraft:nether_wart"}
local age7={

}
local age3={

}
local noReplant={"minecraft:pumpkin","minecraft:melon","minecraft:sugar_cane","minecraft:cactus"}
local function dropInventory()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            turtle.dropUp(64)
        end
    end
end

local function findSeed()

end
local function farmAge3(crop)
    if info.state.age==3 then
        turtle.dig()
        
        dropInventory()
    end
end

local function farmAge7(crop)
    if info.state.age==7 then
        turtle.dig()
        dropInventory()
    end
end

local function farmNoReplant()
    turtle.dig()
    dropInventory()
end
print("starting inplaceFarm:")
while true do
    local _,info=turtle.inspect()
    if info then
        for crop in age3 do
            if info.name==crop then
                farmAge3(crop)
                break
            end
        end
        for crop in age7 do
            if info.name==crop then
                farmAge7(crop)
                break
            end
        end
        for crop in noReplant do
            if info.name==crop then
                farmNoReplant()
                break
            end
        end
    end
    turtle.turnLeft()
end