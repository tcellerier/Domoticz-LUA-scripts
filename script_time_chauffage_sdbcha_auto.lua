-------------------------------------------------------------
-- Script d'action des scripts de gestion du chauffage
------------------------------------------------------------ 
--   1. Mode Auto
--       => Si ON alors active ce script
--   2. Device 'Chauffage Chambre-Sdb Auto'
--       => Si ON, alors on active ce script
-------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


----------------
-- Paramètres --
----------------
dehors_min = 15

chambre_matin_start = -25 -- démarre le chauffage chambre en monde confort x min le matin avant reveil
chambre_matin_end = -10    -- stop le chauffage chambre x min le matin avant reveil
sdb_matin_start =  -40
sdb_matin_end = 0

----------------
----------------


commandArray = {}



-- On détermine si on est un jour ferie
is_jour_ferie = 0
date_jour = os.date("%x")
for jourferie_i in string.gmatch(uservariables['Var_Jours_Feries'], "%S+") do  -- %S+ matche tout ce qui n'est pas un espace
    _, _, jour_ferie_j, jour_ferie_m, jour_ferie_a = string.find(jourferie_i, "(%d+)/(%d+)/(%d+)")
    date_jour_ferie = os.date("%x", os.time{day=jour_ferie_j, month=jour_ferie_m, year='20'..jour_ferie_a})
    if (date_jour_ferie == date_jour) then  -- Si on est dans la journée féri
        is_jour_ferie = 1
        break -- on sort de la bouche si on sait qu'on est un jour féri?
    end
end



 -- variables --
datetime = os.date("*t") -- table is returned containing date & time information
time_inminutes = 60 * datetime.hour + datetime.min
_, _, alarm1, alarm2 = string.find(uservariables['Var_Alarmclock'], "(%d+):(%d+)") -- extrait heure / minute de la variable alarmclock
alarmclock_inminutes = 60 * tonumber(alarm1) + tonumber(alarm2)

-- Temperature chauffage
chambre_consigne_valeur = uservariables['Var_Chauffage_chambre_Consigne'] 
chambre_consigne_onoff = otherdevices['Chauffage Chambre Consigne']
sdb_consigne_onoff = otherdevices['Chauffage Sdb Consigne']
chambre_temp = otherdevices_temperature['Temp chambre']
dehors_temp = otherdevices_temperature['Temp dehors']





-- Gestion automatique du chauffage uniquement 
--    si le mode auto est activé 
--    et si le mode chauffage est activé
--    et si la temperature dehors est supérieure au minmium
if (uservariables['Script_Mode_Maison'] == 'auto' and otherdevices['Chauffage Chambre-Sdb Auto'] == 'On' and not (dehors_temp > dehors_min ) ) then

    --------------------
    -- Tous les jours --

    -----------------------
    -- Chauffage chambre le soir 
    -- entre 23h et minuit
    if (datetime.hour >= 23) then

        if (chambre_consigne_onoff == 'Off') then
            commandArray['Chauffage Chambre Consigne'] = 'On'
        end

    -- entre 22h30 et 23h si temperature vraiment basse, on allume le chauffage
    elseif (datetime.hour >= 22 and datetime.min >= 30 and chambre_temp <= chambre_consigne_valeur - 1.5) then

        if (chambre_consigne_onoff == 'Off') then
            commandArray['Chauffage Chambre Consigne'] = 'On'
        end

    -- Sinon on met le chauffage toute la nuit (jusqu'a l'heure du reveil)
    elseif (time_inminutes < alarmclock_inminutes + chambre_matin_start) then

        if (chambre_consigne_onoff == 'Off') then
            commandArray['Chauffage Chambre Consigne'] = 'On'
        end

    -- Sinon on coupe le chauffage
    elseif (time_inminutes > alarmclock_inminutes + chambre_matin_end and time_inminutes <= alarmclock_inminutes + chambre_matin_end + 3 ) then

        if (chambre_consigne_onoff == 'On') then
            commandArray['Chauffage Chambre Consigne'] = 'Off'
        end

    end



    -------------
    -- semaine --
    if (datetime.wday ~= 7 and datetime.wday ~= 1 and is_jour_ferie == 0) then

        -----------------------
        -- Chauffage chambre le matin

        -- Entre X et Y min avant le reveil
        --   uniquement si le device 'Alarm Clock Weekdays' == 'On' 
        if (otherdevices['Alarm Clock Weekdays'] == 'On' and time_inminutes >= alarmclock_inminutes + chambre_matin_start and time_inminutes <= alarmclock_inminutes + chambre_matin_end ) then

            if (chambre_consigne_onoff == 'Off') then
                commandArray['Chauffage Chambre Consigne'] = 'On'
            end

        end
               
        -- Sinon on coupe le chauffage
        --   => géré dans la partie 'tous les jours'


        -----------------
        -- Chauffage sdb
                -- Entre X et Y min avant le reveil
        --   uniquement si le device 'Alarm Clock Weekdays' == 'On'
        if (otherdevices['Alarm Clock Weekdays'] == 'On' and time_inminutes >= alarmclock_inminutes + sdb_matin_start and time_inminutes <= alarmclock_inminutes + sdb_matin_end ) then

            if (sdb_consigne_onoff == 'Off') then
                commandArray['Chauffage Sdb Consigne'] = 'On'
            end

        -- Sinon on coupe le chauffage 
        elseif (time_inminutes > alarmclock_inminutes + sdb_matin_end and time_inminutes <= alarmclock_inminutes + sdb_matin_end + 3) then 

            if (sdb_consigne_onoff == 'On') then
                commandArray['Chauffage Sdb Consigne'] = 'Off'
            end
        end

    end

    ---------------------------
    -- weekend ou jour férié -- 
    if (datetime.wday == 7 or datetime.wday == 1 or is_jour_ferie == 1) then


        -----------------------
        -- Chauffage chambre le matin

        -- Entre X et Y min avant le reveil
        --   uniquement si le device 'Alarm Clock Weekdays' == 'On' 
        if (otherdevices['Alarm Clock Weekdays'] == 'On' and time_inminutes >= alarmclock_inminutes + chambre_matin_start and time_inminutes <= alarmclock_inminutes + chambre_matin_end ) then

            if (chambre_consigne_onoff == 'Off') then
                commandArray['Chauffage Chambre Consigne'] = 'On'
            end

        end


    end




-- Sinon si température dehors > Minimum, on coupe le chauffage
elseif (uservariables['Script_Mode_Maison'] == 'auto' and otherdevices['Chauffage Chambre-Sdb Auto'] == 'On' and dehors_temp > dehors_min) then

    if (sdb_consigne_onoff == 'On') then
        commandArray['Chauffage Sdb Consigne'] = 'Off'
    end 

    if (chambre_consigne_onoff == 'On') then
        commandArray['Chauffage Chambre Consigne'] = 'Off'
    end

end

return commandArray
