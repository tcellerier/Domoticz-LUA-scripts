-------------------------------------------------------------
-- Script de gestion de la caméra Arlo
-------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


commandArray = {}

script_arlo_on = "python3 /home/pi/domoticz/scripts/python/arlo_cmd.py armed"
script_arlo_off = "python3 /home/pi/domoticz/scripts/python/arlo_cmd.py disarmed"

if (otherdevices['Camera'] == 'On') then

    print('-- Script Python -- Camera Arlo Armed (delay 3min)')
    
    commandArray['Wall Plug'] = 'On'
    os.execute('pkill -f "'..script_arlo_off..'"')
    os.execute('sleep 180 && '..script_arlo_on..' &')

    tts_function('Caméra activée')


-- On coupe la caméra dès détection de présence dans script_variable_all
elseif (otherdevices['Camera'] == 'Off') then 

    print('-- Script Python -- Camera Arlo Disarmed (delay 5min)')
    
    os.execute('pkill -f "'..script_arlo_on..'"')
    os.execute(script_arlo_off..' &')
    commandArray['Wall Plug'] = "Off AFTER 300"  -- On coupe l'alimentation après avoir correctement désarmé la caméra

    tts_function('Caméra off')

end

return commandArray
