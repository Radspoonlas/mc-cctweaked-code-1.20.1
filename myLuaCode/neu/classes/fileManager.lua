local fileManager={}

function  fileManager:new(o)
    o=o or {}
    setmetatable(o,self)
    self.__index =self
    return o
end


function fileManager:loadList(file)
    local list={}
    local handle=io.open(file,"r")
    assert(handle~=nil)
    function Entry(a)
        local entry={}
        for i,v in pairs(a) do
            print(i,v)
            entry[i]=v
        end
        table.insert(list,entry)
    end
    local f=loadfile(file,"t",{Entry=Entry,list=list})
    f()
    os.sleep(5)
    return list
end


function fileManager:saveList(file,list)
    print("saving list in file:")
    local handle=io.open(file,"w")
    assert(handle~=nil)
    for i,Entry in pairs(list) do
        handle:write("Entry")
        print("now serialize")
        fileManager:serialize(Entry,handle)
    end
    handle:close()
    print("done saving")
end

function fileManager:serialize(o,handle)
    --aus der Lua lib:https://www.lua.org/pil/12.1.1.html
    --print(tostring(o))
    if type(o) == "number" then
        handle:write(o)
    elseif type(o) == "string" then
        handle:write(string.format("%q", o))
    elseif type(o) == "table" then
        handle:write("{\n")
        for k,v in pairs(o) do
            handle:write(" [ '", k, "' ]= ")
            fileManager:serialize(v,handle)
            handle:write(",\n")
        end
        handle:write("}\n")
    else
        --print(o)
        --print(tostring(o))
        --print(type(o))
        error("cannot serialize a " .. type(o))
    end
end

return fileManager