local Timeouts = {}

function Timeout(source)
    Timeouts[GetPlayerIdentifier(source, 1)] = os.time() + (Config.invalidPasswordTimeout * 60)
end

function SecondsToClock(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00", "00", "00", "00:00:00"
    else
        hours = string.format("%02.f", math.floor(seconds/3600));
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
        secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
        return hours, mins, secs, hours .. ":" .. mins .. ":" .. secs
    end
end

function TimesToSexy(m,s)
    local r = ""
    if m ~= "00" then
        r = r .. m .. "m"
    end
    if r ~= "" then r = r .. " " end
    r = r .. s .. "s"
    return r
end

function GetSexyTime(seconds)
    local _,m,s = SecondsToClock(seconds)
    return TimesToSexy(m,s)
end

---------------------------------------------------------------------------------------------------------------
AddEventHandler("playerConnecting", function(name, setMessage, deferrals)
    local source = source
    local timeout = Timeouts[GetPlayerIdentifier(source, 1)]
    if timeout then
        if timeout > os.time() then
			local sexytime = GetSexyTime(timeout - os.time())
            deferrals.defer()
            deferrals.update((Locales[Config.Locale]['be_patient_message']):format(sexytime))
            Wait(500)
            deferrals.done((Locales[Config.Locale]['be_patient_message']):format(sexytime))
        end
    end
end)

RegisterServerEvent("nicoo_password:Initialize")
AddEventHandler("nicoo_password:Initialize", function()
    local source = source
    if IsPlayerAceAllowed(source, "Bypass") then
        TriggerClientEvent("nicoo_password:correctPsw", source, true)
    else
        TriggerClientEvent('nicoo_password:showMenu', source)
    end
end)

RegisterServerEvent('nicoo_password:checkPsw')
AddEventHandler('nicoo_password:checkPsw', function(Newpassword, attempts)
    local clPassword = string.lower(Newpassword)
    local s = source

    if clPassword == string.lower(Config.Password) then
        TriggerClientEvent("nicoo_password:correctPsw", s)
    elseif password ~= clPassword then
        if attempts <= 0 then
            Timeout(s)
            DropPlayer(s, Locales[Config.Locale]['kick_message'])
        else
            TriggerClientEvent("nicoo_password:failedPsw", s, clPassword)
        end
    else
        Timeout(s)
        DropPlayer(s, Locales[Config.Locale]['kick_message'])
    end
end)