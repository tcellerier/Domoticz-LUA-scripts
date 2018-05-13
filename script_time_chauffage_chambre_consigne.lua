-------------------------------------------------------------
-- Script d'action des scripts de gestion du chauffage de la chambre
------------------------------------------------------------ 

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


----------------
-- Paramètres --
----------------
hysteresis = 0.3



-- variables --
chambre_consigne_valeur = uservariables['Var_Chauffage_chambre_Consigne'] 
chambre_consigne_onoff = otherdevices['Chauffage Chambre Consigne']
chambre_onoff = otherdevices['Radiateur Chambre On/Off']
chambre_confort = otherdevices['Radiateur Chambre Confort']
chambre_temp = otherdevices_temperature['Temp chambre'] or 18
chambre_temp_timediff = timedifference(otherdevices_lastupdate['Temp chambre'])
mode_maison = uservariables['Script_Mode_Maison']


commandArray = {}


-- On active le chauffage de la chambre si le monde consigne est ON et si le monde maison n'est pas sur ABSENT
if(chambre_consigne_onoff == 'On' and mode_maison ~= 'absent') then

    if (chambre_temp < chambre_consigne_valeur - hysteresis and chambre_onoff == 'Off' and chambre_temp_timediff < 7200) then -- uniquement si la température a été mise à jour dans les 2 dernières heures

        commandArray['Radiateur Chambre On/Off'] = 'On'
        print('----- Chauffage Chambre Confort ON ----- Temp: '.. math.round(chambre_temp, 1, ',') )

        if (chambre_confort == 'Off') then
            commandArray['Radiateur Chambre Confort'] = 'On'
        end


    elseif (chambre_temp >= chambre_consigne_valeur + hysteresis and chambre_onoff == 'On') then

        commandArray['Radiateur Chambre On/Off'] = 'Off'
        print('----- Chauffage Chambre OFF ----- Temp: '.. math.round(chambre_temp, 1, ',') )

    end

end

return commandArray


