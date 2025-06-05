Config = {
    System = {
        Debug = true,            -- set true to view target/ped areas
        Menu = "ox",            -- "qb", "ox"
        Notify = "ox",            -- "qb", "ox", "esx, "okok", "gta"
        ProgressBar = "ox",     -- "qb", "ox"
    },
    Crafting = { --only here for bridge support
        showItemBox = true,--will only show if your inventory supports it
    },
    Commands = {
        ['me'] = {
            Chat = { --all settings for chat. if you dont want to use chat just set Chat = false
                Enable = true, --whether to add message to chat aswell
                ShowPlayerName = true, --show playername in chat
                Icon = 'fas fa-brain',
                DisplayText = "Action!", --the action text to display in front of message (DOING, TRYING ETC)
                ProximityDistance = 30.0,
                FontColour = { 3, 215, 252, 1.0 }, --font colour in chat (uses slightly different frmat to the other font due to it being html)
                ChatSuggestion = { --purely a visual thing to help when typing commands. remove if dont want
                    CommandName = "/me",
                    CommandDescription = "Think of an action",
                    CommandArgs = { --must be in order
                        {name="Text", help="What youre thinking about"}
                    },
                },
            },
            DrawText = { -- all settings for drawtext option. if you dont want to use drawtext just set DrawText = false
                ProximityDistance = 30.0,
                VisibleTime = 5,
                ShowPlayerName = true,
                Font = {
                    FontID = 4, --the font style. find more here https://docs.fivem.net/natives/?_0x66E0276CC5F6B9DA
                    AddShadow = true, --adds a shadow to the text
                    Colour = { r = 2, g = 215, b = 252, a = 1.0 }, --drawtext font colour
                },
                Background = {
                    Enable = true, --show drawtext background
                    Colour = { r = 35, g = 35, b = 35, a = 0.588 }, --background colour
                },
            },
        },
        ['do'] = {
            Chat = {
                Enable = true,
                ShowPlayerName = true,
                Icon = 'fas fa-hand',
                DisplayText = "Doing!",
                ProximityDistance = 30.0,
                FontColour = { 108, 12, 176, 1.0 },
                ChatSuggestion = {
                    CommandName = "/do",
                    CommandDescription = "Do something",
                    CommandArgs = {
                        {name="Text", help="What youre doing"},
                    },
                },
            },
            DrawText = { 
                ProximityDistance = 30.0,
                VisibleTime = 5,
                ShowPlayerName = true,
                Font = {
                    FontID = 4, 
                    AddShadow = true, 
                    Colour = { r = 108, g = 12, b = 176, a = 1.0 }, 
                },
                Background = {
                    Enable = true, 
                    Colour = { r = 35, g = 35, b = 35, a = 0.588 }, 
                },
            },
        },
        ['try'] = {
            UseChance = true,
            ChanceClamps = {Min = 25, Max = 75},
            Chat = {
                Enable = true,
                ShowPlayerName = true,
                Icon = "fas fa-percent",
                DisplayText = "Trying!",
                ProximityDistance = 30.0,
                FontColour = {43, 237,5,1.0 },
                ChatSuggestion = {
                    CommandName = "/try",
                    CommandDescription = "Try to do something with a chance %",
                    CommandArgs = {
                        {name="%Chance", help="Min:25% / Max:75%"},
                        {name="Text", help="What youre trying"},
                    },
                },
            },
            DrawText = { 
                ProximityDistance = 30.0,
                VisibleTime = 5,
                ShowPlayerName = true,
                Font = {
                    FontID = 4, 
                    AddShadow = true, 
                    Colour = { r = 43, g = 237, b = 5, a = 1.0 },
                },
                Background = {
                    Enable = true, 
                    Colour = { r = 35, g = 35, b = 35, a = 0.588 }, 
                },
            },
        },
        ['roll'] = {
            DiceRoll = true, --makes this command return a number set (EXAMPLE /roll dice_amount dice_faces) /roll 2 6 (this will roll 2 dice each with 6 faces)
            PlayerAnimation = { --plays an animation when command is called
                dict = "anim@mp_player_intcelebrationmale@wank", --closest thing to a dice roll XD
                anim = "wank",
            },
            Chat = {
                Enable = true,
                ShowPlayerName = true,
                Icon = "fas fa-dice",
                DisplayText = "Rolling!",
                ProximityDistance = 30.0,
                FontColour = {235, 182, 7,1.0 },
                ChatSuggestion = {
                    CommandName = "/roll",
                    CommandDescription = "Roll some dice",
                    CommandArgs = {
                        {name="Dice Amount", help="How many dice to use"},
                        {name="Dice Faces", help="How many faces the dice has"},
                    },
                },
            },
            DrawText = { 
                ProximityDistance = 30.0,
                VisibleTime = 5,
                ShowPlayerName = true,
                Font = {
                    FontID = 4, 
                    AddShadow = true, 
                    Colour = { r = 235, g = 182, b = 7, a = 1.0 },
                },
                Background = {
                    Enable = true, 
                    Colour = { r = 35, g = 35, b = 35, a = 0.588 }, 
                },
            },
        },
        -- some helper functions for chat 
        ['clear'] = {
            ClearChatForSelf = true, --clears chat just for yourself
            Chat = {
                ChatSuggestion = {
                    CommandName = "/clear",
                    CommandDescription = "clears chat for yourself",
                    CommandArgs = {},
                },
            },
        },
        ['clearall'] = {
            ClearChatForAll = true, --clears everybodies chat in the server
            Permission = "admin", --if using this variable then player needs this permission to use this command
            Chat = {
                ChatSuggestion = {
                    CommandName = "/clearall",
                    CommandDescription = "clears chat for everybody [Admin]",
                    CommandArgs = {},
                },
            },
        },
        -- some job chat commands (will allow jobs to have a private chat)
        ['ems'] = {
            JobChat = true, -- turns this command into jobchat command
            Job = 'ambulance', --if using JobChat = true then you must specify the job code here
            Chat = {
                Enable = true, 
                ShowPlayerName = true, 
                Icon = 'fas fa-comments',
                DisplayText = "EMS!", 
                ProximityDistance = false,
                FontColour = { 252, 19, 3, 1.0 }, 
                ChatSuggestion = { 
                    CommandName = "/ems",
                    CommandDescription = "EMS global chat",
                    CommandArgs = { 
                        {name="Text", help="What you're saying"}
                    },
                },
            },
            DrawText = false,
        },
        ['pd'] = {
            JobChat = true,
            Job = 'police',
            Chat = {
                Enable = true, 
                ShowPlayerName = true, 
                Icon = 'fas fa-comments',
                DisplayText = "Police!", 
                ProximityDistance = false,
                FontColour = { 6, 23, 184, 1.0 }, 
                ChatSuggestion = { 
                    CommandName = "/pd",
                    CommandDescription = "Police global chat",
                    CommandArgs = { 
                        {name="Text", help="What you're saying"}
                    },
                },
            },
            DrawText = false,
        },
        ['mech'] = {
            JobChat = true,
            Job = 'mechanic',
            Chat = {
                Enable = true, 
                ShowPlayerName = true, 
                Icon = 'fas fa-comments',
                DisplayText = "Mechanic!", 
                ProximityDistance = false,
                FontColour = { 207, 184, 10, 1.0 }, 
                ChatSuggestion = { 
                    CommandName = "/mech",
                    CommandDescription = "Mechanic global chat",
                    CommandArgs = { 
                        {name="Text", help="What you're saying"}
                    },
                },
            },
            DrawText = false,
        },
    }
}