-------------------------------------------
--  Bibliothèque des fonctions utiles  ----
-------------------------------------------


-----------------------------
--    Text to Speech       --
-----------------------------
 -- Pré requis 
 -- La clef SSH du compte root du raspberry pi doit être copiée dans le fichier .ssh/authorized_key du compte root du NAS
 -- Le règlage du volume se fait dans l'application Audio Station du NAS Synology

tts_function = function(text_to_speech)

    -- IP du serveur NAS stockée dans une variable 
    nas_ip = uservariables['Var_IP_NAS']
    -- URL de l'API de TTS
    tts_api_url = "http://api.voicerss.org/?key=XXXX&f=44khz_16bit_mono&c=MP3&hl=fr-fr&src="
    -- emplacement du player sur le NAS
    player_path = "/var/packages/AudioStation/target/bin/mplayer"

    -- On execute toutes les commandes en 1 fois sans attendre le retour pour éviter le lag dans Domoticz
    os.execute('ssh root@' .. nas_ip .. ' "wget -q -U Mozilla -O /tmp/domoticz_tts.mp3 \'' .. tts_api_url .. text_to_speech .. '\' && ' .. player_path .. ' /tmp/domoticz_tts.mp3" &')

end


-----------------------------
--    Fonction arrondi     --
-----------------------------
-- formatDecimale est le format du séparteur entier/décimale
-- Ex : formatDecimale = ','
math.round = function(number, precision, formatDecimale)

    precision = precision or 0
    decimal = string.find(tostring(number), ".", nil, true)

    if (decimal) then
        power = 10 ^ precision
        if (number >= 0) then
            number = math.floor(number * power + 0.5) / power
        else
            number = math.ceil(number * power - 0.5) / power
        end

        number = tostring(number)
        cutoff = number:sub(decimal + 1 + precision)
        -- delete everything after the cutoff
        number = number:gsub(cutoff, "")
        number = number:gsub("%.", formatDecimale) -- replace le . par formatDecimale
    end
    return number
end


--------------------------------------------
--           Fonction timedifference      --
--    entre une datetime et maintenant    --
--------------------------------------------
function timedifference(s)
    year = string.sub(s, 1, 4)
    month = string.sub(s, 6, 7)
    day = string.sub(s, 9, 10)
    hour = string.sub(s, 12, 13)
    minutes = string.sub(s, 15, 16)
    seconds = string.sub(s, 18, 19)
    t1 = os.time()
    t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
    difference = os.difftime (t1, t2)
    return difference
end

