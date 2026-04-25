Gui={}

function Gui:findMonitor()
    Gui.monitor=peripheral.find("monitor")
end

function Gui:showSelect(listOfSelections)

end

function Gui:showOptions(listOfOptions)

end

function Gui:showLoading(percentage)
    print(type(percentage))
    print(percentage)
    assert(type(percentage)=="number")
    local win=Gui.monitor
    win.setBackgroundColor(colours.white)
    win.setTextColour(colours.black)
    win.clear()
    local maxX,maxY = win.getSize()
    win.setCursorPos(maxX*0.25,maxY*0.5)
    win.write("[")
    win.setCursorPos(maxX*0.75,maxY*0.5)
    win.write("]")
    for i=1,percentage do
         win.setCursorPos(maxX*0.25+i*(maxX*(percentage/100)),maxY*0.5)
        win.write("|")
    end
end

function Gui:searchItem(listOfItems)
end

function Gui:idle( ... )
    -- body
end

function Gui:buttonListener()

end
return Gui