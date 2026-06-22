
local inputs={}
local knownPeripherals=peripheral.getNames()
local outputs={}
print(knownPeripherals)
for key, periph in pairs(knownPeripherals) do
    if peripheral.getType(periph)=="minecraft:hopper" then
        
        outputs[#outputs+1]=periph
        print(#outputs)
    elseif peripheral.getType(periph)=="minecraft:chest" then
        inputs[#outputs]=peripheral.wrap(periph)
    end
end
print(#outputs)
table.sort(outputs)
for n,output in pairs(outputs) do
    outputs[n]=peripheral.wrap(output)
end
local disposer=peripheral.find("minecraft:dropper")
local filter={"minecraft:potion","minecraft:enchanted_book","minecraft:splash_potion","minecraft:iron_boots"}
local whiteList={"minecraft:soul_sand",
"minecraft:gravel",
"minecraft:spectral_arrow",
"minecraft:string",
"minecraft:iron_nugget",
"minecraft:obsidian",
"minecraft:crying_obsidian",
"minecraft:leather",
"minecraft:blackstone",
"minecraft:nether_brick",
"minecraft:fire_charge",
"minecraft:ender_pearl"}
local function isWhiteListed(itemName,chest,slot)
    for k, whiteListedItem in pairs(whiteList) do
        if whiteListedItem==itemName then
            print(#outputs.." number of outputs and ".. k.." expected number")
            local amount=chest.pushItems(peripheral.getName(outputs[k]),slot)
            while amount==0 do
                print("failed to move Item whitelist")
                print(itemName,chest,slot)
                os.sleep(1)
                amount=chest.pushItems(peripheral.getName(outputs[k]),slot)
            end
            return true
        end
    end
    return false
end
local function isFiltered(itemName,chest,slot)
    for k, filteredItem in pairs(filter) do
        if filteredItem==itemName then
            print(#outputs.." number of outputs and ".. k.." expected number")
            print((disposer))
            print(peripheral.getName(disposer))
            local amount= chest.pushItems(peripheral.getName(disposer),slot)
            while amount==0 do
                print("failed to move Item filter")
                os.sleep(1)
                amount= chest.pushItems(peripheral.getName(disposer),slot)
            end
            return true
        end          
    end
    return false
end
while true do
    for i, chest in pairs(inputs) do
        for j, item in pairs(chest.list()) do
            if item and item.name then
                
                if not isWhiteListed(item.name,chest,j) then
                     if not isFiltered(item.name,chest,j) then
                        local amount=chest.pushItems(peripheral.getName(outputs[#outputs]),j)
                        while amount==0 do
                            print("failed to move Item other")
                            os.sleep(1)
                            amount=chest.pushItems(peripheral.getName(outputs[#outputs]),j)
                        end
                    end
                end
            end
        end
    end
end