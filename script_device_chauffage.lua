-------------------------------------------------------------
-- Script de gestion technique du chauffage 
------------------------------------------------------------ 

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


commandArray = {}


mode_maison = uservariables['Script_Mode_Maison']
chambre_temp = otherdevices_temperature['Temp chambre'] or 18
sdb_temp = otherdevices_temperature['Temp sdb'] or 18
salon_temp = otherdevices_temperature['Temp salon'] or 18
salon_consigne = uservariables['Var_Chauffage_salon_Consigne']


------------------------------
-- Chauffage chambre / sdb ---
------------------------------

---------------- Auto planif.  ----------------

-- Log Chauffage auto Chambre et Sdb ON
if (devicechanged['Chauffage Chambre-Sdb Auto'] == 'On') then
    tts_function('Activation chauffage planifié chambre et salle de bain') -- . Chambre '..math.round(chambre_temp, 1, ',')..' degrés, Salle de bain '..math.round(sdb_temp, 1, ',')..' degrés')

-- Log Chauffage auto Chambre et Sdb OFF
elseif (devicechanged['Chauffage Chambre-Sdb Auto'] == 'Off') then
    print('----- Chauffage Auto Chambre-Sdb OFF ---- Temp chambre: '.. math.round(chambre_temp, 1, ',') ..', Temp sdb: '.. math.round(sdb_temp, 1, ',') )
    tts_function('Désactivation chauffage planifié chambre et salle de bain') -- . Chambre '..math.round(chambre_temp, 1, ',')..' degrés, Salle de bain '..math.round(sdb_temp, 1, ',')..' degrés')
end

---------------- Consignes ----------------

-- Chauffage consigne Sdb on
if (devicechanged['Chauffage Sdb Consigne'] == 'On' and mode_maison ~= 'absent') then
   
    sdb_consigne = uservariables['Var_Chauffage_sdb_Consigne']
    if (sdb_temp < sdb_consigne) then
        commandArray['Radiateur sdb On/Off'] = 'On'
    else
        commandArray['Radiateur sdb On/Off'] = 'Off'
    end

-- Chauffage consigne Sdb off : stop les radiateurs sdb
elseif (devicechanged['Chauffage Sdb Consigne'] == 'Off') then
    commandArray['Radiateur sdb On/Off'] = 'Off'
    print('----- Chauffage sdb OFF (fin du mode consigne) ----- Temp: '..math.round(sdb_temp, 1, ',') )
end

-- Chauffage consigne chambre  on
if (devicechanged['Chauffage Chambre Consigne'] == 'On' and mode_maison ~= 'absent') then

    chambre_consigne = uservariables['Var_Chauffage_chambre_Consigne'] 
    if (chambre_temp < chambre_consigne) then
        commandArray['Radiateur Chambre On/Off'] = 'On'
    else
        commandArray['Radiateur Chambre On/Off'] = 'Off'
    end

-- Chauffage consigne chambre  off : stop les radiateurs chambre
elseif (devicechanged['Chauffage Chambre Consigne'] == 'Off') then
    commandArray['Radiateur Chambre On/Off'] = 'Off'
    print('----- Chauffage Chambre OFF (fin du mode consigne) ----- Temp: '..math.round(chambre_temp, 1, ',') )
end




----------------------
-- Chauffage salon ---
----------------------

---------------- Auto présence ----------------
-- Chauffage salon Auto ON
if(devicechanged['Chauffage Salon Auto'] == 'On' 
  and uservariables['Script_Mode_Maison'] == 'auto' 
  and uservariables['Script_Presence_Maison'] >= 1 or uservariables['Script_Presence_Maison'] == -1
  and otherdevices['Chauffage Salon Consigne'] == 'Off') then
    commandArray['Chauffage Salon Consigne'] = 'On'

-- Chauffage salon Auto OFF
elseif (devicechanged['Chauffage Salon Auto'] == 'Off') then
    commandArray['Chauffage Salon Consigne'] = 'Off'
end

---------------- Consigne - PID Heating System Salon ----------------
-- Consigne Chauffage Salon On
if (devicechanged['Chauffage Salon Consigne'] == 'On') then

    commandArray['Variable:Script_Chauffage_SomErreur'] = '' -- Remise à zéro de SomErreur 
    commandArray['Radiateur Salon Confort'] = 'On'

    if (mode_maison ~= 'absent') then
        if (salon_temp < salon_consigne) then -- Allume le chauffage si nécessaire
            commandArray['Radiateur Salon On/Off'] = 'On'
        else
            commandArray['Radiateur Salon On/Off'] = 'Off'
        end
    end
    tts_function('Activation chauffage consigne salon') -- , '.. math.round(salon_temp, 1, ',') ..' degrés

-- Consigne Chauffage Salon Off => On éteint les radiateurs
elseif (devicechanged['Chauffage Salon Consigne'] == 'Off') then

    commandArray['Radiateur Salon On/Off'] = 'Off'
    commandArray['Radiateur Salon Confort'] = 'Off'

    print('----- Chauffage Salon Consigne OFF - Coupure chauffage salon ----- Temp: '.. math.round(salon_temp, 1, ',') )
    tts_function('Désactivation chauffage consigne salon') -- , '..math.round(salon_temp, 1, ',')..' degrés

end




return commandArray
