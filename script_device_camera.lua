-------------------------------------------------------------
-- Script de gestion de la caméra Arlo
-------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")



commandArray = {}

script_arlo = "python3 /home/pi/domoticz/scripts/python/arlo.py"


if (devicechanged['Camera'] == 'On') then
	
    print('-- Script Python -- Camera Arlo Armed')
    os.execute(script_arlo .. ' On &')
    tts_function('Surveillance caméra activée')


elseif (devicechanged['Camera'] == 'Off') then 

    print('-- Script Python -- Camera Arlo Disarmed')
    os.execute(script_arlo .. ' Off &')
    tts_function('Surveillance caméra désactivée')

end

return commandArray
