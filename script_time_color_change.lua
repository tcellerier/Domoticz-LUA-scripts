------------------------------------------------------
-- Script de changement de couleur de la lampe Zipato
------------------------------------------------------

-------------------------------------------------------------
--  Change la couleur de la lampe toutes les X secondes pendant 1 heure
--  Conditions : Device 'Lampe chambre Color Change' = On
--               (une fois activé le device le reste 1h)
-------------------------------------------------------------

package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library")
require("library_credentials")


commandArray = {}



-- On change les couleurs tant que le device est On (pendant 1h par défaut lors de l'activation de la scène)
if (otherdevices['Lampe chambre Color Change'] == 'On') then


    idx = 66  -- identifiant domoticz de la lampe
    brightness = uservariables['Script_Lamp_brightness'] or 70 -- intensité de 1 à 100
    hue = uservariables['Script_Lamp_color_hue'] or 100 -- couleur actuelle (de 0 à 359)
    first_hue = tostring((hue  + 1) % 360)
    frequence = uservariables['Script_Lamp_Freq_Change'] or 1  -- Fréquence de change des couleurs / minute (de 1 à 6)
    server = '127.0.0.1' 
    -- domoticzCredentials dans la library library_credentials


    -- On change les couleurs 'frequence' fois par minute (1ère fois immédiatement)
    for i=0, frequence-1, 1 
    do 
        delay = math.round((60 / frequence) * i) -- delai en seconde du changement
        hue = tostring((hue + 1) % 360) -- nouvelle couleur

        -- Nécessite de soit 1/ ne pas avoir de login/mdp  ou 2/ d'authoriser l'ip 192.168.99.5 dans les paramétres domoticz à ne pas saisir de mot de passe
        -- commandArray['OpenURL'] = 'http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..new_hue..'&brightness='..brightness..'&iswhite=false'

        -- Login / mot de passe à modifier si besoin dans library_credentials.lua
        -- Le retour JSON est actuellement error mais cela marche quand même
        cmd = 'sleep '..delay..' && curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue..'&brightness='..brightness..'&iswhite=false" &'
        os.execute(cmd) 
        -- print('DEBUG // '..cmd)
        
    end

    -- On stocke la dernière valeur de hue
    commandArray['Variable:Script_Lamp_color_hue'] = hue

    print('Lamp color change - hue : de '..first_hue..' à '..hue..', brightness : '..brightness.. '/100')


end

return commandArray
