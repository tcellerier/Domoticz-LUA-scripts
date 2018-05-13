-------------------------------------------------------------
-- Script d'action des scripts de gestion du chauffage PID du salon
------------------------------------------------------------ 

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


----------------
-- Paramètres --
----------------
salon_consigne = uservariables['Var_Chauffage_salon_Consigne']
dehors_min = 16
debug = 0 -- Affiche les logs complets
----------------
----------------


commandArray = {}



 -- variables --
datetime = os.date("*t") -- table is returned containing date & time information
time_inminutes = 60 * datetime.hour + datetime.min

salon_onoff = otherdevices['Radiateur Salon On/Off']
dehors_temp = otherdevices_temperature['Temp dehors'] or 10
salon_temp = otherdevices_temperature['Temp salon'] or 18
salon_temp_timediff = timedifference(otherdevices_lastupdate['Temp salon'])

SomErreur_nb_val = 10 -- nb valeurs stockées pour SomErreur (* Ki)



-- Gestion automatique PID du chauffage du salon uniquement
--    si le mode auto est activé 
--    et si le mode Chauffage consigne Salon est activé
--    et si la temperature dehors est supérieure au minmium
if (uservariables['Script_Mode_Maison'] ~= 'absent' and otherdevices['Chauffage Salon Consigne'] == 'On' and dehors_temp <= dehors_min ) then


    -- Cycle d'exécution de 3 min
    if (time_inminutes % 3 == 0) then

        SomErreur_txt = uservariables['Script_Chauffage_SomErreur']
        Kp =  uservariables['Var_Chauffage_salon_Kp']
        Ki =  uservariables['Var_Chauffage_salon_Ki']


        ---  Calcul du proportionnel  ---
        TmpErreur = salon_consigne - salon_temp

        ---  Calcul de l'intégrale  ---
        -- Calcul de la somme des erreurs + Update de la sonde Somme d'erreur
        SomErreur = TmpErreur
        Erreur_tab = {}
        nb_erreur = 1 
        for SomErreur_i in string.gmatch(SomErreur_txt, "%S+") do  -- %S+ matche tout ce qui n'est pas un espace
            if (nb_erreur < SomErreur_nb_val) then  -- On boucle jusqu'à SomErreur_nb_val valeurs
                SomErreur = SomErreur + tonumber(SomErreur_i)
                Erreur_tab[nb_erreur] = tonumber(SomErreur_i)
                nb_erreur = nb_erreur + 1
            end
        end

        -- Mise à jour de l'intégrale (valeur la plus récente à gauche, nb max de valeurs : SomErreur_nb_val)
        SomErreur_txt_new = math.round(TmpErreur, 2, '.')..' ' 
        if (nb_erreur < SomErreur_nb_val) then
            SomErreur_txt_new = SomErreur_txt_new..SomErreur_txt
        else
            for i=1,nb_erreur-1 do 
                SomErreur_txt_new = SomErreur_txt_new..math.round(Erreur_tab[i], 2, '.')..' ' 
            end
        end
        commandArray['Variable:Script_Chauffage_SomErreur'] = SomErreur_txt_new 



        --- Calcul de la dérivée ---
        --  Pas de calcul
        --  L'action dérivative est surtout intéressante pour des systèmes lents ou possédant un grand temps mort


        --- Calcul de la commande de chauffage ---
        CmdChauff = Kp*TmpErreur + Ki*SomErreur 

        -- debug
        if (debug == 1) then
            print('DEBUG PID - Consigne Salon: '..salon_consigne..' , Kp: '..Kp..' , Ki: '..Ki)
            print('DEBUG PID - CmdChauff: '..math.round(CmdChauff, 0, ',')..' %, Erreur : '..math.round(TmpErreur, 2, ',')..' , SomErreur : '..math.round(SomErreur, 2, ','))
            print('DEBUG PID - SomErreur_txt : '..SomErreur_txt_new)    
        end

        -- La commande de chauffage est un nombre entier compris entre 0 et 100 
        if CmdChauff < 10 then   -- Si le cycle est trop court on coupe 
            CmdChauff = 0
        elseif CmdChauff > 90 then -- Si le cycle est trop long, on allume sans coupure
            CmdChauff = 100
        end

        -- Stockage pour affichage dans tablette
        commandArray['Variable:Info_Chauffage_Pourcentage'] = tostring(CmdChauff)

        -- Calcul du temps de cycle en seconde (x1.8 pour des cycles de 3min)
        CycleChauff = math.floor(CmdChauff * 1.8)

        -- Exécution de la commande chauffage
        if (CmdChauff <= 0 and salon_onoff == 'On') then
            commandArray['Radiateur Salon On/Off'] = 'Off'
            print('----- PID - Chauffage Salon OFF (CmdChauff = 0 %) ----- Temp: '..math.round(salon_temp, 2, ','))
        
        elseif (CmdChauff >= 100 and salon_onoff == 'Off' and salon_temp_timediff < 7200) then  -- uniquement si la température a été mise à jour dans les 2 dernières heures
            commandArray['Radiateur Salon On/Off'] = 'On'
            print('----- PID - Chauffage Salon On (CmdChauff = 100 %) ----- Temp: '..math.round(salon_temp, 2, ','))      

        elseif (CmdChauff > 0 and CmdChauff < 100) then  
            if (salon_onoff == 'Off' and salon_temp_timediff < 7200) then -- uniquement si la température a été mise à jour dans les 2 dernières heures
                commandArray[1] = {['Radiateur Salon On/Off'] = 'On'}
            end 
            commandArray[2]= {['Radiateur Salon On/Off'] = 'Off AFTER '..CycleChauff}
            print('----- PID - Chauffage Salon On puis Off après '..CycleChauff..' secondes (CmdChauff = '..math.round(CmdChauff, 0, ',')..' %) ----- Temp: '..math.round(salon_temp, 2, ','))        
        end 

    end



-- Sinon si température dehors > Minimum, on coupe le chauffage
elseif (salon_onoff == 'On' and uservariables['Script_Mode_Maison'] ~= 'absent' and otherdevices['Chauffage Salon Consigne'] == 'On' and dehors_temp > dehors_min) then

    commandArray['Radiateur Salon On/Off'] = 'Off'
    print('----- Chauffage Salon OFF (Temp dehors > minimum) ----- Temp: '..math.round(salon_temp, 2, ','))

end

return commandArray
