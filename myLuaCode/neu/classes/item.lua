local item={properties={name="",count=0,limit=1},instances={},lastAccess={inventory=false,slot=0}}
function item:new(o)
    print("in item:new type of o:",type(o))
    o=o or {}
    setmetatable(o,self)
    self.__index =self
    return o
end
function item:newInstance(i,s)
    table.insert(item.instances,{inventory=peripheral.getName(i),slot=s})
end

function item:add(d)
    item.properties.count= item.properties.count+d
end
function item:getName()
    return item.properties.name
end
function item:getCount()
    return item.properties.count
end
function item:getLimit()
    return item.properties.limit
end

function item:locate()
    for i,v in pairs(item.instances) do
        return {v}
    end
end
function item:getInstances()
    return item.instances
end
function item:getProperties()
    return {item.properties.name,item.properties.count,item.properties.limit}
end
function item:isStackable()
    return item.properties.limit>1
end
return item
