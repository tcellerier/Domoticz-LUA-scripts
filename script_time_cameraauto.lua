--------------------------------------------------------------------
-- Script de gestion de la caméra en fonction de la présence
-- ( ne pas appeler le fichier script_variable_camera sinon cela ne fonctionne pas )
--------------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")

commandArray = {}

datetime = os.date("*t") -- table is returned containing date & time information
Script_Presence_Maison = tonumber(uservariables['Script_Presence_Maison']) or 0


-- Lorsque la présence est confirmée
if (Script_Presence_Maison >= 1 and uservariables['Script_Mode_Maison'] ~= 'manuel') then

    if (otherdevices['Camera'] == 'On') then 
        commandArray['Camera'] = 'Off'
    end

-- entre 5 et 10 min après qu'il n'y ait plus de présence détectée (ie entre 5 et 10 min après Script_Presence_Maison = 0)
elseif (Script_Presence_Maison == 0 and datetime.hour >= 6 and datetime.hour < 23 and timedifference(uservariables_lastupdate['Script_Presence_Maison']) >= 5*60 and timedifference(uservariables_lastupdate['Script_Presence_Maison']) <= 10*60 and uservariables['Script_Mode_Maison'] ~= 'manuel')  then

    if (otherdevices['Camera'] == 'Off') then
        commandArray['Camera'] = 'On'
    end

end



-- Mode absent : On active la caméra au bout de 15 min
if (uservariables['Script_Mode_Maison'] == 'absent' and timedifference(uservariables_lastupdate['Script_Mode_Maison']) >= 15*60) then
    
    if (otherdevices['Camera'] == 'Off') then
        commandArray['Camera'] = 'On'
    end

end

        
return commandArray
