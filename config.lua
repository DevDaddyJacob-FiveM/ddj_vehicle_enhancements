logger = Logger.new("vehicle-enhancements")

Config = {
    --[[
        Configuration fields for the engine module
    ]]
    Engine = {
        --[[
            Controls if the module is enabled or not
        ]]
        Enabled = true,

        --[[
            By default, GTA will automatically start a vehicle's engine when
            the accelerate input is pressed while it's off.

            When set to true, this is disabled, so the engine must be
            explicitly turned on using the ToggleEngine control.
        ]]
        DisableAutoStart = true,

        --[[
            By default, GTA will automatically turn a vehicle's engine off
            shortly after its driver exits.

            When set to true, the engine is kept running after exiting,
            unless it was already turned off before exiting.
        ]]
        KeepEngineOnExit = true,

        Controls = {
            --[[
                The keybinding used to toggle the vehicle's engine on/off.
                Requires ToggleEngineModifier to be held.
            ]]
            ToggleEngine = {
                Command = "_ddj_engine_toggle",

                --[[
                    See https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/
                ]]
                Mapper = "keyboard",

                --[[
                    The default primary keybinding, set to `""` to not set a default
                ]]
                DefaultPrimary = "G",

                --[[
                    The default secondary keybinding, set to `""` to not set a default
                ]]
                DefaultSecondary = "",
            },

            --[[
                Must be held while pressing ToggleEngine to toggle the engine
            ]]
            ToggleEngineModifier = {
                Command = "_ddj_engine_toggle_modifier",

                --[[
                    See https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/
                ]]
                Mapper = "keyboard",

                --[[
                    The default primary keybinding, set to `""` to not set a default
                ]]
                DefaultPrimary = "LCONTROL",

                --[[
                    The default secondary keybinding, set to `""` to not set a default
                ]]
                DefaultSecondary = "",
            },
        },
    },
    
    --[[
        Configuration fields for the gear shifting module
    ]]
    GearShift = {
        --[[
            Controls if the module is enabled or not
        ]]
        Enabled = true,

        --[[
            When set to true, uses the basic integrated HUD.
            Optionally, you can make your own HUD using the script's exports or
            use a HUD script made by someone else and hook this script into it
            using the exports. (I am not the most UI tallented dev, so maybe one
            day I will take the time to make something nice and ship it with this)
        ]]
        UseIntegratedHUD = true,

        --[[
            Controls if the neutral gear is enabled or not
        ]]
        EnableNeutral = false,

        --[[
            Controls if the reverse is it's own gear or not.
            
            When set to true, the gear layout is:
                - Drive (Forward Only)
                - Neutral (If Appliciable)
                - Reverse
                - Park

            When set to false, the gear layout is:
                - Drive (Forward & Reverse)
                - Neutral (If Appliciable)
                - Park
        ]]
        EnableReverse = true,

        --[[
            Disables automatically entering reverse when holding the brake to stop.

            This does nothing if EnableReverse is enabled.
        ]]
        DisableAutoReverse = true,

        --[[
            When set to true, the engine can only be turned off while the
            vehicle is in park.

            This does nothing if the Engine module is disabled.
        ]]
        RequireParkToTurnOffEngine = false,

        AutoRoll = {
            --[[
                The maximum speed (in m/s) vehicles are allowed to creep up to when
                in drive/reverse without gas pressed.
            ]]
            Speed = 3.33,

            --[[
                How much the auto-roll speed ramps up per tick, so vehicles
                ease into AutoRoll.Speed instead of snapping straight to it.
            ]]
            RampStep = 0.04,
        },

        Controls = {
            --[[
                The keybinding used to change into the next gear down
                (drive -> neutral, neutral -> park, etc)
            ]]
            ChangeGear = {
                Command = "_ddj_gear_change",

                --[[
                    See https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/
                ]]
                Mapper = "keyboard",

                --[[
                    The default primary keybinding, set to `""` to not set a default
                ]]
                DefaultPrimary = "SPACE",

                --[[
                    The default secondary keybinding, set to `""` to not set a default
                ]]
                DefaultSecondary = "",
            },
            
            --[[
                When this key is held and the change gear key is pressed, the gear
                changes up instead of down
                (neutral -> drive, park -> neutral, etc)
            ]]
            ChangeGearModifier = {
                Command = "_ddj_gear_change_modifier",

                --[[
                    See https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/
                ]]
                Mapper = "keyboard",

                --[[
                    The default primary keybinding, set to `""` to not set a default
                ]]
                DefaultPrimary = "LCONTROL",

                --[[
                    The default secondary keybinding, set to `""` to not set a default
                ]]
                DefaultSecondary = "",
            },
        },

        ControllerVibrations = {
            --[[ 
                When set to false all controller vibrations are disabled
            ]]
            Enabled = true,

            --[[
                Controls the vibration from shifting up a gear
            ]]
            ShiftGearUp = {
                --[[
                    Controls if this particular vibration trigger is enabled
                ]]
                Enabled = true,

                --[[
                    The duration in milliseconds that the vibration last for
                ]]
                DurationMs = 75,

                --[[
                    The frequence between 0 and 255 of the vibration
                ]]
                Frequency = 150,
            },

            --[[
                Controls the vibration from shifting down a gear
            ]]
            ShiftGearDown = {
                Enabled = true,
                DurationMs = 75,
                Frequency = 150,
            },

            --[[
                Controls the vibration from trying to shift a gear with no next gear
            ]]
            ShiftGearFail = {
                Enabled = true,
                DurationMs = 200,
                Frequency = 255,
            },
        },
    },
}