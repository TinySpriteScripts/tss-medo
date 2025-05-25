local QBCore = exports['qb-core']:GetCoreObject()

local function HasJob(src, job)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    return Player.PlayerData.job.name == job
end

local function handleCommand(source, action, args)
    local config = Config.Commands[action]
    if not config then return end

    local text, success, chance, random
    if config.ClearChatForSelf then
        TriggerClientEvent('chat:clear', source)
        return
    end
    if config.ClearChatForAll then
        TriggerClientEvent('chat:clear', -1)
        return
    end

    if config.JobChat then
        if not HasJob(source, config.Job) then
            return
        end
    end



    if config.UseChance then
        chance = tonumber(args[1])
        if not chance or chance < config.ChanceClamps.Min or chance > config.ChanceClamps.Max then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"System", "Invalid chance. Must be between " .. config.ChanceClamps.Min .. "% and " .. config.ChanceClamps.Max .. "%."}
            })
            return
        end

        chance = math.min(math.max(chance, config.ChanceClamps.Min), config.ChanceClamps.Max)
        random = math.random(0, 100)
        success = random <= chance
        text = table.concat(args, " ", 2)

    elseif config.DiceRoll then

        local dice = tonumber(args[1])
        local sides = tonumber(args[2])
        if not dice or not sides then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {"System", "Invalid dice layout. Layout is dice_count, dice_faces"}
            })
            return
        end
        local results = {}
        for i = 1, dice do
            table.insert(results, math.random(1, sides))
        end

        local resultText = table.concat(results, ", ")
        local maxTotal = dice * sides -- This is the max possible roll
        text = "[" .. resultText .. "] Max Total: " .. maxTotal

    else

        text = table.concat(args, " ")

    end

    if config.PlayerAnimation then
        TriggerClientEvent('sayer-medo:PlayerAnimation', source, config.PlayerAnimation)
    end

    if not text then return end

    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local fullName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        TriggerClientEvent('sayer-medo:sendCommandMessage', -1, text, source, action, fullName, success, chance)
    end
end

CreateThread(function()
    for command, v in pairs(Config.Commands) do
        local Permission = false
        if v.Permission then
            Permission = v.Permission
        end
        RegisterCommand(command, function(source, args)
            if source then handleCommand(source, command, args) end
        end, Permission)
    end
end)
