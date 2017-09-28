-------------------------------------------------------------
-- Script de gestion de la caméra Arlo
-------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")



commandArray = {}


script_arlo = "python3 /home/pi/domoticz/scripts/python/arlo.py"



if (devicechanged['Camera'] == 'On') then
	
    print('-- Script Python -- Camera Arlo Armed')
    batterie = os.execute(script_arlo .. ' On &')
    tts_function('Caméra armée')


elseif (devicechanged['Camera'] == 'Off') then 

    print('-- Script Python -- Camera Arlo Disarmed')
    batterie = os.execute(script_arlo .. ' Off &')
    tts_function('Caméra désarmée')

end

return commandArray
