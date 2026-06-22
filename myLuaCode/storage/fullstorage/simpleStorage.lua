local cache={}
local completion = require "cc.completion"
local cmdHistory={"monitor","getCount","storeItems","searchItem minecraft:"}
local cmdChoices={"searchItem minecraft:","storeItems","monitor","getCount minecraft:"}

local function searchItem(itemName)
    local storage={peripheral.find("minecraft:barrel")}
    for i,barrel in pairs(storage) do
        for i,item in pairs(barrel.list()) do
            if item and item.name==itemName then
               peripheral.find("minecraft:dropper").pullItems(peripheral.getName(barrel),i,64)
               --print("found Item")
               return
            end
        end
    end
end

local function storeItem(ItemName,slot,fromInv)
    --print("called fun storeItem")
    local storage={peripheral.find("minecraft:barrel")}
    for j,barrel in pairs(storage) do
        local items=barrel.list()
        for i = 1, 27 do
            if items[i] then

                if items[i].name==ItemName and (items[i].count<barrel.getItemDetail(i).maxCount) then
                    --print("found same item")
                    barrel.pullItems(fromInv,slot)
                    return
                end
            else
                barrel.pullItems(fromInv,slot)
                return
            end
        end
    end
end

local function handleInput()
    print("please enter either: 'storeItems' or 'searchItem itemName'")
    term.write(">")
    local msg=read(nil,cmdHistory,function(text) return completion.choice(text,cmdChoices) end,nil)
    print(msg)
    if msg:match('storeItems') then
        --print("got into storeitems")
        local output=peripheral.find("minecraft:dropper")
        local inputs={peripheral.find("minecraft:chest")}
        for i,item in pairs(output.list()) do
            print(i,item)
            print(item.name)
            storeItem(item.name,i,peripheral.getName(output))
        end
        --print(#inputs,inputs[1])
        for n=1,#inputs do
            --print(#inputs[n].list(),inputs[n].list())
            for i=1,#inputs[n].list() do
                local item=inputs[n].getItemDetail(i)
            if item then
                storeItem(item.name,i,peripheral.getName(inputs[n]))
            end

        end
    end
    elseif msg:match('searchItem') then
        msg=msg:gsub("searchItem ",'')
        print("searching for:")
        print(msg)
        searchItem(msg)
    elseif msg:match('getCount') then
        msg=msg:gsub("getCount ",'')
    end
end
while true do
    handleInput()
end

