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
    if config.RegisterChatChannel then
        if GetResourceState('tss-chat') ~= 'started' then
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                args = { 'System', 'tss-chat is not started, so the channel could not be registered.' }
            })
            return
        end

        local name = tostring(args[1] or '')
        if name == '' then
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                args = { 'System', 'Usage: /register_chat_channel <name> [label] [red] [green] [blue]' }
            })
            return
        end

        local label = tostring(args[2] or name)
        local function colour(value, fallback)
            value = math.floor(tonumber(value) or fallback)
            return math.max(0, math.min(255, value))
        end

        local red = colour(args[3], 50)
        local green = colour(args[4], 220)
        local blue = colour(args[5], 190)
        local ok, registered = pcall(function()
            return exports['tss-chat']:RegisterChannel(name, {
                label = label,
                description = ('Channel registered by tss-medo: %s'):format(label),
                color = { red, green, blue }
            })
        end)

        if not ok or not registered then
            TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                args = { 'System', 'The tss-chat channel could not be registered.' }
            })
            return
        end

        exports['tss-chat']:AddMessage(source, {
            channel = name,
            color = { red, green, blue },
            args = { 'tss-medo', ('Registered the %s chat channel.'):format(label:upper()) }
        })
        return
    end

    if config.JobChat then
        if not hasJob(config.Job, source) then
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
        TriggerClientEvent('tss-medo:PlayerAnimation', source, config.PlayerAnimation)
    end

    if not text then return end

    local Player = getPlayer(source)
    if Player then
        local fullName = Player.firstname .. " " .. Player.lastname
        TriggerClientEvent('tss-medo:sendCommandMessage', -1, text, source, action, fullName, success, chance)
    end
end

local function argumentMetadata(commandConfig)
    local suggestion = commandConfig.Chat and commandConfig.Chat.ChatSuggestion
    local arguments = {}

    for index, argument in ipairs(suggestion and suggestion.CommandArgs or {}) do
        local name = tostring(argument.name or ('arg' .. index))
            :gsub('%%', '')
            :gsub('%s+', '_')
            :gsub('[^%w_%-]', '')
            :lower()
        local argumentType = argument.type or 'string'
        local options = argument.options

        if commandConfig.UseChance and index == 1 then
            name = 'chance'
            argumentType = 'number'
            options = {
                tostring(commandConfig.ChanceClamps.Min),
                tostring(math.floor((commandConfig.ChanceClamps.Min + commandConfig.ChanceClamps.Max) / 2)),
                tostring(commandConfig.ChanceClamps.Max)
            }
        elseif commandConfig.DiceRoll and index == 1 then
            name = 'dice_amount'
            argumentType = 'number'
            options = { '1', '2', '3', '4', '5', '6' }
        elseif commandConfig.DiceRoll and index == 2 then
            name = 'dice_faces'
            argumentType = 'number'
            options = { '4', '6', '8', '10', '12', '20', '100' }
        end

        arguments[#arguments + 1] = {
            name = name ~= '' and name or ('arg' .. index),
            help = argument.help or '',
            type = argumentType,
            optional = argument.optional == true,
            options = options
        }
    end

    return arguments
end

local function commandCategory(commandConfig)
    if commandConfig.RegisterChatChannel then return 'admin' end
    if commandConfig.JobChat then return 'job chat' end
    if commandConfig.ClearChatForSelf or commandConfig.ClearChatForAll then return 'chat' end
    return 'roleplay'
end

local function registerChatMetadata()
    if GetResourceState('tss-chat') == 'started' then
        for command, commandConfig in pairs(Config.Commands) do
            local suggestion = commandConfig.Chat and commandConfig.Chat.ChatSuggestion

            exports['tss-chat']:RegisterCommandMetadata(command, {
                category = commandCategory(commandConfig),
                description = suggestion and suggestion.CommandDescription or ('Run /' .. command),
                permission = commandConfig.Permission or 'user',
                args = argumentMetadata(commandConfig)
            })
        end
    end
end

CreateThread(function()
    for command, v in pairs(Config.Commands) do
        local commandName = command
        local restricted = v.Permission ~= nil and v.Permission ~= false and v.Permission ~= 'user'

        RegisterCommand(commandName, function(source, args)
            if source then handleCommand(source, commandName, args) end
        end, restricted)
    end

    registerChatMetadata()
end)

AddEventHandler('tss-chat:server:ready', registerChatMetadata)
