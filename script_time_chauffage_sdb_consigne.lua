-------------------------------------------------------------
-- Script d'action des scripts de gestion du chauffage de la salle de bain
------------------------------------------------------------ 

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


----------------
-- Paramètres --
----------------
hysteresis = 0.3



-- variables --
sdb_consigne_valeur = uservariables['Var_Chauffage_sdb_Consigne']
sdb_consigne_onoff = otherdevices['Chauffage Sdb Consigne']
sdb_onoff = otherdevices['Radiateur sdb On/Off']
sdb_temp = otherdevices_temperature['Temp sdb'] or 18
sdb_temp_timediff = timedifference(otherdevices_lastupdate['Temp sdb'])
mode_maison = uservariables['Script_Mode_Maison']


commandArray = {}


-- On active le chauffage de la sdb si le monde consigne est ON et si le monde maison n'est pas sur ABSENT
if(sdb_consigne_onoff == 'On' and mode_maison ~= 'absent') then

    if (sdb_temp < sdb_consigne_valeur - hysteresis and sdb_onoff == 'Off' and sdb_temp_timediff < 7200) then -- uniquement si la température a été mise à jour dans les 2 dernières heures

        commandArray['Radiateur sdb On/Off'] = 'On'
        print('----- Chauffage sdb ON ----- Temp: '.. math.round(sdb_temp, 1, ',') )

    elseif (sdb_temp >= sdb_consigne_valeur + hysteresis and sdb_onoff == 'On') then

        commandArray['Radiateur sdb On/Off'] = 'Off'
        print('----- Chauffage sdb OFF ----- Temp: '.. math.round(sdb_temp, 1, ',') )

    end

end


return commandArray
