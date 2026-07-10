local activeLabels = {}
local nextLabelId = 0
local uiReady = false

local function GetResultSuffix(success, chance)
    if success == true then return " ^7(^2Successful:"..tostring(chance).."%^7)"
    elseif success == false then return " ^7(^1Unsuccessful:"..tostring(chance).."%^7)"
    else return "" end
end

local function SendUIConfig()
    SendNUIMessage({
        action = 'configure',
        config = Config.OverheadUI or {}
    })
end

local function SendLabel(label)
    SendNUIMessage({
        action = 'show',
        label = {
            id = label.id,
            playerId = label.serverId,
            text = label.text,
            style = label.style or {}
        }
    })
end

local function AddOverheadLabel(player, serverId, text, overhead)
    if player == -1 or not NetworkIsPlayerActive(player) then return end

    nextLabelId = nextLabelId + 1
    local label = {
        id = ('%s:%s'):format(serverId, nextLabelId),
        serverId = tostring(serverId),
        text = text:gsub('%^%d', ''),
        style = overhead.Style or {},
        maxDistance = tonumber(overhead.ProximityDistance) or 30.0,
        expiresAt = GetGameTimer() + ((tonumber(overhead.VisibleTime) or 5) * 1000)
    }

    activeLabels[label.id] = label
    if uiReady then SendLabel(label) end
end

local function TriggerOutput(Player, source, text, action, fullName, success, chance)
    local command = Config.Commands[action]
    if not command then return print("Invalid command:", action) end

    local fullText = text .. GetResultSuffix(success, chance)

    if command.JobChat and not hasJob(command.Job) then return end

    -- Browser-rendered overhead box
    local overhead = command.Overhead
    if (Config.OverheadUI or {}).Enable ~= false and overhead and overhead.Enable ~= false then
        local overheadText = fullText
        if overhead.ShowPlayerName then
            overheadText = fullName .. ': ' .. overheadText
        end
        AddOverheadLabel(Player, source, overheadText, overhead)
    end

    -- Chat Display
    if command.Chat and command.Chat.Enable then
        local chat_text = fullText
        if command.Chat.ShowPlayerName then
            chat_text = fullName .. ": " .. chat_text
        end
        if command.Chat.ProximityDistance then
            if Player == -1 or not NetworkIsPlayerActive(Player) then return end
            local fromCoords = GetEntityCoords(GetPlayerPed(Player))
            local toCoords = GetEntityCoords(PlayerPedId())
            local maxDistance = tonumber(command.Chat.ProximityDistance) or 30.0
            if Vdist2(fromCoords, toCoords) > (maxDistance * maxDistance) then return end
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

end

local function DistanceScale(distance)
    local options = (Config.OverheadUI or {}).DistanceScaling or {}
    if options.Enable == false then return 1.0 end

    local nearDistance = tonumber(options.NearDistance) or 2.0
    local farDistance = tonumber(options.FarDistance) or 30.0
    local minScale = tonumber(options.MinScale) or 0.7
    local maxScale = tonumber(options.MaxScale) or 1.0
    if farDistance <= nearDistance then return maxScale end

    local progress = math.max(0.0, math.min(1.0, (distance - nearDistance) / (farDistance - nearDistance)))
    return maxScale + ((minScale - maxScale) * progress)
end

CreateThread(function()
    while true do
        local uiConfig = Config.OverheadUI or {}
        local updateInterval = math.max(0, tonumber(uiConfig.UpdateInterval) or 0)
        Wait(next(activeLabels) and updateInterval or 250)

        local now = GetGameTimer()
        local groups = {}

        for id, label in pairs(activeLabels) do
            if now >= label.expiresAt then
                activeLabels[id] = nil
                if uiReady then
                    SendNUIMessage({ action = 'remove', id = id })
                end
            else
                local group = groups[label.serverId]
                if not group then
                    group = { serverId = label.serverId, labels = {} }
                    groups[label.serverId] = group
                end
                group.labels[#group.labels + 1] = label
            end
        end

        if uiReady then
            local positions = {}
            local viewerPed = PlayerPedId()
            local viewerCoords = GetEntityCoords(viewerPed)
            local hideForPause = uiConfig.HideWhilePaused ~= false and IsPauseMenuActive()
            local bone = tonumber(uiConfig.HeadBone) or 31086
            local headOffset = uiConfig.HeadOffset or {}

            for _, group in pairs(groups) do
                local player = GetPlayerFromServerId(tonumber(group.serverId))
                local ped = player ~= -1 and NetworkIsPlayerActive(player) and GetPlayerPed(player) or 0
                local position = {
                    id = group.serverId,
                    visible = false,
                    labels = {}
                }

                local canShowSelf = uiConfig.ShowSelf ~= false or player ~= PlayerId()
                if not hideForPause and canShowSelf and ped ~= 0 and DoesEntityExist(ped) and GetPlayerServerId(player) == tonumber(group.serverId) then
                    local pedCoords = GetEntityCoords(ped)
                    local dx = viewerCoords.x - pedCoords.x
                    local dy = viewerCoords.y - pedCoords.y
                    local dz = viewerCoords.z - pedCoords.z
                    local distance = math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
                    local clearLineOfSight = uiConfig.HideWhenOccluded ~= true
                        or player == PlayerId()
                        or HasEntityClearLosToEntity(viewerPed, ped, 17)

                    local headCoords = GetPedBoneCoords(
                        ped,
                        bone,
                        tonumber(headOffset.X) or 0.0,
                        tonumber(headOffset.Y) or 0.0,
                        tonumber(headOffset.Z) or 0.35
                    )
                    local onScreen, screenX, screenY = World3dToScreen2d(headCoords.x, headCoords.y, headCoords.z)

                    if onScreen and clearLineOfSight then
                        position.x = screenX
                        position.y = screenY
                        position.scale = DistanceScale(distance)

                        for _, label in ipairs(group.labels) do
                            local labelVisible = distance <= label.maxDistance
                            position.labels[#position.labels + 1] = { id = label.id, visible = labelVisible }
                            if labelVisible then position.visible = true end
                        end
                    end
                end

                positions[#positions + 1] = position
            end

            SendNUIMessage({ action = 'positions', players = positions })
        end
    end
end)

RegisterNUICallback('ready', function(_, cb)
    uiReady = true
    SendUIConfig()
    for _, label in pairs(activeLabels) do SendLabel(label) end
    cb('ok')
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    SendNUIMessage({ action = 'reset' })
end)

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
    TriggerOutput(GetPlayerFromServerId(source), source, text, output, fullName, success, chance)
end)
