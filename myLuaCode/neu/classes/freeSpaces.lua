local freeSpaces={spaces={}}
function freeSpaces:init(o)
    o=o or {}
    setmetatable(o,self)
    self.__index =self
    return o
end
function freeSpaces:add(v)
    table.insert( self.spaces, v )
end

function freeSpaces:remove()
    return table.remove(self.spaces)
end

function freeSpaces:list()
    return self.spaces
end

return freeSpaces