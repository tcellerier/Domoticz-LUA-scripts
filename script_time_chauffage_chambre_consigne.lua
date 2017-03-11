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
chambre_temp = otherdevices_temperature['Temp chambre']



commandArray = {}



if(chambre_consigne_onoff == 'On') then

    if (chambre_temp < chambre_consigne_valeur - hysteresis and chambre_onoff == 'Off') then

        commandArray['Radiateur Chambre On/Off'] = 'On'
        print('----- Chauffage Chambre Confort ON ----- Temp: '..chambre_temp)

        if (chambre_confort == 'Off') then
            commandArray['Radiateur Chambre Confort'] = 'On'
        end


    elseif (chambre_temp >= chambre_consigne_valeur + hysteresis and chambre_onoff == 'On') then

        commandArray['Radiateur Chambre On/Off'] = 'Off'
        print('----- Chauffage Chambre OFF ----- Temp: '..chambre_temp)

    end

end

return commandArray


