
local args={...}

local function emptyInventory()
    print("inside emptyInventory")
    local _,info=turtle.inspect()
    print(info.name)
    if string.match( info.name,"chest") then
        for slot=1,16 do
            print("empying slot:",slot,turtle.getItemDetail(slot))
            turtle.select(slot)
            turtle.drop()
        end
    end
end

local function countItems()
    itemcnt=0
    for i = 1, 16 do
        if(turtle.getItemDetail(i)) then
             itemcnt=itemcnt+turtle.getItemCount(i)
        end 
        print('itemcnt:',itemcnt,'/',(16*4*4)*0.8)
     end
    return itemcnt
end

local function checkForFuel()
    for i = 1, 16, 1 do
       if(turtle.getItemDetail(i)) then
            if(turtle.getItemDetail(i).name=='minecraft:coal' or turtle.getItemDetail(i).name=='minecraft:charcoal') then
                print('found fuel at:',i)
                if(turtle.getFuelLimit()-turtle.getFuelLevel()>turtle.getItemCount(i)*8) then
                    turtle.select(i)
                    turtle.refuel(turtle.getItemCount())
                    print(turtle.getItemCount(i)-turtle.getFuelLimit()/8+turtle.getFuelLevel()/8)
                else
                    turtle.select(i)
                    turtle.refuel(turtle.getItemCount()-turtle.getFuelLimit()/8+turtle.getFuelLevel()/8)
                    print(turtle.getItemCount(i)-turtle.getFuelLimit()/8+turtle.getFuelLevel()/8)
                end
            end
       end
    end
    turtle.select(1)
end
local x,y,z
if not args[1] then
    x=16
end
if not args[1] then
    y=16
end
if not args[3] then
    z=16
end
local x,y,z=args[1],args[2],args[3]

local function mineCube()
    for i=1,x do
        for j=1,y do
            for k=1,z do
                
            end
        end
    end
end