local EventList=require "EventManager"
local modem=require "modemManager"
local Oefen={peripheral.find "minecraft:oven"}


--[[ möglichkeiten sind:
    1. Inventar schmelzen also alle verschiedenen items in verschienen oefen gleichzeitig schmelzen
    2. Bestimmte Items Schmelzen (aktive oefen ueberpruefen)
    3. optimierung, sodass ich punktgenau zu schluss des schmelzen eines typs items einen anderen einfuegen kann
]]--

--[[events zu handlen sind:[
    smeltItem(item,count)?
    smeltInventory(source)?
]]--