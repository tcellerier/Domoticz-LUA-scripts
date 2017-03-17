-------------------------------------------------------------
-- Script de gestion de la telecommande RF
------------------------------------------------------------ 

-- A parametrer dans chaque device : Off Delay: 1 second !!!!


package.path = package.path .. ';' .. '/home/pi/domoticz/scripts/lua/?.lua' 
require("library_credentials")


idx = 66        -- identifiant domoticz de la lampe
server = '127.0.0.1' 
brightness = tonumber(uservariables['Script_Lamp_brightness'])   -- intensité de 1 à 100
hue = tonumber(uservariables['Script_Lamp_color_hue'])    -- couleur (de 0 à 359)
iswhite = uservariables['Script_Lamp_iswhite']    -- couleur blanche ou pas (true / false)
frequence = tonumber(uservariables['Script_Lamp_Freq_Change'])  -- Fréquence de change des couleurs / min
-- domoticzCredentials dans la library library_credentials


commandArray = {}


if (devicechanged['Telecommande On/Off'] == 'On') then
    print('----- Telecommande On/Off -----')
    if (otherdevices['Lampe Chambre RGBW'] == 'On' or otherdevices['Lampe Chambre RGBW'] == 'Set Level') then
        -- On arrête le script de changement des couleurs s'il était démarré
        commandArray['Lampe chambre Color Change'] = 'Off' 
        cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
        os.execute(cmd)
        commandArray['Lampe Chambre RGBW'] = 'Off'
    else
        commandArray['Lampe Chambre RGBW'] = 'On'
    end

elseif (devicechanged['Telecommande Demo'] == 'On') then
    print('----- Telecommande Demo -----')
    if (otherdevices['Lampe chambre Color Change'] == 'Off') then
        commandArray['Variable:Script_Lamp_iswhite'] = 'false'
        commandArray['Lampe chambre Color Change'] = 'On'
    else
        commandArray['Lampe chambre Color Change'] = 'Off'
        -- Stoppe tous les changements de couleur prévus dans la minute
        cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
        os.execute(cmd)
    end

elseif (devicechanged['Telecommande Blanc'] == 'On') then
    print('----- Telecommande Blanc -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'true'
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue..'&brightness='..brightness..'&iswhite=true" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Rouge'] == 'On') then
    print('----- Telecommande Rouge -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'false'
    hue_rouge = '0'
    commandArray['Variable:Script_Lamp_color_hue'] = hue_rouge
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue_rouge..'&brightness='..brightness..'&iswhite=false" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Vert'] == 'On') then
    print('----- Telecommande Vert -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'false'
    hue_vert = '120'
    commandArray['Variable:Script_Lamp_color_hue'] = hue_vert
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue_vert..'&brightness='..brightness..'&iswhite=false" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Bleu'] == 'On') then
    print('----- Telecommande Bleu -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'false'
    hue_bleu = '240'
    commandArray['Variable:Script_Lamp_color_hue'] = hue_bleu
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue_bleu..'&brightness='..brightness..'&iswhite=false" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Jaune'] == 'On') then
    print('----- Telecommande Jaune -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'false'
    hue_jaune = '60'
    commandArray['Variable:Script_Lamp_color_hue'] = hue_jaune
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue_jaune..'&brightness='..brightness..'&iswhite=false" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Cyan'] == 'On') then
    print('----- Telecommande Cyan -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'false'
    hue_cyan = '180'
    commandArray['Variable:Script_Lamp_color_hue'] = hue_cyan
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue_cyan..'&brightness='..brightness..'&iswhite=false" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Violet'] == 'On') then
    print('----- Telecommande Violet -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'false'
    hue_violet = '300'
    commandArray['Variable:Script_Lamp_color_hue'] = hue_violet
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue_violet..'&brightness='..brightness..'&iswhite=false" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

-- Virtual device (pour l'interface tablette)
elseif (devicechanged['Telecommande Rose'] == 'On') then
    print('----- Telecommande Rose (virutal device) -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'false'
    hue_rose = '330'
    commandArray['Variable:Script_Lamp_color_hue'] = hue_rose
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue_rose..'&brightness='..brightness..'&iswhite=false" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Color-'] == 'On') then
    print('----- Telecommande Color- -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'false'
    hue_new = tostring((hue - 10) % 360)
    commandArray['Variable:Script_Lamp_color_hue'] = hue_new
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue_new..'&brightness='..brightness..'&iswhite=false" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Color+'] == 'On') then
    print('----- Telecommande Color+  -----')
    commandArray['Variable:Script_Lamp_iswhite'] = 'false'
    hue_new = tostring((hue + 10) % 360)
    commandArray['Variable:Script_Lamp_color_hue'] = hue_new
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue_new..'&brightness='..brightness..'&iswhite=false" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Bright-'] == 'On') then
    print('----- Telecommande Bright-  -----')
    if (brightness < 25) then
        brightness_new = tostring(math.max(1, brightness - 5))
    else
        brightness_new = tostring(math.max(1, brightness - 15))
    end
    commandArray['Variable:Script_Lamp_brightness'] = brightness_new
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue..'&brightness='..brightness_new..'&iswhite='..iswhite..'" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Bright+'] == 'On') then
    print('----- Telecommande Bright+ -----')
    if (brightness < 15) then
        brightness_new = tostring(math.min(100, brightness + 5))
    else
        brightness_new = tostring(math.min(100, brightness + 15))
    end
    commandArray['Variable:Script_Lamp_brightness'] = brightness_new
    cmd = 'curl --user '..domoticzCredentials..' "http://'..server..'/json.htm?type=command&param=setcolbrightnessvalue&idx='..idx..'&hue='..hue..'&brightness='..brightness_new..'&iswhite='..iswhite..'" &'
    os.execute(cmd)
    -- On arrête tous les changements éventuels (Demo On) alors décorélés et prévus dans la minute en cours (puis reprise la minute suivante)
    cmd = "for i in `ps axww | grep '^.*sleep.*curl.*setcolbrightnessvalue.*$' | awk '{ print $1 }'`; do kill -9 $i; done"
    os.execute(cmd)

elseif (devicechanged['Telecommande Speed-'] == 'On') then
    print('----- Telecommande Speed- -----')
    frequence_new = tostring(math.max(1, (frequence - 1)))
    commandArray['Variable:Script_Lamp_Freq_Change'] = frequence_new

elseif (devicechanged['Telecommande Speed+'] == 'On') then
    print('----- Telecommande Speed+ -----')
    frequence_new = tostring(math.min(6, (frequence + 1)))
    commandArray['Variable:Script_Lamp_Freq_Change'] = frequence_new

elseif (devicechanged['Telecommande Mode-'] == 'On') then
    print('----- Telecommande Mode- -----')
    commandArray['Volets Chambre'] = 'Off'

elseif (devicechanged['Telecommande Mode+'] == 'On') then
    print('----- Telecommande Mode+ -----')
    commandArray['Volets Chambre'] = 'On'

end


return commandArray
