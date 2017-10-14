-------------------------------------------------------------
-- Script de vérification de mise à jour des devices 
-- Envoie alerte 2 fois par semaine si pas de mise à jour d'un device depuis + de 24h ou si batterie caméra < X %
------------------------------------------------------------ 

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")
require("library_credentials")
JSON = assert(loadfile "/home/pi/domoticz/scripts/lua/JSON.lua")() -- one-time load of the routines

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

camera_device_name = "Camera"
server = '127.0.0.1' 
BatteryThreshold = 30   -- Seuil batterie faible en %
------------------


commandArray = {}


datetime = os.date("*t") -- table is returned containing date & time information
time_inminutes = 60 * datetime.hour + datetime.min




-- Vérification le weekend à 14h
if (time_inminutes == 14*60 and (datetime.wday == 7 or datetime.wday == 1)) then 



    -- Pour chaque device de device_list
    i = 1
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


    -- Vérification de la batterie de la caméra (directement depuis le flux json)
    -- cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=devices&order=name&used=true"'
    -- handle = assert(io.popen(cmd))
    -- devicesJson = handle:read('*all')
    -- handle:close()
    -- devices = JSON:decode(devicesJson)
    -- for j,device in ipairs(devices.result) do
    --    if device.BatteryLevel <= BatteryThreshold and device.Name == camera_device_name then
    --        print('!! Warning !! Batterie faible pour '..device.Name..' : '..device.BatteryLevel..'% (< '..BatteryThreshold..' %)') 
    --        commandArray[i+j] = {['SendNotification'] = 'Batterie faible#Caméra Arlo - Batterie '..device.BatteryLevel..' % #-1' }
    --    end
    -- end


    -- Vérification de la batterie de la caméra à partir du fichier /tmp/arlo_cam1.txt
    handle = io.popen('cat /tmp/arlo_cam1.txt')
    battery = handle:read("*a")
    handle:close()
    battery = tonumber(battery)
    if battery == nil then -- Si pas de données au format numérique ou si pas de données
        battery = 255 
    end
    if battery <= BatteryThreshold then
        print('!! Warning !! Batterie faible pour Caméra Arlo : '..battery..' % (Règle : < '..BatteryThreshold..' %)') 
        commandArray[i] = {['SendNotification'] = 'Batterie faible#Caméra Arlo - Batterie '..battery..' % #-1' }
    end


end

return commandArray
