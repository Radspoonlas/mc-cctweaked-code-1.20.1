
local info=turtle.getItemDetail()
for i=1,16 do
    info=turtle.getItemDetail(i)
    if info then
        if string.match(info.name,"powder")then 
            turtle.select(i)
            for i=1,info.count do
                turtle.place()
                turtle.dig()
            end
        end
    end
end
turtle.select(1)