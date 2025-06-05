local positionIndex = 1

local function GetResultSuffix(success, chance)
    if success == true then return " ^7(^2Successful:"..tostring(chance).."%^7)"
    elseif success == false then return " ^7(^1Unsuccessful:"..tostring(chance).."%^7)"
    else return "" end
end

local function TriggerOutput(Player, text, offset, action, fullName, success, chance)
    local command = Config.Commands[action]
    if not command then return print("Invalid command:", action) end

    local state = { enabled = true }
    local fullText = text .. GetResultSuffix(success, chance)

    if command.JobChat and not hasJob(command.Job) then return end

    positionIndex = positionIndex + 1

    -- 3D Text Thread
    local drawtext_text = fullText
    if command.DrawText and command.DrawText.ShowPlayerName then
        drawtext_text = fullName .. ": " .. drawtext_text
    end
    if command.DrawText then
        CreateThread(function()
            while state.enabled do
                Wait(0)
                local fromCoords = GetEntityCoords(GetPlayerPed(Player))
                local toCoords = GetEntityCoords(PlayerPedId())
                if Vdist2(fromCoords, toCoords) < command.DrawText.ProximityDistance then
                    DrawText3D(fromCoords.x, fromCoords.y, fromCoords.z + offset - 0.1, drawtext_text:gsub("%^%d", ""), action)
                end
            end
            positionIndex = positionIndex - 1
        end)
    end

    -- Chat Display
    if command.Chat and command.Chat.Enable then
        local fromCoords = GetEntityCoords(GetPlayerPed(Player))
        local toCoords = GetEntityCoords(PlayerPedId())
        local chat_text = fullText
        if command.Chat.ShowPlayerName then
            chat_text = fullName .. ": " .. chat_text
        end
        if command.Chat.ProximityDistance and Vdist2(fromCoords, toCoords) > command.Chat.ProximityDistance then
            return
        end
        
        local icon = "fa-solid fa-comments" -- default fallback
        if command.Chat.Icon and command.Chat.Icon ~= "" then
            icon = command.Chat.Icon
        end
        TriggerEvent('chat:addMessage', {
            color = command.Chat.FontColour,
            multiline = true,
            template = string.format([[
                <div class="msg chat-message">
                    <span><i class="%s" style="font-size: 14px; vertical-align: middle; margin-right: 5px;"></i> {0}</span>
                </div>
            ]], icon),
            args = { command.Chat.DisplayText .. " | " .. chat_text }
        })
    end

    -- Timer
    CreateThread(function()
        if command.DrawText then
            Wait(command.DrawText.VisibleTime * 1000)
            state.enabled = false
        end
    end)
end


CreateThread(function()
    for _, cmd in pairs(Config.Commands) do
        if cmd.Chat and cmd.Chat.ChatSuggestion then
            TriggerEvent('chat:addSuggestion',
                cmd.Chat.ChatSuggestion.CommandName,
                cmd.Chat.ChatSuggestion.CommandDescription,
                cmd.Chat.ChatSuggestion.CommandArgs
            )
        end
    end
end)


function DrawText3D(x,y,z, text, action)
    local options = Config.Commands[action].DrawText
    if not options then return end

    local font_colour = options.Font.Colour
    local bg_colour = options.Background.Colour
    local font_style = options.Font.FontID

    local onScreen,_x,_y = World3dToScreen2d(x,y,z)
    local px,py,pz = table.unpack(GetGameplayCamCoord())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = ((1/dist)*2)*(1/GetGameplayCamFov())*120

    if onScreen then

        -- Formalize the text
        SetTextColour(font_colour.r, font_colour.g, font_colour.b, math.floor(font_colour.a * 255))
        SetTextScale(0.0*scale, 0.4*scale)
        SetTextFont(font_style)
        SetTextProportional(1)
        SetTextCentre(true)
        if options.Font.AddShadow then
            SetTextDropshadow(10, 100, 100, 100, 255)
        end

        -- Calculate width and height
        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)
        local height = GetTextScaleHeight(0.45*scale, font_style)
        local width = EndTextCommandGetWidth(font_style)
        -- Diplay the text
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(_x, _y)

        if options.Background.Enable then
            DrawRect(_x, _y+scale/73, width, height, bg_colour.r, bg_colour.g, bg_colour.b , bg_colour.a)
        end

    end
end

RegisterNetEvent('tss-medo:PlayerAnimation',function(anim_data)
    if not anim_data.dict or not anim_data.anim then return end
    local ped = PlayerPedId()
    RequestAnimDict(anim_data.dict)
    while not HasAnimDictLoaded(anim_data.dict) do
        Wait(0)
    end
    TaskPlayAnim(ped, anim_data.dict, anim_data.anim, 8.0, -8.0, 2000, 0, 0, false, false, false)
    RemoveAnimDict(anim_data.dict)
end)


RegisterNetEvent('tss-medo:sendCommandMessage', function(text, source, output, fullName, success, chance)
    local offset = 1 + (positionIndex*0.14)
    TriggerOutput(GetPlayerFromServerId(source), text, offset, output, fullName, success, chance)
end)
