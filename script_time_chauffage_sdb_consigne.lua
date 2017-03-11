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
sdb_temp = otherdevices_temperature['Temp sdb']



commandArray = {}


if(sdb_consigne_onoff == 'On') then

    if (sdb_temp < sdb_consigne_valeur - hysteresis and sdb_onoff == 'Off') then

        commandArray['Radiateur sdb On/Off'] = 'On'
        print('----- Chauffage sdb ON ----- Temp: '..sdb_temp)

    elseif (sdb_temp >= sdb_consigne_valeur + hysteresis and sdb_onoff == 'On') then

        commandArray['Radiateur sdb On/Off'] = 'Off'
        print('----- Chauffage sdb OFF ----- Temp: '..sdb_temp)

    end

end


return commandArray
