--------------------------------------------------------------------
-- Script de gestion des actions en cas de modificaiton de variable
--------------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


commandArray = {}


if (uservariablechanged['Script_Mode_Maison'] == 'auto') then
    tts_function('Mode Auto')

elseif (uservariablechanged['Script_Mode_Maison'] == 'manuel') then
    tts_function('Mode Manuel')

elseif (uservariablechanged['Script_Mode_Maison'] == 'absent') then
    tts_function('Mode absent')

    -- on coupe tous les chauffages s'ils etaient actifs au moment de l'activation
    commandArray['Radiateur Salon On/Off'] = 'Off'
    commandArray['Radiateur Chambre On/Off'] = 'Off'
    commandArray['Radiateur sdb On/Off'] = 'Off'
    
    -- On ferme le volet de la salle de bain
    commandArray['Volets sdb'] = 'Off'
    

elseif (uservariablechanged['Script_Mode_Volets'] == 'auto' and uservariables['Script_Mode_VoletsTardifs'] == 'off') then
    tts_function('Volets Auto')
elseif (uservariablechanged['Script_Mode_Volets'] == 'auto' and uservariables['Script_Mode_VoletsTardifs'] == 'on') then
    tts_function('Volets Tardif Auto')

elseif (uservariablechanged['Script_Mode_Volets'] == 'manuel') then
    tts_function('Volets Manuel')

elseif (uservariablechanged['Script_Mode_Volets'] == 'canicule') then
    tts_function('Volets auto canicule')

end



        
return commandArray
