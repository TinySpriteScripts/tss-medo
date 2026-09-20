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
    OverheadUI = {
        Enable = true,
        ShowSelf = true,           -- show your own command boxes above your character
        UpdateInterval = 0,       -- 0 updates every frame; 16 is roughly 60 FPS
        HeadBone = 31086,         -- SKEL_Head
        HeadOffset = { X = 0.0, Y = 0.0, Z = 0.35 },
        AnchorOffset = { X = 0, Y = -28 }, -- final screen-space offset in pixels; more negative moves boxes higher
        StackGap = 6,             -- gap between boxes from the same player
        HideWhenOccluded = true,
        HideWhilePaused = true,
        TransitionDuration = 80,  -- box fade duration in milliseconds
        DistanceScaling = {
            Enable = true,
            NearDistance = 2.0,
            FarDistance = 30.0,
            MinScale = 0.72,
            MaxScale = 1.0,
        },
        -- These defaults can be overridden in any command's Overhead.Style table.
        DefaultStyle = {
            BackgroundColour = 'rgba(35, 35, 35, 0.88)',
            TextColour = '#ffffff',
            BorderColour = 'rgba(255, 255, 255, 0.25)',
            BorderWidth = 1,
            BorderStyle = 'solid',
            BorderRadius = 5,
            FontFamily = 'Arial, sans-serif',
            FontSize = 16,
            FontWeight = 600,
            LineHeight = 1.25,
            LetterSpacing = 0,
            Padding = '7px 10px',
            MinWidth = 0,
            MaxWidth = 360,
            TextAlign = 'center',
            BoxShadow = '0 3px 12px rgba(0, 0, 0, 0.35)',
            TextShadow = '0 1px 2px rgba(0, 0, 0, 0.7)',
            Opacity = 1.0,
        },
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
            Overhead = { -- browser-rendered box; set Overhead = false to disable it
                Enable = true,
                ProximityDistance = 30.0,
                VisibleTime = 5,
                ShowPlayerName = true,
                Style = {
                    TextColour = 'rgb(2, 215, 252)',
                    BorderColour = 'rgba(2, 215, 252, 0.7)',
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
            Overhead = {
                Enable = true,
                ProximityDistance = 30.0,
                VisibleTime = 5,
                ShowPlayerName = true,
                Style = {
                    TextColour = 'rgb(173, 97, 224)',
                    BorderColour = 'rgba(173, 97, 224, 0.7)',
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
            Overhead = {
                Enable = true,
                ProximityDistance = 30.0,
                VisibleTime = 5,
                ShowPlayerName = true,
                Style = {
                    TextColour = 'rgb(43, 237, 5)',
                    BorderColour = 'rgba(43, 237, 5, 0.7)',
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
            Overhead = {
                Enable = true,
                ProximityDistance = 30.0,
                VisibleTime = 5,
                ShowPlayerName = true,
                Style = {
                    TextColour = 'rgb(235, 182, 7)',
                    BorderColour = 'rgba(235, 182, 7, 0.7)',
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
            Overhead = false,
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
            Overhead = false,
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
            Overhead = false,
        },
    }
}
