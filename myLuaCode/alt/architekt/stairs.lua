local args={...}
local burnables={"minecraft:coal","minecraft:dried_kelp_block","minecraft:char_coal"}
local blocks={"minecraft:netherrack","minecraft:cobblestone","minecraft:"}
local counter
if args then
    counter=tonumber(args[1])
else
    print("you can also try adding a number")
end
turtle.select(1)
if not counter then
    counter=64
end
local function refuel()
    for i=1,16 do
        local info=turtle.getItemDetail(i)
        if info then
            for i,v in ipairs(burnables) do
                if info.name==v then
                    turtle.select(i)
                    if turtle.refuel(64) then
                        return true  
                    end   
                    
                end
            end
        end
    end
    return false
end
refuel()

local function selectBlocks(n)
    if not n then
        n=1
    end
    for i=n,16 do
        local info=turtle.getItemDetail(i)
        if info then
            for j,v in ipairs(blocks) do
                if info.name==v then
                    turtle.select(i)
                    return true
                end
            end
        end
    end
    return false
end

local function vorne()
    while not turtle.forward() do
        turtle.dig()
    end
end

local function runter()
   if not turtle.down() then
     turtle.digDown()
     turtle.down()
   end
end

local function platzieren()
    selectBlocks(turtle.getSelectedSlot())
    turtle.placeDown()
end

while counter>0 do
    vorne()
    turtle.digUp()
    runter()
    platzieren()
    local _,info=turtle.inspectDown()
    if info then
        if info=="minecraft:lava" then
            turtle.up()
        end
    end
    print(turtle.getFuelLevel())
    if turtle.getFuelLevel()==0 then
        if not refuel() then
            print("missing fuel")
            return -1
        end
    end
    counter=counter-1
    print("rest treppe:",counter)
end