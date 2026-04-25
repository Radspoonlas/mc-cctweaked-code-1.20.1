local args={...}
local TUNNEL_LIMIT
if args then
    print("set TUNNEL_LIMIT to:",args[1])
    TUNNEL_LIMIT=tonumber(args[1])
else
    print("you can also try adding a number as distanceLimit")
end


local burnables={"minecraft:coal","minecraft:dried_kelp_block","minecraft:char_coal"}

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
local Limit=true
local function updateLimit()
    if TUNNEL_LIMIT then
        TUNNEL_LIMIT=TUNNEL_LIMIT-1
        if TUNNEL_LIMIT==0 then
            Limit=false
        end
    end

end
print(TUNNEL_LIMIT)
while Limit do
    if not turtle.dig() then
        return
    end
    print("fuel Level:",turtle.getFuelLevel())
    local _,info=turtle.inspect()
    if info then
        if info.name=="minecraft:lava" then
            turtle.turnLeft()
            turtle.turnLeft()
            turtle.forward()
            turtle.forward()
            return
        end
    end
    turtle.forward()
    turtle.digUp()
    updateLimit()
    print("UPPER LIMIT:",TUNNEL_LIMIT)
end
