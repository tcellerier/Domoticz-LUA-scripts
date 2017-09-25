-------------------------------------------------------------
-- Script d'action des scripts de gestion des volets en fonction de
------------------------------------------------------------ 
--   1. Mode Mnauel
--       => Si activé alors Désactive ce script
--   2. Mode Auto
--        Ouverture volets salon au lever du soleil / Fermeture au coucher
--   3. Mode Auto Tardif
--        Ouverture volets salon à 9h en semaine et pas d'ouverture le weekend
--   4. Mode absent
--      => Si activé alors :
--         pas d'ouverture des volets sdb 
--         ouverture volet chambre les matins et weekend
--   5. Mode canicule
--      => Si activé alors
--        Tous les jours, ouverture volets salon 1h30 plus tôt, Fermeture volets salon/chambre 2h plus tard  
--        En semaine, ouverture volets chambre uniquement à  23h + fermeture volets salon de 14h à  17h
--        Si temp dehors < chambre, alors ouvre le volet chambre sinon on le ferme
--        Fermeture des volets du salon entre 14h et 17h la semaine
--   6. Device 'Alarm Clock Weekdays'  
--       => Semaine uniquement :
--        Si On, ouverture volets chambre 30min après heure reveil et ouverture volets sdb pendant 45min après heure reveil
--        Si OFF alors pas d'ouverture des volets chambre ni sdb le matin
--   7. Si détection de présence   
--       => On ouvre les volets sdb sinon on les ferme

-------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")

commandArray = {}

----------------
-- Paramètres --
----------------
volets_sdb_on_weekdays = 45 -- Nbre de minutes volets restent ouverts le matin en semaine uniquement (variable alarmclock)
----------------

----- variables ------
datetime = os.date("*t") -- table is returned containing date & time information
time_inminutes = 60 * datetime.hour + datetime.min
_, _, alarm1, alarm2 = string.find(uservariables['Var_Alarmclock'], "(%d+):(%d+)") -- extrait heure / minute de la variable alarmclock
alarmclock_inminutes = 60 * tonumber(alarm1) + tonumber(alarm2)
min_time_ouverture = math.max(450, math.min(timeofday['SunriseInMinutes'], 540)) -- ouverture des volets à  minimum 7h30 et à maximum 9h
min_time_fermeture = math.max(1050, timeofday['SunsetInMinutes']) -- fermeture des volets à minimum 17h30  
temp_dehors = otherdevices_temperature['Temp dehors'] or 10
temp_chambre = otherdevices_temperature['Temp chambre'] or 18
humdite_dehors = otherdevices_humidity['Temp dehors'] or 60
----------------------

-- On détermine si on est un jour ferie
is_jour_ferie = 0
date_jour = os.date("%x")
for jourferie_i in string.gmatch(uservariables['Var_Jours_Feries'], "%S+") do  -- %S+ matche tout ce qui n'est pas un espace
    _, _, jour_ferie_j, jour_ferie_m, jour_ferie_a = string.find(jourferie_i, "(%d+)/(%d+)/(%d+)")
    date_jour_ferie = os.date("%x", os.time{day=jour_ferie_j, month=jour_ferie_m, year='20'..jour_ferie_a})
    if (date_jour_ferie == date_jour) then  -- Si on est dans la journée fériée
        is_jour_ferie = 1
        break -- on sort de la bouche si on sait qu'on est un jour fériée
    end
end




-- Définition des paramètres à afficher sur le dashboard (doit être aligné avec les règles codées ci-après)
if (uservariables['Script_Mode_Volets'] == 'canicule' and uservariables['Script_Mode_Maison'] ~= 'manuel' and uservariables['Script_Mode_Volets'] ~= 'manuel') then
    commandArray['Variable:Info_VoletsSalonOn'] = tostring(min_time_ouverture - 90)
    commandArray['Variable:Info_VoletsSalonOff'] = tostring(min_time_fermeture + 122)
    commandArray['Variable:Info_VoletsChambreOff'] = tostring(min_time_fermeture + 121)
    commandArray['Variable:Info_VoletsSdbOff'] = tostring(min_time_fermeture + 120)
