-------------------------------------------------------------
-- Script de gestion de la consommation EDF en HC et HP
--  avec un device virtuel Smart Meter
------------------------------------------------------------ 

--------  Paramètres  ---------
owl_name = "Compteur EDF"  -- Nom du device Domoticz du compteur EDF (réel)
compteur_virtuel_id = 97   -- ID du compteur (virtuel) Smart Meter HC/HP 
-------------------------------

commandArray = {}

if (devicechanged[owl_name]) then

    datetime = os.date("*t") -- table is returned containing date & time information

    owl_value = otherdevices_svalues[owl_name]
    puissance,conso=owl_value:match("([^;]+);([^;]+)")
    conso = tonumber(conso) 
    conso_hp = tonumber(uservariables['Script_EDF_HP'])
    conso_hc = tonumber(uservariables['Script_EDF_HC'])
    
    -- Gestion du cas de changement de pile / reinitialisation compteur
    if (conso < conso_hp or conso < conso_hc) then
        conso_hp = 0
        conso_hc = 0
    end

    
    -- Heure pleine de 7h à 23h
    if(datetime.hour >= 7 and datetime.hour < 23) then
        HC = conso_hc
        HP = conso - conso_hc
        commandArray['Variable:Script_EDF_HP'] = tostring(HP)

    -- heure creuse
    else
        HC = conso - conso_hp
        HP = conso_hp
        commandArray['Variable:Script_EDF_HC'] = tostring(HC)
    end


    -- Format valeur device Smart Meter : USAGE1;USAGE2;RETURN1;RETURN2;CONS;PRODi
    --   USAGE1= energy usage meter tariff 1
    --   USAGE2= energy usage meter tariff 2
    --   RETURN1= energy return meter tariff 1 
    --   RETURN2= energy return meter tariff 2 
    --   CONS= actual usage power (Watt) 
    --   PROD= actual return power (Watt) 
    
    commandArray['UpdateDevice'] = compteur_virtuel_id .. "|0|" .. tonumber(HC) .. ";" .. tonumber(HP) .. ";0;0;" .. tonumber(puissance) .. ";0"

end

return commandArray
