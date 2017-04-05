----------------------------------------------------------------------
-- Script de vérification de présence
-- via ping du téléphone et de l'ordinateur

-- Après un ping OK, indique une présence pendant 2 fois 'delay_minutes'
-- A partir de 'delay_minutes', re-execute les pings toutes les minutes jusqu'à OK

-- Présence = 1  => Présence détectée depuis moins de 'delay_minutes' 
-- Présence = -1 => Présence détectée entre 'delay_minutes' et 2 x 'delay_minutes' (en mode 3 uniquement)
-- Présence = 0  => Pas de présence détectée depuis 2 x 'delay_minutes' en mode 3, depuis 'delay_minutes' en mode 2
----------------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")

-----------------
-- Variables  --
-----------------
-- Delay en minutes entre le passage d'un état de détection à un autre (ex : de présent à absent)
-- Valeurs conseillées : 20 en modePresence 3, 15 en modePrésence 2. 
delay_minutes = 15 -- ATTENTION : A mettre à jour également dans dashboard.js

-- Deux modes possibles :
--    3 => ne se base que sur le ping pour détecter une présence. 3 états : a. présent, b. présent mais on essaye de pinger, c. non présent
--    2 => Passe immédiatement d'un état de présence à un état de non présence. Utile avec le script de détection continue d'adresse MAC par exemple (python)
modePresence = '2'
-----------------


commandArray = {}

datetime = os.date("*t") -- table is returned containing date & time information
time_inminutes = 60 * datetime.hour + datetime.min
Script_Presence_Maison = uservariables['Script_Presence_Maison']
Script_Presence_Maison_HasChanged = 0


-- tous les jours entre 10h du matin et minuit (- 1min pour que les autres scripts se déclenchent correctement à 10h pile)
if (time_inminutes >= 10 * 60 - 1) then  


    -- Mode 3 états : on tente de pinger (présence = -1) avant de passer en "non présence"
    if (modePresence == '3') then

        -- Présence = -1 après 'delai_minutes' depuis le dernier ping, on recommence à tenter des pings
        if (Script_Presence_Maison == 1 and timedifference(uservariables_lastupdate['Script_Presence_Maison']) >= delay_minutes * 60) then
            Script_Presence_Maison = -1
            Script_Presence_Maison_HasChanged = 1
        
        -- Presence = 0 si pas de ping à partir de 2 fois 'delay minutes' (1 x 'delay minutes' en presence '=1' + 1 x 'delay minutes' en presence '=-1' )
        elseif (Script_Presence_Maison == -1 and timedifference(uservariables_lastupdate['Script_Presence_Maison']) >= delay_minutes * 60) then
            Script_Presence_Maison = 0
            Script_Presence_Maison_HasChanged = 1
            print('----- Plus de présence détectée : Ping telephone/ordinateur KO depuis ' .. tostring(delay_minutes) .. ' min -----')
        end

    -- Mode 2 états : on passe immédiatement de "présence" à "non présence" (à utiliser avec le script python de détection continue d'adresse MAC)
    elseif (modePresence == '2') then

        -- Présence = 0 après 'delai_minutes' depuis le dernier évènement de présence
        if (Script_Presence_Maison == 1 and timedifference(uservariables_lastupdate['Script_Presence_Maison']) >= delay_minutes * 60) then
            Script_Presence_Maison = 0
            Script_Presence_Maison_HasChanged = 1
            print('----- Plus de présence détectée par adresse MAC depuis ' .. tostring(delay_minutes) .. ' min (script python presence.py) -----')
        end

    
    else -- Si pb dans le choix du mode, on passe en mode "non présent" en permanence
        if (Script_Presence_Maison ~= 0) then
            Script_Presence_Maison = 0
            Script_Presence_Maison_HasChanged = 1
        end
    end


    -- si presence <= 0, on ping à nouveau
    if (Script_Presence_Maison <= 0) then  
        
        ping_success_computer = ""
        ping_success_tel = ""

        -- Ping des ordinateurs en priorité (IP spérarées par un espace dans la variable))
        for Computer_IP_i in string.gmatch(uservariables['Var_IP_Computer_ping'], "%S+") do  -- %S+ matche tout ce qui n'est pas un espace
            ping_computer = os.execute('ping -c1 -W3 '..Computer_IP_i)
            if (ping_computer) then 
                ping_success_computer = Computer_IP_i 
                break
            end
        end

        -- Si échec du ping des ordinateurs, ping des téléphones (IP spérarées par un espace dans la variable)
        if(ping_success_computer == "") then

            for Tel_IP_i in string.gmatch(uservariables['Var_IP_Tel_ping'], "%S+") do  -- %S+ matche tout ce qui n'est pas un espace
                ping_tel = os.execute('ping -c1 -W3 '..Tel_IP_i)
                if (ping_tel) then 
                    ping_success_tel = Tel_IP_i 
                    break
                end
            end
        end 


        if (ping_success_computer ~= "") then
            if (uservariables['Script_Presence_Maison'] == 0) then -- On test par rapport à l'état de présence au début du script
                print('----- Nouvelle présence détectée : Ping Ordinateur ' .. ping_success_computer .. ' OK -----')
            else
                print('----- Présence continue détectée : Ping Ordinateur ' .. ping_success_computer .. ' OK -----')
            end
            Script_Presence_Maison = 1
            Script_Presence_Maison_HasChanged = 1
        
        elseif (ping_success_tel ~= "") then
            if (uservariables['Script_Presence_Maison'] == 0) then -- On test par rapport à l'état de présence au début du script
                print('----- Nouvelle présence détectée : Ping Téléphone ' .. ping_success_tel .. ' OK -----')
            else
                print('----- Présence continue détectée : Ping Téléphone ' .. ping_success_tel .. ' OK -----')
            end
            Script_Presence_Maison = 1
            Script_Presence_Maison_HasChanged = 1
        end

    end



-- Entre minuit et 10h -> on désactive la présence
else
    if (Script_Presence_Maison ~= 0) then
        Script_Presence_Maison = 0
        Script_Presence_Maison_HasChanged = 1
    end
end


-- Si l'état de présence a changé, on l'enregistre dans la variable Domoticz
if(Script_Presence_Maison_HasChanged == 1) then

    commandArray['Variable:Script_Presence_Maison'] = tostring(Script_Presence_Maison)

    -- Si l'état passe de présent à non présent (avant 22h)
    if(Script_Presence_Maison == 0 and uservariables['Script_Presence_Maison'] ~= 0 and datetime.hour < 22) then
        tts_function('Mode absent dans une minute')
    end

end

return commandArray
