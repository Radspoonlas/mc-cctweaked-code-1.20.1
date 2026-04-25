print("before:",turtle.getFuelLevel(),"/",turtle.getFuelLimit())
for i=1,16 do
    local info=turtle.getItemDetail(i)
    if info then
        if info.name=="minecraft:dried_kelp_block" or string.match(info.name,"coal") then
            turtle.select(i)
            turtle.refuel()
        end
    end
   
end

turtle.refuel()
print("after:",turtle.getFuelLevel(),"/",turtle.getFuelLimit())