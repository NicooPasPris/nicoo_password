local attempts = Config.MaxAttemps
local passwordPassed = false

function KeyboardInput(textEntry, inputText, maxLength) -- Thanks to Flatracer for the function.
    AddTextEntry('FMMC_KEY_TIP1', textEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", inputText, "", "", "", maxLength)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        return result
    else
        Citizen.Wait(500)
        return nil
    end
end

function ShowNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(0,1)
end

function drawText(text, x, y)
	local resx, resy = GetScreenResolution()
	SetTextFont(0)
	SetTextScale(0.8, 0.8)
	SetTextProportional(true)
	SetTextColour(41, 170, 226, 255)
	SetTextCentre(true)
	SetTextDropshadow(0, 0, 0, 0, 0)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText((float(x) / 1.5) / resx, ((float(y) - 6) / 1.5) / resy)
end

function float(num)
	num = num + 0.00001
	return num
end

-- Menu
local mainMenu
local PswTest = {}

Citizen.CreateThreadNow(function()
    mainMenu = RageUI.CreateMenu(Locales[Config.Locale]['menu_title'], Locales[Config.Locale]['menu_subtitle'], 650, 400)
    mainMenu.Controls.Back.Enabled = false

    while true do
        Citizen.Wait(0)
        if RageUI.Visible(mainMenu) then
            RageUI.DrawContent({}, function()
                RageUI.Button(Locales[Config.Locale]['enter_password_item'], Locales[Config.Locale]['enter_password_item_desc'], { RightLabel = Locales[Config.Locale]['enter_password_item_right'] }, true, function(Hovered, Active, Selected)
                    if Selected then
                        local pI = KeyboardInput(Locales[Config.Locale]['keyboard_input_name'], "", 30)
                        if pI then
                            attempts = attempts - 1
                            TriggerServerEvent("nicoo_password:checkPsw", pI, attempts)
                        end
                    end
                end)

                RageUI.Button(Locales[Config.Locale]['attempts_item'], nil, { RightLabel = Locales[Config.Locale]['attempts_item_right']:gsub('%%s', attempts) }, true, function(Hovered, Active, Selected)
                end)

                if attempts < 3 then
                    RageUI.Button("------------------------------------------------------------------------", description, {}, true, function(Hovered, Active, Selected)
                    end)

                    for i=1, #PswTest, 1 do
                        RageUI.Button(PswTest[i], Locales[Config.Locale]['wrong_password_desc']:gsub('%%s', PswTest[i]), { RightLabel = Locales[Config.Locale]['wrong_password_right'] }, true, function(Hovered, Active, Selected)
                        end)
                    end
                end
            end)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if RageUI.Visible(mainMenu) then
            DisableAllControlActions(0)
        end
    end
end)

---------------------------------------------------------------------------------------------------------------
AddEventHandler('onClientMapStart', function()
    Wait(1000)
    local ped = GetPlayerPed(-1)
    FreezeEntityPosition(ped, true)
    TriggerServerEvent("nicoo_password:Initialize")
end)

RegisterNetEvent('nicoo_password:failedPsw')
AddEventHandler('nicoo_password:failedPsw', function(psw)
    table.insert(PswTest, psw)
end)

RegisterNetEvent('nicoo_password:correctPsw')
AddEventHandler('nicoo_password:correctPsw', function()
    local ped = GetPlayerPed(-1)
    FreezeEntityPosition(ped, false)
    ShowNotification(Locales[Config.Locale]['correct_password'])
    RageUI.Visible(mainMenu, false)
end)

RegisterNetEvent('nicoo_password:showMenu')
AddEventHandler('nicoo_password:showMenu', function(psw)
    RageUI.Visible(mainMenu, true)
end)