elseif (uservariables['Script_Mode_Maison'] ~= 'manuel' and uservariables['Script_Mode_Volets'] ~= 'manuel') then
    if (uservariables['Script_Mode_VoletsTardifs'] == 'off') then
        commandArray['Variable:Info_VoletsSalonOn'] =  tostring(min_time_ouverture)
    elseif (uservariables['Script_Mode_VoletsTardifs'] == 'on' and datetime.wday ~= 7 and datetime.wday ~= 1 and is_jour_ferie == 0) then
        commandArray['Variable:Info_VoletsSalonOn'] = tostring(9 * 60)
    else
        commandArray['Variable:Info_VoletsSalonOn'] = tostring(-1)
    end
    commandArray['Variable:Info_VoletsSalonOff'] = tostring(min_time_fermeture + 1)
    commandArray['Variable:Info_VoletsChambreOff'] = tostring(min_time_fermeture)
    commandArray['Variable:Info_VoletsSdbOff'] = tostring(min_time_fermeture - 30)
else 
    commandArray['Variable:Info_VoletsSalonOff'] = tostring(-1)
    commandArray['Variable:Info_VoletsChambreOff'] = tostring(-1)
    commandArray['Variable:Info_VoletsSdbOff'] = tostring(-1)
    commandArray['Variable:Info_VoletsSalonOn'] =  tostring(-1)
end
if (otherdevices['Alarm Clock Weekdays'] == 'On' and uservariables['Script_Mode_Maison'] ~= 'manuel' and uservariables['Script_Mode_Volets'] ~= 'manuel') then
    commandArray['Variable:Info_VoletsSdbOffWeekMorning'] = tostring(alarmclock_inminutes + volets_sdb_on_weekdays)
else
    commandArray['Variable:Info_VoletsSdbOffWeekMorning'] = tostring(-1)
end
if (otherdevices['Alarm Clock Weekdays'] == 'On' and uservariables['Script_Mode_Maison'] == 'auto' and alarmclock_inminutes >=  timeofday['SunriseInMinutes'] and temp_dehors >= 0 and uservariables['Script_Mode_Maison'] ~= 'manuel' and uservariables['Script_Mode_Volets'] ~= 'manuel') then
    commandArray['Variable:Info_VoletsSdbOnWeekMorning'] = tostring(alarmclock_inminutes)
else
    commandArray['Variable:Info_VoletsSdbOnWeekMorning'] = tostring(-1)
end
if ((otherdevices['Alarm Clock Weekdays'] == 'On' or uservariables['Script_Mode_Maison'] == 'absent')  and uservariables['Script_Mode_Volets'] ~= 'canicule' and temp_dehors >= 5 and uservariables['Script_Mode_Maison'] ~= 'manuel' and uservariables['Script_Mode_Volets'] ~= 'manuel') then
    commandArray['Variable:Info_VoletsChambreOnWeek'] = tostring(alarmclock_inminutes + 30)
else
    commandArray['Variable:Info_VoletsChambreOnWeek'] = tostring(-1)
end
---------------------------------------------------------------------------------------------------------------





