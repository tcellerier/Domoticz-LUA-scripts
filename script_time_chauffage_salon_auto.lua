------------------------------------------------------------------
-- Script d'action des scripts d'activation du chauffage du salon
--   en fonction d'une presence
------------------------------------------------------------------


commandArray = {}

-- Si le mode Auto est activé
if(otherdevices['Chauffage Salon Auto'] == 'On' and uservariables['Script_Mode_Maison'] == 'auto') then

    -- S'il y a une présence
    if(uservariables['Script_Presence_Maison'] >= 1 or uservariables['Script_Presence_Maison'] == -1) then

        if(otherdevices['Chauffage Salon Consigne'] == 'Off') then
            commandArray['Chauffage Salon Consigne'] = 'On'
        end
    else
        if(otherdevices['Chauffage Salon Consigne'] == 'On') then
            commandArray['Chauffage Salon Consigne'] = 'Off'
        end
    end

end

-- Si on coupe le mode Auto, le chauffage consigne salon est coupé via le script script_device_chauffage.lua

return commandArray

