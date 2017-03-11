-------------------------------------------------------------
-- Script d'action des scripts de gestion des volets en fonction de
------------------------------------------------------------ 
--   1. Mode Mnauel
--       => Si activé alors Désactive ce script
--   2. Device 'Alarm Clock Weekdays'  
--       => Semaine uniquement :
--        Si On, ouverture volets chambre 20min après heure reveil et ouverture volets sdb pendant 45min après heure reveil
--        Si OFF alors pas d'ouverture des volets chambre ni sdb le matin
--   3. Mode absent
--      => Si activé alors :
--         pas d'ouverture des volets sdb 
--         ouverture volet chambre les matins et weekend
--   4. Si détection ping du téléphone portable le weekend   
--       => Si oui alors on ouvre / laisse ouvert volets sdb
--       => Si non alors on ferme les volets sdb
--   5. Mode volets canicules
--      => Si activé alors
--        Tous les jours, ouverture volets salon 1h30 plus tôt, Fermeture volets salon/chambre 2h plus tard  
--        En semaine, ouverture volets chambre uniquement à  23h + fermeture volets salon de 14h à  17h
--        Si temp dehors < chambre, alors ouvre le volet chambre sinon on le ferme
-------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")

----------------
-- Paramètres --
----------------
volets_salon_on = "On AFTER 1200" -- en secondes après le lever du soleil ou après heure minimum (7h10). 1h30 avant si mode canicule
volets_salon_off = "Off AFTER 1200" -- en secondes après le coucher du soleil. 2h après si canicule

volets_chambre_on_weekdays = "On AFTER 1200" -- en secondes après le reveil en semaine uniquement (variable alarmclock)
volets_chambre_off = "Off RANDOM 10" -- après le coucher du soleil. 2h après si canicule

volets_sdb_on_weekdays = 45 -- Nbre de minutes volets restent ouverts le matin en semaine uniquement (variable alarmclock)

volets_sdb_off = "Off RANDOM 10" -- 1h avant le coucher du soleil 
----------------

commandArray = {}


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