-- Gestion automatique des volets uniquement 
--   si le mode maison n'est pas manuel
--   si le mode volet n'est pas manuel
if (uservariables['Script_Mode_Maison'] ~= 'manuel' and uservariables['Script_Mode_Volets'] ~= 'manuel') then


    --------------------
    -- Tous les jours --


    --   Si le mode canicule n'est pas activé
    if (uservariables['Script_Mode_Volets'] ~= 'canicule' ) then
    
        -- Ouverture Volets salon 
        --   a. Si Mode_VoletsTardifs = Off, tous les jours le matin au lever du soleil + 20 min
        --   b. Si Mode_VoletsTardifs = On, à 9h en semaine uniquement
        if (uservariables['Script_Mode_VoletsTardifs'] == 'off' and time_inminutes == min_time_ouverture 
            or uservariables['Script_Mode_VoletsTardifs'] == 'on' and time_inminutes == 540 and datetime.wday ~= 7 and datetime.wday ~= 1 and is_jour_ferie == 0) then
            commandArray['Volets Salon'] = "On"
            print('----- Ouverture automatique volets salon le matin -----')
        end

        -- Fermeture Volets salon le soir
        if (time_inminutes == min_time_fermeture + 1) then
            commandArray['Volets Salon'] = "Off"
            print('----- Fermeture automatique volets salon le soir -----')
        end

        -- Fermeture Volets chambre le soir
        if (time_inminutes == min_time_fermeture) then
            commandArray['Volets Chambre'] = "Off RANDOM 10"
            print('----- Fermeture automatique volets chambre le soir ----- regle : Off RANDOM 10')
        end

        -- Fermeture Volet sdb le soir 30min avant coucher du soleil s'ils sont encore ouverts
        if (otherdevices['Volets sdb'] == 'Open' and time_inminutes == - 30 + min_time_fermeture) then
            tts_function('Fermeture volets salle de bain dans les 10 minutes')
            commandArray['Volets sdb'] = "Off RANDOM 10"
            print('----- Fermeture automatique volets sdb tous les soirs ----- regle : Off RANDOM 10')
        end


    --   Si le mode canicule est activé
    elseif (uservariables['Script_Mode_Volets'] == 'canicule') then

        -- Ouverture Volets salon le matin
        if (time_inminutes == min_time_ouverture - 90) then
            commandArray['Volets Salon'] = "On"
            print('----- Ouverture automatique volets salon le matin ----- regle : Mode Canicule On (-90min) ')
        end

        -- Fermeture Volets salon le soir
        if (time_inminutes == min_time_fermeture + 122) then
            commandArray['Volets Salon'] = "Off"
            print('----- Fermeture automatique volets salon le soir ----- regle : Mode Canicule On (+120min) ')
        end

        -- Fermeture Volets chambre le soir
        if (time_inminutes == min_time_fermeture + 121) then
            commandArray['Volets Chambre'] = "Off RANDOM 10"
            print('----- Fermeture automatique volets chambre le soir ----- regle : Mode Canicule On (+120min), Off RANDOM 10')
        end

        -- Fermeture Volet sdb le soir 120min après coucher du soleil s'ils sont encore ouverts
        if (otherdevices['Volets sdb'] == 'Open' and time_inminutes == 120 + min_time_fermeture) then
            tts_function('Fermeture volets salle de bain dans les 10 minutes')
            commandArray['Volets sdb'] = "Off RANDOM 10"
            print('----- Fermeture automatique volets sdb tous les soirs ----- regle : Mode Canicule On, Off RANDOM 10')
        end


        --   Ouverture Volet chambre pour cause de temperature 
        --      si temp extérieure + 1 <= temp chambre et si lumière eteinte
        --      si temperature chambre >= 20 et humidité extérieure < 70
        --      si pas de changement des volets dans la derniere heure
        --      avant 23h et 30 min après réveil si en semaine sinon après 14h
        if (otherdevices['Volets Chambre'] == 'Closed' and otherdevices['Lampe Chambre RGBW'] == 'Off' 
          and temp_dehors + 1 <= temp_chambre 
          and datetime.hour < 23
          and temp_chambre >= 20 and humdite_dehors < 70 
          and timedifference(otherdevices_lastupdate['Volets Chambre']) >= 3600  
          and ( otherdevices['Alarm Clock Weekdays'] == 'On' and time_inminutes >= alarmclock_inminutes + 45 and datetime.wday ~= 7 and datetime.wday ~= 1 and is_jour_ferie == 0
               or (datetime.wday == 7 or datetime.wday == 1 or is_jour_ferie == 1 or otherdevices['Alarm Clock Weekdays'] == 'Off') and datetime.hour >= 14) ) then
                commandArray['Volets Chambre'] = 'On'
                print('----- Ouverture automatique volet chambre ----- regle : Mode canicule On et température favorable')
        end

        --   Fermeture Volet chambre pour cause de temperature
        --      si temp extérieure >= temp chambre + 1 et si lumière eteinte 
        --      si pas de changement des volets dans la derniere heure  
        --  ou si temp chambre < 18 ou si humidité extérieure >= 90
        if (otherdevices['Volets Chambre'] == 'Open' and otherdevices['Lampe Chambre RGBW'] == 'Off' 
          and (temp_dehors >= temp_chambre + 0.5
          and timedifference(otherdevices_lastupdate['Volets Chambre']) >= 3600
            or temp_chambre < 18
            or humdite_dehors >= 90)  ) then 
                commandArray['Volets Chambre'] = 'Off'
                print('----- Fermeture automatique volet chambre ----- regle : Mode canicule On et température défavorable')
        end

    end



    -- Ouverture Volet sdb si mode auto activé
    --     lorsqu'il y a une presence (Script_Presence_Maison = 1)
    --     uniquement si heure comprise entre 10h et 1h avant Sunset
    --     uniquement si temperature exterieur > 5°C
    if (uservariables['Script_Mode_Maison'] == 'auto'  and otherdevices['Volets sdb'] == 'Closed' and uservariables['Script_Presence_Maison'] >= 1
        and timedifference(otherdevices_lastupdate['Volets sdb']) >= 3600  
        and datetime.hour >= 10 and time_inminutes <  min_time_fermeture - 60
        and temp_dehors >= 5 ) then
        tts_function('Ouverture volets salle de bain')
        commandArray['Volets sdb'] = 'On AFTER 3'
        print('----- Ouverture automatique volets sdb la journée ----- regle : Présence détectée')
    end

    -- Fermeture Volet sdb si pas de présence (variable Script_Presence_Maison = 0)
    if (otherdevices['Volets sdb'] == 'Open' and uservariables['Script_Presence_Maison'] == 0
        and datetime.hour >= 10) then
        tts_function('Fermeture volets salle de bain')
        commandArray['Volets sdb'] = 'Off AFTER 15'
        print('----- Fermeture automatique volets sdb la journée ----- regle : Pas de présence détectée')
    end




    -------------
    -- semaine --
    if (datetime.wday ~= 7 and datetime.wday ~= 1 and is_jour_ferie == 0) then

        -- Ouverture Volet chambre en semaine
        --    Si alarmclock activée ou si mode absent activé
        --    et si mode canicule désactivé
        --    et si températeur extérieure > 5° 
        if ((otherdevices['Alarm Clock Weekdays'] == 'On' or uservariables['Script_Mode_Maison'] == 'absent') 
            and uservariables['Script_Mode_Volets'] ~= 'canicule'  and time_inminutes == alarmclock_inminutes + 30
            and temp_dehors >= 5 ) then
                commandArray['Volets Chambre'] = "On"
                print('----- Ouverture automatique volets chambre en semaine -----')
        end


        -- Mode canicule Salon - Fermeture / Ouverture Volets Salon l'après-midi
        if (uservariables['Script_Mode_Volets'] == 'canicule' ) then

            -- Fermeture Volets salon à  14h
            if (time_inminutes == 14*60) then
                commandArray['Volets Salon'] = 'Off RANDOM 10'
                print('----- Fermeture automatique volets salon en semaine ----- regle : Mode Canicule On à  14h')
            end

            -- Ouverture Volets salon à  17h
            if (time_inminutes == 17*60) then
                commandArray['Volets Salon'] = 'On RANDOM 10'
                print('----- Ouverture automatique volets salon en semaine ----- regle : Mode Canicule On à  17h')
            end
        end


    
        -- Ouverture Volet sdb le matin en semaine
        --    uniquement si mode Domoticz auto
        --    uniquement si le reveil est après le lever du soleil
        --    uniquement si temperature exterieure >= 0° 
        if (otherdevices['Alarm Clock Weekdays'] == 'On' and uservariables['Script_Mode_Maison'] == 'auto'
            and alarmclock_inminutes >=  timeofday['SunriseInMinutes'] and time_inminutes == alarmclock_inminutes
            and temp_dehors >= 0 ) then
                commandArray['Volets sdb'] = 'On' 
                print('----- Ouverture automatique volets sdb le matin en semaine ----- regle : On at alarmclock')
        end

        -- Fermeture Volet sdb le matin en semaine
        if (otherdevices['Alarm Clock Weekdays'] == 'On' and otherdevices['Volets sdb'] == 'Open' 
           and time_inminutes == alarmclock_inminutes + volets_sdb_on_weekdays
           and uservariables['Script_Presence_Maison'] == 0) then
                tts_function('Fermeture volet salle de bain')
                commandArray['Volets sdb'] = 'Off AFTER 5'
                print('----- Fermeture automatique volets sdb le matin en semaine ----- regle : Off '..volets_sdb_on_weekdays..' min after alarmclock')
        end

    end

    -------------
    -- weekend -- 
    if (datetime.wday == 7 or datetime.wday == 1 or is_jour_ferie == 1) then

        -- Uniquement si mode absent activé => Ouverture Volet chambre weekend à  10h 
        if (uservariables['Script_Mode_Maison'] == 'absent' and time_inminutes == 60*10) then
            commandArray['Volets Chambre'] = "On"
            print('----- Ouverture automatique volets chambre weekend  ----- regle : à  10h si mode absent activé')
        end
    end

end

return commandArray
