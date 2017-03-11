-------------------------------------------------------------
-- Script de gestion des commandes vocales
-------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


commandArray = {}



if (devicechanged['Alarm Clock Weekdays'] == 'On') then
	_, _, alarm1, alarm2 = string.find(uservariables['Var_Alarmclock'], "(%d+):(%d+)") -- extrait heure / minute de la variable alarmclock
    tts_function('Réveil activé à '..alarm1..' heure '..alarm2)      

elseif (devicechanged['Alarm Clock Weekdays'] == 'Off') then 
    tts_function('Réveil désactivé')


elseif (devicechanged['Chauffage Chambre-Sdb Auto'] == 'On') then
    chambre_temp = math.round(otherdevices_temperature['Temp chambre'], 1, ',')
    sdb_temp = math.round(otherdevices_temperature['Temp sdb'], 1, ',')
    tts_function('Activation chauffage auto chambre et salle de bain. Chambre '..chambre_temp..' degrés, Salle de bain '..sdb_temp..' degrés')

elseif (devicechanged['Chauffage Chambre-Sdb Auto'] == 'Off') then
    chambre_temp = math.round(otherdevices_temperature['Temp chambre'], 1, ',')
    sdb_temp = math.round(otherdevices_temperature['Temp sdb'], 1, ',')
    tts_function('Désactivation chauffage auto chambre et salle de bain. Chambre '..chambre_temp..' degrés, Salle de bain '..sdb_temp..' degrés')

elseif (devicechanged['Chauffage Salon Consigne'] == 'On') then
    salon_temp = math.round(otherdevices_temperature['Temp salon'], 1, ',')
    tts_function('Activation chauffage auto salon') -- , '..salon_temp..' degrés

elseif (devicechanged['Chauffage Salon Consigne'] == 'Off') then
    salon_temp = math.round(otherdevices_temperature['Temp salon'], 1, ',')
    tts_function('Désactivation chauffage auto salon') -- , '..salon_temp..' degrés


end

return commandArray
