local args={...}
local myChannel=2206
local storageChannel=22065
local nameChoices={"minecraft:","minecraft:stone","minecraft:iron_ingot"}
local completion = require "cc.completion"
local inventoryChoices ={"minecraft:","minecraft:dropper",
"minecraft:chest","minecraft:barrel","minecraft:hopper"}
local countChoices ={"1","16","64","128","256"}
local slotChoices ={"1","2","27"}
local modem=peripheral.find("modem") or error("no modem",0)
modem.open(myChannel)

print("please enter either: 'storeItems' or 'searchItem itemName'")
term.write(">")
local name=read(nil,nil,function(text) return completion.choice(text,nameChoices) end,nil)
print(name)
local count=read(nil,nil,function(text) return completion.choice(text,countChoices) end,nil)
local inv=read(nil,nil,function(text) return completion.choice(text,inventoryChoices) end,nil)
local slot=read(nil,nil,function(text) return completion.choice(text,slotChoices) end,nil)
count=tonumber(count)
slot=tonumber(slot)
modem.open(storageChannel)
modem.transmit(storageChannel,myChannel,{cmd="pushItem",name=name,count=count,inventory=inv,slot=slot})
modem.close(storageChannel)