-- Gestion automatique des volets uniquement 
--   si le mode maison n'est pas manuel
--   si le mode volet n'est pas manuel
if (uservariables['Script_Mode_Maison'] ~= 'manuel' and uservariables['Script_Mode_Volets'] ~= 'manuel') then

     -- variables --
    datetime = os.date("*t") -- table is returned containing date & time information
    time_inminutes = 60 * datetime.hour + datetime.min
    _, _, alarm1, alarm2 = string.find(uservariables['Var_Alarmclock'], "(%d+):(%d+)") -- extrait heure / minute de la variable alarmclock
    alarmclock_inminutes = 60 * tonumber(alarm1) + tonumber(alarm2)
    min_time_ouverture = math.max(430, math.min(timeofday['SunriseInMinutes'], 520)) -- ouverture des volets à  minimum 7h10 et à  maximum 8h50
    min_time_fermeture = math.max(1030, timeofday['SunsetInMinutes']) -- fermeture des volets à  minimum 17h10  

    --------------------
    -- Tous les jours --


    --   Si le mode canicule n'est pas activé
    if (uservariables['Script_Mode_Volets'] ~= 'canicule' ) then
    
        -- Ouverture Volets salon le matin
        if (time_inminutes == min_time_ouverture) then
            commandArray['Volets Salon'] = volets_salon_on
            print('----- Ouverture automatique volets salon le matin ----- regle : '..volets_salon_on)
        end

        -- Fermeture Volets salon le soir
        if (time_inminutes == min_time_fermeture + 1) then
            commandArray['Volets Salon'] = volets_salon_off
            print('----- Fermeture automatique volets salon le soir ----- regle : '..volets_salon_off)
        end

        -- Fermeture Volets chambre le soir
        if (time_inminutes == min_time_fermeture) then
            commandArray['Volets Chambre'] = volets_chambre_off
            print('----- Fermeture automatique volets chambre le soir ----- regle : '..volets_chambre_off)
        end

        -- Fermeture Volet sdb le soir 30min avant coucher du soleil s'ils sont encore ouverts
        if (otherdevices['Volets sdb'] == 'Open' and time_inminutes == - 30 + min_time_fermeture) then
            tts_function('Fermeture volets salle de bain dans les 10 minutes')
            commandArray['Volets sdb'] = volets_sdb_off
            print('----- Fermeture automatique volets sdb tous les soirs ----- regle : '..volets_sdb_off)
        end


    --   Si le mode canicule est activé
    elseif (uservariables['Script_Mode_Volets'] == 'canicule') then

        -- Ouverture Volets salon le matin
        if (time_inminutes == min_time_ouverture - 90) then
            commandArray['Volets Salon'] = volets_salon_on
            print('----- Ouverture automatique volets salon le matin ----- regle : Mode Canicule On (-90min) '..volets_salon_on)
        end

        -- Fermeture Volets salon le soir
        if (time_inminutes == min_time_fermeture + 122) then
            commandArray['Volets Salon'] = volets_salon_off
            print('----- Fermeture automatique volets salon le soir ----- regle : Mode Canicule On (+120min) '..volets_salon_off)
        end

        -- Fermeture Volets chambre le soir
        if (time_inminutes == min_time_fermeture + 121) then
            commandArray['Volets Chambre'] = volets_chambre_off
            print('----- Fermeture automatique volets chambre le soir ----- regle : Mode Canicule On (+120min) '..volets_chambre_off)
        end

        -- Fermeture Volet sdb le soir 120min après coucher du soleil s'ils sont encore ouverts
        if (otherdevices['Volets sdb'] == 'Open' and time_inminutes == 120 + min_time_fermeture) then
            tts_function('Fermeture volets salle de bain dans les 10 minutes')
            commandArray['Volets sdb'] = volets_sdb_off
            print('----- Fermeture automatique volets sdb tous les soirs ----- regle : Mode Canicule On '..volets_sdb_off)
        end


        --   Ouverture Volet chambre pour cause de temperature 
        --      si temp extérieure + 1 <= temp chambre et si lumière eteinte
        --      si temperature chambre >= 20 et humidité extérieure < 70
        --      si pas de changement des volets dans la derniere heure
        --      avant 23h et 30 min après réveil si en semaine sinon après 14h
        if (otherdevices['Volets Chambre'] == 'Closed' and otherdevices['Lampe Chambre RGBW'] == 'Off' 
          and otherdevices_temperature['Temp dehors'] + 1 <= otherdevices_temperature['Temp chambre'] 
          and datetime.hour < 23
          and otherdevices_temperature['Temp chambre'] >= 20 and otherdevices_humidity['Temp dehors'] < 70 
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
          and (otherdevices_temperature['Temp dehors'] >= otherdevices_temperature['Temp chambre'] + 0.5
          and timedifference(otherdevices_lastupdate['Volets Chambre']) >= 3600
            or  otherdevices_temperature['Temp chambre'] < 18
            or otherdevices_humidity['Temp dehors'] >= 90)  ) then 
                commandArray['Volets Chambre'] = 'Off'
                print('----- Fermeture automatique volet chambre ----- regle : Mode canicule On et température défavorable')
        end

    end



    -- Ouverture Volet sdb si mode auto activé
    --     lorsqu'il y a une presence (Script_Presence_Maison = 1)
    --     uniquement si heure comprise entre 10h et 1h avant Sunset
    --     uniquement si temperature exterieur > 5Â°
    if (uservariables['Script_Mode_Maison'] == 'auto'  and otherdevices['Volets sdb'] == 'Closed' and uservariables['Script_Presence_Maison'] >= 1
        and timedifference(otherdevices_lastupdate['Volets sdb']) >= 3600  
        and datetime.hour >= 10 and time_inminutes <  min_time_fermeture - 60
        and not (otherdevices_temperature['Temp dehors'] < 5) ) then
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
            and uservariables['Script_Mode_Volets'] ~= 'canicule'  and time_inminutes == alarmclock_inminutes
            and not (otherdevices_temperature['Temp dehors'] < 5) ) then
                commandArray['Volets Chambre'] = volets_chambre_on_weekdays
                print('----- Ouverture automatique volets chambre en semaine ----- regle : '..volets_chambre_on_weekdays)
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
            and not (otherdevices_temperature['Temp dehors'] < 0) ) then
                commandArray['Volets sdb'] = 'On' 
                print('----- Ouverture automatique volets sdb le matin en semaine ----- regle : On at alarmclock')
        end

        -- Fermeture Volet sdb le matin en semaine
        if (otherdevices['Alarm Clock Weekdays'] == 'On' and otherdevices['Volets sdb'] == 'Open' 
           and time_inminutes == alarmclock_inminutes + volets_sdb_on_weekdays
           and uservariables['Script_Presence_Maison'] == 0) then
                tts_function('Fermeture volet salle de bain')
                commandArray['Volets sdb'] = 'Off AFTER 15'
                print('----- Fermeture automatique volets sdb le matin en semaine ----- regle : Off '..volets_sdb_on_weekdays..' min after alarmclock')
        end

    end

    -------------
    -- weekend -- 
    if (datetime.wday == 7 or datetime.wday == 1 or is_jour_ferie == 1) then

        -- Uniquement si mode absent activé => Ouverture Volet chambre weekend à  10h 
        if (uservariables['Script_Mode_Maison'] == 'absent' and time_inminutes == 60*10) then
            commandArray['Volets Chambre'] = volets_chambre_on_weekdays
            print('----- Ouverture automatique volets chambre weekend  ----- regle : à  10h si mode absent activé, '..volets_chambre_on_weekdays)
        end
    end

end

return commandArray
