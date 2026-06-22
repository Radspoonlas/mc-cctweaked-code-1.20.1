turtle.select(1)
while true do
    turtle.digDown()
    local detail=turtle.getItemDetail(1)
    if detail then
        turtle.drop()
    end
end