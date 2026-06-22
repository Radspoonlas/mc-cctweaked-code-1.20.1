
local function selectCocoa()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            if detail.name=="minecraft:cocoa_beans" then
                turtle.select(i)
                return true
            end
        end
    end
    return false
end

local function selectBamboo()
    local chest=peripheral.find("minecraft:chest")
    turtle.suckUp(9)
    local count=turtle.getItemCount()
    if count<9 then
        return false
    end
    turtle.transferTo(16)
    turtle.select(16)
    return true
end
local function placeChest()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            print(detail.name)
            turtle.select(i)
            if detail.name=="minecraft:chest" then
                turtle.placeUp()
            end
        end
    end
end

local function dropCocoa()
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail then
            if detail.name=="minecraft:cocoa_beans" then
                turtle.select(i)
                turtle.dropDown(64)
            end
        end
    end
end

local grid={1,2,3,5,6,7,9,10,11}

local function craftFuel()
    print("crafting fuel")
    placeChest()
    for i=1,16 do
        turtle.select(i)
        turtle.dropUp(64)
    end
    while selectBamboo() do
        for i,v in ipairs(grid) do
            print(v)
            turtle.transferTo(v,1)
        end
        local result,error=turtle.craft(1)
        print(error)
        turtle.craft(1)
        turtle.refuel(2)
        print(turtle.getFuelLevel())
    end
    turtle.suckUp()
    turtle.digUp()
end
local _,info=turtle.inspect()
local facingCocoa=false
if info then
    if info.name=="minecraft:cocoa" then
        facingCocoa=true
    end
end

while true do
    if turtle.getFuelLevel()<100 then
        _,info=turtle.inspect()
        if info then
            if info.name=="minecraft:bamboo" then
                turtle.dig()
            end
        end
        turtle.turnLeft()
        facingCocoa=false
        craftFuel()
    else
        _,info=turtle.inspect()
        while not facingCocoa do
            turtle.turnLeft()
            _,info=turtle.inspect()
            if info then
                if info.name=="minecraft:cocoa" then
                    facingCocoa=true
                end
            end
        end
        while info.state.age<2 do
            _,info=turtle.inspect()
            os.sleep(10)
        end
        while facingCocoa do
            if info.state.age==2 then
                turtle.dig()
                selectCocoa()
                turtle.place()
            end
            if not turtle.up() then
                facingCocoa=false
            end
        end
        while turtle.down() do
            turtle.down()
        end
        dropCocoa()
    end
end