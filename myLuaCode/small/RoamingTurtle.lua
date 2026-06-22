

function farmFarmland()
end


function inspectBlock()
    local _,info=turtle.inspect()
    --turtle ueberprueft auf farbe der wolle (als Beispiel) je nach farbe weiß er ob er links oder rechts abbiegen soll 
    -- oder der Block signalisiert eine station und ein Programm wird gestartet (abfarmen von crops) oder holzfarmen. oder os.sleep
    --findet 1/2 blöcke über spieler statt, sodass diese nicht beeinflusst werden.

end


while true do
    if not turtle.forward() then
        inspectBlock()
    end
end