-------------------------------------------------------------
-- Script de vérification de mise à jour des devices 
-- Envoie alerte une fois par jour si pas de mise à jour d'un device depuis + de 24h 
------------------------------------------------------------ 

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")


------------------
--- Paramètres ---
------------------
-- Liste des devices à contrôler (device_list["Device"] = "Nom_Domoticz_device")
device_list = {}
device_list["Sonde Oregon Dehors"] = "Temp dehors"
device_list["Sonde Oregon Chambre"] = "Temp chambre"
device_list["Sonde Oregon Salle de Bain"] = "Temp sdb"
device_list["Sonde Oregon Salon"] = "Temp salon"
device_list["Compteur electrique OWL CM180"] = "Compteur EDF"


commandArray = {}


datetime = os.date("*t") -- table is returned containing date & time information
time_inminutes = 60 * datetime.hour + datetime.min


-- Vérification le weekend à 14h
if (time_inminutes == 14*60 and (datetime.wday == 7 or datetime.wday == 1)) then

    i = 1 -- Compteur 
    -- Pour chaque device testé
    for key,value in pairs(device_list) do 

        lastupdate_heures = math.floor(timedifference(otherdevices_lastupdate[value]) / 3600)
        lastupdate_minutes = math.floor( (timedifference(otherdevices_lastupdate[value]) % 3600) / 60) 

        -- Si pas de mise à jour du device depuis plus de 24h   
        if (lastupdate_heures > 24) then
    
            print('!! Warning !! Batterie faible pour '..key..' - Pas de données depuis '..lastupdate_heures..' h '..lastupdate_minutes..' min ('..otherdevices_lastupdate[value]..')') 

            -- Notifications subject#body#priority  
            commandArray[i] = {['SendNotification'] = 'Batterie faible#'..key..' - Pas de données depuis '..otherdevices_lastupdate[value]..'#-1' }
            i = i + 1
            
        end

    end

end

return commandArray
