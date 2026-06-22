local modems={peripheral.find("modem")}
local monitors={peripheral.find("monitor")}
print(os.date)
print(os.time)
print(("this computer hast %d modems attached to it: %s"):format(#modems,table.unpack(modems)))
print(("this computer hast %d monitors attached to it: %s"):format(#monitors,table.unpack(monitors)))
print("my Name is: ",os.getComputerLabel() or "non existant"," my ID is: ", os.getComputerID())