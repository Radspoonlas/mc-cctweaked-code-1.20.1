local myFile="test"
io.output(myFile)
local handle=io.open(myFile,"w")
handle:write("Entry{\n ' test ',\n 'test2',\n 325265\n}\n")
handle:close()
handle=io.open(myFile,"r")
local myList={}
function Entry(b)table.insert(myList,b) print(b) end
local foo=loadfile(myFile,"t",_ENV)
foo()
dofile(myFile)
print(#myList)
for i,v in pairs(myList) do print(i,v) end