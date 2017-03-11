-------------------------------------------------------------
-- Script de gestion technique du chauffage automatique

-- Stop les radiateurs lorsque le mode auto est désactivé
------------------------------------------------------------ 


commandArray = {}


-- Chauffage auto Chambre et Sdb OFF
if (devicechanged['Chauffage Chambre-Sdb Auto'] == 'Off') then

    chambre_temp = otherdevices_temperature['Temp chambre']
    sdb_temp = otherdevices_temperature['Temp sdb']
    print('----- Chauffage Auto Chambre-Sdb OFF ---- Temp chambre: '..chambre_temp..', Temp sdb: '..sdb_temp)


-- Chauffage consigne Sdb on
elseif (devicechanged['Chauffage Sdb Consigne'] == 'On') then
   
    sdb_consigne= uservariables['Var_Chauffage_sdb_Consigne']
    sdb_temp = otherdevices_temperature['Temp sdb']

    if (sdb_temp < sdb_consigne) then
        commandArray['Radiateur sdb On/Off'] = 'On'
    else
        commandArray['Radiateur sdb On/Off'] = 'Off'
    end

-- Chauffage consigne Sdb off : stop les radiateurs sdb
elseif (devicechanged['Chauffage Sdb Consigne'] == 'Off') then

    commandArray['Radiateur sdb On/Off'] = 'Off'
    sdb_temp = otherdevices_temperature['Temp sdb']
    print('----- Chauffage sdb OFF (fin du mode consigne) ----- Temp: '..sdb_temp)


-- Chauffage consigne chambre  on
elseif (devicechanged['Chauffage Chambre Consigne'] == 'On') then

    chambre_temp = otherdevices_temperature['Temp chambre']
    chambre_consigne = uservariables['Var_Chauffage_chambre_Consigne'] 

    if (chambre_temp < chambre_consigne) then
        commandArray['Radiateur Chambre On/Off'] = 'On'
    else
        commandArray['Radiateur Chambre On/Off'] = 'Off'
    end

-- Chauffage consigne chambre  off : stop les radiateurs chambre
elseif (devicechanged['Chauffage Chambre Consigne'] == 'Off') then

    commandArray['Radiateur Chambre On/Off'] = 'Off'
    chambre_temp = otherdevices_temperature['Temp chambre']
    print('----- Chauffage Chambre OFF (fin du mode consigne) ----- Temp: '..chambre_temp)
end



-- PID Heating System Salon
-- Remise à zéro de SomErreur 
-- Allume le chauffage si nécessaire
if (devicechanged['Chauffage Salon Consigne'] == 'On') then

    commandArray['Variable:Script_Chauffage_SomErreur'] = ''
    commandArray['Radiateur Salon Confort'] = 'On'

    salon_consigne = uservariables['Var_Chauffage_salon_Consigne']
    salon_temp = otherdevices_temperature['Temp salon']

    if (salon_temp < salon_consigne) then
        commandArray['Radiateur Salon On/Off'] = 'On'
    else
        commandArray['Radiateur Salon On/Off'] = 'Off'
    end


-- Consigne Chauffage Salon Off => On éteint les radiateurs
elseif (devicechanged['Chauffage Salon Consigne'] == 'Off') then

    commandArray['Radiateur Salon On/Off'] = 'Off'
    commandArray['Radiateur Salon Confort'] = 'Off'

    salon_temp = otherdevices_temperature['Temp salon']
    print('----- Chauffage Salon Consigne OFF - Coupure chauffage salon ----- Temp: '..salon_temp)
end


-- Chauffage salon Auto OFF
if (devicechanged['Chauffage Salon Auto'] == 'Off') then
    commandArray['Chauffage Salon Consigne'] = 'Off'
end



return commandArray
