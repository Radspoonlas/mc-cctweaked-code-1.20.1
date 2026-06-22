term.setBackgroundColor(colours.white)
local x,y=term.getSize()
for i=1,y do
    print("")
end
term.setTextColour(colours.black)
term.setCursorPos(1,x/2)
term.write(SettingsManager)
while true do
    print("waiting for input")
    local event,key,press =os.pullEvent "key"
    print("pressed",key)
end