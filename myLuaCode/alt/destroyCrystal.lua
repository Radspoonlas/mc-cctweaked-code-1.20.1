turtle.dig()
turtle.forward()
local _,info=turtle.inspectUp()
while info.name=="minecraft:obsidian" do
    turtle.digUp()
    turtle.up()
    _,info=turtle.inspectUp()
end
turtle.up()
local counter=0
while turtle.forward() do
    counter=counter+1
end
turtle.up()
turtle.dig()
turtle.turnLeft()
turtle.turnLeft()
for i=1,counter do
    turtle.forward()
end
turtle.forward()
while turtle.down() do
    print("coming home")
end

