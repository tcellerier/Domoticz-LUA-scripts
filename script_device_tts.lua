-------------------------------------------------------------
-- Script de gestion des commandes vocales
-------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


commandArray = {}


-- Réveil
if (devicechanged['Alarm Clock Weekdays'] == 'On') then
	_, _, alarm1, alarm2 = string.find(uservariables['Var_Alarmclock'], "(%d+):(%d+)") -- extrait heure / minute de la variable alarmclock
    tts_function('Réveil activé à '..alarm1..' heure '..alarm2)      

elseif (devicechanged['Alarm Clock Weekdays'] == 'Off') then 
    tts_function('Réveil désactivé')

end

return commandArray
