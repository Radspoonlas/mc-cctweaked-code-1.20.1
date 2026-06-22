
local function findBucketBarrel()
    print("finding BucketBarrel")
    local _,detail=turtle.inspect()
    if detail and detail.name then
        if detail.name=="minecraft:barrel" then
            print("found barrel")
            return
        
        elseif detail.name=="minecraft:cauldron" or detail.name=="minecraft:lava_cauldron"then
            turtle.turnLeft()
            while turtle.forward() do
            print("returning to Barrel...")
            print("found barrelcauld")
            end
        elseif detail.name=="minecraft:chest" then
            turtle.turnRight()
            print("found barrelchest")
        end
    else
        turtle.turnLeft()
        print("didnt find barrel")
        findBucketBarrel()
    end
end
local  function checkLavaBuckets()
    print("checking LavaBuckets")
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail and detail.name and detail.name=="minecraft:lava_bucket" then
            turtle.select(i)
            turtle.drop()
        end
    end
end

local function checkFuel()
    print("checking Fuel: turtle.getFuelLevel()")
    if turtle.getFuelLevel()>(turtle.getFuelLimit()-1000)then
        return
    end 
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail and detail.name and detail.name=="minecraft:lava_bucket" then
            turtle.select(i)
            turtle.refuel()
            return
        end
    end
end

local function checkEmptyBuckets()
    print("looking for empty buckets")
    for i=1,16 do
        local detail=turtle.getItemDetail(i)
        if detail and detail.name and detail.name=="minecraft:bucket" then
            print("buckets remaining at least: "..detail.count)
            turtle.select(i)
            return
        end
    end
    print("failed to locate bucket")
    os.sleep(10)
    os.shutdown()
end
findBucketBarrel()
while true do
    
    turtle.turnLeft()
    checkFuel()
    checkLavaBuckets()
    turtle.turnRight()
    turtle.select(1)
    turtle.drop()
    turtle.suck()
    checkEmptyBuckets()
    turtle.turnRight()
    local _,detail=turtle.inspect()
    while detail and detail.name do
        turtle.place()
        turtle.turnRight()
        turtle.forward()
        turtle.turnLeft()
        _,detail=turtle.inspect()
    end
    turtle.turnLeft()
    turtle.forward()
    findBucketBarrel()
    os.sleep(1000)
end