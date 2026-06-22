local args={...}
local burnables={"minecraft:coal","minecraft:dried_kelp_block","minecraft:char_coal"}
local blocks={"minecraft:netherrack","minecraft:cobblestone","minecraft:"}
local counter
if args then
    counter=tonumber(args[1])
else
    print("you can also try adding a number")
end

local function selectBlocks(n)
    if not n then
        n=1
    end
    for i=n,16 do
        local info=turtle.getItemDetail(i)
        if info then
            print(info.name)
            for j,v in ipairs(blocks) do
                
                if info.name==v then
                    turtle.select(i)
                    return true  
                end
            end
        end
    end
    print("couldnt find blocks")
    return false
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
turtle.select(1)
if not counter then
    counter=64
end

while counter>0 do

    while turtle.forward() do
        print(counter>0)
        print(turtle.getFuelLevel())
        if turtle.getFuelLevel()==0 then
            if not refuel() then
                print("missing fuel")
                return -1
            end
        end
        print("selecting blocks")
        selectBlocks(turtle.getSelectedSlot())
        if not turtle.placeDown() then
            if not selectBlocks(turtle.getSelectedSlot()) then
                print("missing blocks")
                return 0
            end
            turtle.placeDown()
        end
        local _,info=turtle.inspectDown()
        if not _ then
            print("didnt place block")
            return -1
        end
        counter=counter-1
        print("remaining blocks:",counter)
    end
    if not turtle.forward() then
        print("path obstructed")
        return
    end
end
