------------------------------------------------------------------
-- Script d'action des scripts d'activation du chauffage du salon
--   en fonction d'une presence
--   (uniquement après l'heure du réveil si la planification auto est activée)
------------------------------------------------------------------


datetime = os.date("*t") -- table is returned containing date & time information
time_inminutes = 60 * datetime.hour + datetime.min
_, _, alarm1, alarm2 = string.find(uservariables['Var_Alarmclock'], "(%d+):(%d+)") -- extrait heure / minute de la variable alarmclock
alarmclock_inminutes = 60 * tonumber(alarm1) + tonumber(alarm2)

Script_Presence_Maison = tonumber(uservariables['Script_Presence_Maison']) or 0


commandArray = {}

-- Si le mode Auto présence est activé
if(otherdevices['Chauffage Auto Présence'] == 'On' and uservariables['Script_Mode_Maison'] == 'auto' and
  (otherdevices['Chauffage Auto Planification'] == 'Off'  or otherdevices['Chauffage Auto Planification'] == 'On' and (time_inminutes > alarmclock_inminutes or time_inminutes <= alarmclock_inminutes - 120) ) ) then -- Gestion du cas avec 'Auto Planif' ON qui permet de mettre le chauffage sdb le matin et cela même sans présence

    -- S'il y a une présence
    if(Script_Presence_Maison >= 1 or Script_Presence_Maison == -1) then

        if(otherdevices['Chauffage Salon Consigne'] == 'Off') then
            commandArray['Chauffage Salon Consigne'] = 'On'
        end
        if(otherdevices['Chauffage Sdb Consigne'] == 'Off') then
            commandArray['Chauffage Sdb Consigne'] = 'On'
        end

    else -- Possible interférence avec le scription chauffage_autoplanification
        if(otherdevices['Chauffage Salon Consigne'] == 'On') then
            commandArray['Chauffage Salon Consigne'] = 'Off'
        end
        if(otherdevices['Chauffage Sdb Consigne'] == 'On') then
            commandArray['Chauffage Sdb Consigne'] = 'Off'
        end
    end

end

-- Si on coupe le mode Auto, les chauffages consigne salon et consigne sdb sont coupé via le script script_device_chauffage.lua

return commandArray

