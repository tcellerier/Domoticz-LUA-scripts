-------------------------------------------------------------
-- Script de gestion technique des volets

-- Règles - ouvre ou ferme un volet si : 
--   1. le volet n'est pas déjà dans cet état (ouvert ou fermé)
--   2. Ou dans tous les cas si la demande se fait 2 fois en moins d'une minute 
------------------------------------------------------------ 

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")

----------------
-- Paramètres --
----------------
-- Difference max en secondes entre 2 demandes d'ouverture/fermeture pour que l'action soit forcée 
force_diff_sec = 60
----------------

commandArray = {}


-- Ouverture des 2 volets salon
if (devicechanged['Volets Salon'] == 'Open') then
    commandArray['Volets Salon Gauche'] = 'On'
    commandArray['Volets Salon Droit'] = 'On AFTER 10'

-- Fermeture des 2 volets salon
elseif (devicechanged['Volets Salon'] == 'Closed') then
    commandArray['Volets Salon Gauche'] = 'Off'
    commandArray['Volets Salon Droit'] = 'Off AFTER 10'
end


-- Ouverture volet Salon Gauche
if (devicechanged['Volets Salon Gauche'] == 'Open') then
    if (uservariables['Script_Volets_salon_gauche'] == 'closed' or timedifference(uservariables_lastupdate['Script_Volets_salon_gauche']) < force_diff_sec) then
        commandArray['GPIO 18 jaune'] = 'Off'   
    end
    commandArray['Variable:Script_Volets_salon_gauche'] = 'open'

-- Fermeture volet Salon Gauche
elseif (devicechanged['Volets Salon Gauche'] == 'Closed') then 
    if (uservariables['Script_Volets_salon_gauche'] == 'open' or timedifference(uservariables_lastupdate['Script_Volets_salon_gauche']) < force_diff_sec) then
        commandArray['GPIO 27 vert'] = 'Off'
    end
    commandArray['Variable:Script_Volets_salon_gauche'] = 'closed'
end


-- Ouverture volet Salon Droit 
if (devicechanged['Volets Salon Droit'] == 'Open') then 
    if (uservariables['Script_Volets_salon_droit'] == 'closed' or timedifference(uservariables_lastupdate['Script_Volets_salon_droit']) < force_diff_sec) then
        commandArray['GPIO 22 violet'] = 'Off'
    end
        commandArray['Variable:Script_Volets_salon_droit'] = 'open'

-- Fermeture volet Salon Droit 
elseif (devicechanged['Volets Salon Droit'] == 'Closed') then 
    if(uservariables['Script_Volets_salon_droit'] == 'open' or timedifference(uservariables_lastupdate['Script_Volets_salon_droit']) < force_diff_sec) then
        commandArray['GPIO 23 bleu'] = 'Off'
    end        
    commandArray['Variable:Script_Volets_salon_droit'] = 'closed'
end


-- Ouverture volet Chambre 
if (devicechanged['Volets Chambre'] == 'Open') then 
    if(uservariables['Script_Volets_chambre'] == 'closed' or timedifference(uservariables_lastupdate['Script_Volets_chambre']) < force_diff_sec) then
        commandArray['GPIO 25 blanc'] = 'Off'
    end
    commandArray['Variable:Script_Volets_chambre'] = 'open'

-- Fermeture volet Chambre 
elseif (devicechanged['Volets Chambre'] == 'Closed') then 
    if (uservariables['Script_Volets_chambre'] == 'open' or timedifference(uservariables_lastupdate['Script_Volets_chambre']) < force_diff_sec) then
        commandArray['GPIO 24 gris'] = 'Off'
    end
    commandArray['Variable:Script_Volets_chambre'] = 'closed'
end


-- Ouverture volet sdb  (On active le mode présence en parallèle)
if (devicechanged['Volets sdb'] == 'Open') then 
    if (uservariables['Script_Volets_sdb'] == 'closed' or timedifference(uservariables_lastupdate['Script_Volets_sdb']) < force_diff_sec) then
        commandArray['GPIO 17 orange'] = 'Off'
    end
    commandArray['Variable:Script_Volets_sdb'] = 'open'

-- Fermeture volet sdb 
elseif (devicechanged['Volets sdb'] == 'Closed') then 
    if (uservariables['Script_Volets_sdb'] == 'open' or timedifference(uservariables_lastupdate['Script_Volets_sdb']) < force_diff_sec) then
        commandArray['GPIO 4 rouge'] = 'Off'
    end
    commandArray['Variable:Script_Volets_sdb'] = 'closed'
end

return commandArray
