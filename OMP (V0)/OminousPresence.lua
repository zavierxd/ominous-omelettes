--                dMMMMMMMMMMb 
--             dddMMMMMMMMMMMMMMMmnomMMMnommnomMMnommnomm
--          ddddMMMMooov      qqqMov  mnomMMMMMMMmmmmnommmmnomm
--        MMMMMMoov            qMov                                            MMMMMMMMMMMMMMMmpooov
--      ddMMMMMov             dMov       MMM   dMMMMMPmm    dMMMMMMMPov       MMMMMMoovp   qMMMMMMpoov
--    dMMMMMMov              dMov       MMMMMMMMoovMMMM  MMMMoov  MMMpov     MMMMoov        qMMMMMpoov
--   dMMMMMMov              dMov       MMMMMMoov   MMMMMMMMoov   MMMpov     MMMMoov         dMMMMpoov
--   dMMMMMMov            ddMov       MMMMooo      MMMMMooo     MMMpov     MMMMMoov        dMMMMboov
--   qMMMMMMMov         ddMov        MMMMooo      MMMMMooo     MMMpov     MMMMMMooov    dMMMbbboov
--    qMMMMMMMov    vooddov         MMMMooo      MMMMMooo     MMMpov     MMMMMMMMMMMMMMMMMbboov
--       MMMMMMMdddooov            MMMMoov      MMMMMooo     MMMpov     MMMMMMMoMMooov
--                                                                     MMMMMMoooov
--                                                                    MMMMooov
--                                                                   MMMMooov
--                                                                  MMMMooov
--                                                                 MMMMooov
--                                                                MMMMooov

-----------------------------------------====================================== mods
local _RPC = require("discordRPC")
local stringy = require("lib.stringy")
local DogRescue = require("obj.Spawn.Pickup.Rescue.DogRescue")
local omp = setmetatable({}, {__tostring = function() return "OminousPresence" end, __metatable = [[¯\_(ツ)_/¯]]})
local PickupTable

local mains = Screens.MainScreen
mains:add_sequencer()

-----------------------------------------====================================== changeables
local APP_NAME = "1387171483515621497"
local DEBUG_MODE = false

-----------------------------------------====================================== vars
local _SQ = mains.sequencer
local _S = mains.current_screen
local _P = {
    state = "",
    details = "",
    largeImageText = "",
    largeImageKey = "",
    smallImageKey = "",
    smallImageText = "Most Recent Upgrade",
    _ = {
        menu = "blah blah blah",
        health = "something random lol",
        win = "you can't see this can you...",
        death = "stupid",
    }
}

local texts = {
    wave_clear = {
        "Wave Clear",
        "Wave End",
        "Short Victory",
        "Intermission",
    },

    startup = {
        menu = {
            "Nothin yet",
            "Nothing in particular",
            "Browsing buttons",
            "AFK... or not idk",
            "Nothing",
        },
        normal = {
            "ominous presence is active",
            "discord's running",
            "discord's up",
            "ominous presence is on",
            "you should check dc lol",
            "I CAN TYPE IN UPPERCASE XD",
            "omp's ready",
            "omp's up",
            "ominous online",
        },
        lag = {
            "omp just started, it was a little laggy",
            "ominous presence just started",
            "ominous presence took a bit",
            "ominous presence is finally done",
            "damn it was laggy... but omp's good tho",
        },
        rare = {
            "you gonna be seeing a lotta stars",
            "[unhelpful message]",
            "i love reading",
            "enilno s'pom",
            "i forgot lmao",
            "this should be a turn based game",
            "you should find your evil clone",
            "fear the kebab man",
            "prepare to die",
        }
    },

    health = {        
        death = {
            normal = {
                "Dead",
                "Scrambled",
                "Fried",
                "Boiled",
                "Afterlife",
                "Cooked",
                "Destructified",
                "Heaven..?",
                "Rotten",
            },
            with_twin = {
                "AND your twin?",
                "bro.",
                "Not the twin as well 😭"
            },
            egg = {
                "Powerless.",
                "Futile.",
                "Egg's doing.",
                "Exterminated.",
                "No more."
            }
        },

        twin_death = {
            normal = {
                "SDIYBT",
                "One twin remains.",
                "Twin Death",
                "Twin's Gone",
                "Extra Life",
                "Another Chance",
                "Redemption",
                "Don't screw it up",
            }
        },

        [0] = {
            "Staring at God",
            "One-shot",
            "Uhhhhhh",
            "Plightful",
            "Sickly",
            "Cracked",
        },
        [1] = {
            "Scuffed",
            "Decent",
            "Normal",
            "Fair",
            "Alright",
        },
        [2] = {
            "Chillin",
            "Healthy",
            "Reggsistant",
            "Flawless",
            "Eggcellent",
            "God i should stop with the egg puns",
        }
    },

    error = {
        state = {
            🥴,
            😵,
            🤪,
            🐟,
            😬,
            😧,
            😅
        },
        details = {
            normal = {
                "Oops!",
                "Whoops!",
                "",
                "Uhhhh,",
                "Whoopsie,",
                "Hmmmm,",
                "Oopsie daisy,"
            },
            rare = {
                "SHIT",
                "FUCK",
                "WHYYYYYYYYYYY",
                "GOD DAMN IT"
            }
        }
    }
}

local behaviors = {
    --main menu behaviors
    [Screens.MainMenuScreen] = {
        [Screens.GameScreen] = function(_S)
            omp.showMenuText(true)
        end,
    },
    
    --in-game behaviors
    [Screens.GameScreen] = {
        [Screens.MainMenuScreen] = function(_S)
            if DEBUG_MODE then
                game_state.level = 29
                game_state.hearts = 99
                game_state:upgrade(PickupTable.upgrades.DamageUpgrade)
                for i = 1, 2 do
                    game_state:upgrade(PickupTable.upgrades.NumBulletsUpgrade)
                    game_state:upgrade(PickupTable.upgrades.FireRateUpgrade)
                    game_state:upgrade(PickupTable.upgrades.RangeUpgrade)
                    game_state:upgrade(PickupTable.upgrades.FireRateUpgrade)
                    game_state:upgrade(PickupTable.upgrades.BulletSpeedUpgrade)
                end
            end

            --vars
            local world = omp.getWorld()
            
            --link
            signal.connect(world, "all_spawns_cleared", omp, "omp_track_player_finish_total", function()
                omp.waitForNextRoom(function()
                    --vars
                    local initState = world.state
                    
                    --functions
                    local function spotLoop()
                        initState = world.state
                        omp.waitForNextWaveClear(initState, function()
                            if world.state ~= "RoomClear" then
                                omp.showFightText(world.room, false)
                                spotLoop()
                            else
                                -- print("room end")
                            end
                        end)
                    end
                    
                    spotLoop()
                end)
            end)
            signal.connect(world, "room_cleared", omp, "omp_track_player_room_finish", function()
                omp.showWinText(true)
            end)
            signal.connect(world, "player_died", omp, "omp_track_death", function()
                --vars
                local case = texts.health.death.normal

                --proofread
                if DEBUG_MODE then
                    leaderboard.quit()
                end

                --code
                --check if twin was destroyed and if so, make fun of the player for it
                for k, v in pairs(game_state.artefacts_destroyed) do
                    print(k, v)
                end

                --reroll death message in presence
                _P._.death = rng:choose(unpack(case))

                omp.updatePresence({
                    state = "🥚🥚",
                    details = _P._.death
                })
            end)
            
            signal.connect(game_state, "player_upgraded", omp, "omp_track_upgrades", function(_U)
                omp.updatePresence({
                    smallImageKey = "upgrade_".._U.upgrade_type.."_icon_large",
                    smallImageText = "Most Recent Upgrade"
                })
            end)
            signal.connect(game_state, "player_downgraded", omp, "omp_track_upgrades", function(_U)
                omp.updatePresence({
                    smallImageKey = "upgrade_".._U.upgrade_type.."_icon_large",
                    smallImageText = "Most Recent Downgrade"
                })
            end)
            signal.connect(game_state, "player_heart_gained", omp, "omp_track_health", function()
                omp.showFightText(world.room, true)
            end)
            signal.connect(game_state, "player_heart_lost", omp, "omp_track_health", function()
                omp.showFightText(world.room, true)
            end)
            signal.connect(game_state, "hatched", omp, "omp_track_gamestate", function()
                omp.showGeneralText(true)
                omp.waitForNextRoom(function()
                    --vars
                    local initState = world.state

                    --function
                    local function spotLoop()
                        initState = world.state
                        omp.waitForNextWaveClear(initState, function()
                            if world.state ~= "RoomClear" then
                                omp.showFightText(world.room, false)
                                spotLoop()
                            else
                                --print("room end")
                            end
                        end)
                    end

                    spotLoop()
                end)

                _SQ:start(function()
                    --vars
                    local selectedText = rng:choose(unpack(texts.startup.normal))
                    local selectedPallete = "notif_upgrade_available"

                    --code
                    _SQ:wait(60)
                    _SQ:wait_until_truthy(_RPC, "initialized")

                    if (game_state.elapsed) >= 300 then
                        selectedText = rng:choose(unpack(texts.startup.lag))
                    elseif rng:randi(1, 10) == 1 then
                        selectedPallete = "notif_base"
                        selectedText = rng:choose(unpack(texts.startup.rare))
                    end

                    world:quick_notify(
                        "BTW",
                        selectedPallete,
                        "pickup_ready_notification",
                        1,
                        120,
                        false
                    )
                    world:quick_notify(
                        selectedText:upper(),
                        selectedPallete,
                        "pickup_ready_notification",
                        1,
                        120,
                        false
                    )
                    world:quick_notify(
                        "GOOD LUCK",
                        "notif_heart_up",
                        "level_start",
                        1,
                        200
                    )
                end)
            end)
        end
    }
}

-----------------------------------------====================================== functions
function love.threaderror()
    signal.emit(omp, "error_in_game")

    local _DT = rng:choose(unpack(texts.error.details.normal))

    if rng:percent(10) then
        _DT = rng:choose(unpack(texts.error.details.rare))
    end


    omp.updatePresence({
        state = rng:choose(unpack(texts.error.state)),
        details = _DT
    })
end

local function buildHeartString(heart, emptyHeart)
    --vars
    local emojiString = ""
    local _H = game_state.hearts
    local maxHearts = 2

    --proofread
    if DEBUG_MODE then
        return ""
    end
    heart, emptyHeart = heart or "❤️", emptyHeart or "🖤"

    assert(type(heart) == "string", "Invalid type for arg, 'heart'")
    assert(type(emptyHeart) == "string", "Invalid type for arg, 'emptyHeart'")

    --code
    for i = 1, _H do
        emojiString = emojiString..heart
    end

    for i = 1, maxHearts - _H do
        emojiString = emojiString..emptyHeart
    end

    return emojiString
end

-----------------------------------------====================================== functions (omp)

-----------------------========================== presence updaters
function omp.updatePresence(presence)
    presence = presence or _P

    if DEBUG_MODE then
        local p = presence

        p.state = "Testing something, run not saved"
        p.details = "Level "..tostring(game_state.level)..", "..game_state.hearts.."/2 ❤️"
    end

    for k, v in pairs(_P) do
        if presence[k] == nil then
            presence[k] = _P[k]
        end
    end

    _P = presence --old = new now B)

    _RPC.updatePresence(presence)
end

function omp.showFightText(room, rerollText)
    assert(rerollText ~= nil and type(rerollText) == "boolean", "Error: arg 'rerollText' must be a boolean value")
    if not _S:is(Screens.GameScreen) then return end

    --vars
    local emojiString = buildHeartString()
    local _H = game_state.hearts

    if rerollText and not DEBUG_MODE then
        _P._.health = rng:choose(unpack(texts.health[_H]))
    end

    --code
    omp.updatePresence({
        state = "(".._P._.health..") "..emojiString,
        details = "Wave "..tostring(room.wave)
    })
end

function omp.showMenuText(rerollText)
    assert(rerollText ~= nil and type(rerollText) == "boolean", "Error: arg 'rerollText' must be a boolean value")

    if rerollText then
        _P._.menu = rng:choose(unpack(texts.startup.menu))
    end

    _RPC.updatePresence({
        state = _P._.menu,
        details = "In Menu",
        smallImageKey = "",
        largeImageKey = "",
    })
end

function omp.showGeneralText(rerollText)
    assert(rerollText ~= nil and type(rerollText) == "boolean", "Error: arg 'rerollText' must be a boolean value")
    if not _S:is(Screens.GameScreen) then return end

    --vars
    local _H = game_state.hearts
    local emojiString = buildHeartString()

    if rerollText and not DEBUG_MODE then
        _P._.health = rng:choose(unpack(texts.health[_H]))
    end
    
    --code
    omp.updatePresence({
        state = "(".._P._.health..") "..emojiString,
        details = "Level "..tostring(game_state.level),
        smallImageKey = "",
        --largeImageKey = "I don't know where to fit artefacts rn so here's the build: \n"
    })
end

function omp.showWinText(rerollText)
    assert(rerollText ~= nil and type(rerollText) == "boolean", "Error: arg 'rerollText' must be a boolean value")
    if not _S:is(Screens.GameScreen) then return end

    --vars
    local _H = game_state.hearts
    local emojiString = buildHeartString()

    if rerollText and not DEBUG_MODE then
        _P._.win = rng:choose(unpack(texts.wave_clear))
    end

    --code
    omp.updatePresence({
        state = "(".._P._.win..") "..emojiString,
        details = "Level "..tostring(game_state.level)
    })
end

-----------------------========================== utils

function omp.getWorld()
    return _S.game_layer.world
end

function omp.waitForNextRoom(func)
    --vars
    local world = omp.getWorld()

    --proofread
    func = func or function() end

    --code
    _SQ:start(function()
        _SQ:wait_for(function()
            return world.state == "LevelTransition"
        end)



        func()
    end)
end

function omp.waitForNextWaveClear(startState, func)
    --vars
    local world = omp.getWorld()

    --proofread
    func = func or function() end

    --code
    _SQ:start(function()
        _SQ:wait_for(function()
            if world.state == "RoomClear" then return true end --insta-cancel on room clear since it will run again on the next room 
            return world.state ~= startState
        end)
        _SQ:wait_for(function()
            if world.state == "RoomClear" then return true end --insta-cancel on room clear since it will run again on the next room 
            return world.state == "Spawning"
        end)

        func()
    end)
end

-----------------------========================== loader

function omp.load()
    --init vars
    PickupTable = require("obj.pickup_table")

    --link events
    signal.connect(omp, "screen_changed", omp, "omp_track_screens", function(screen, last)
        print(screen)
        assert(screen ~= nil, "Current screen is nil")

        local screenRelations

        for otherScreen, relationships in pairs(behaviors) do
            if screen:is(otherScreen) then
                screenRelations = relationships
            end
        end

        if screenRelations then
            local relationship

            for otherScreen, func in pairs(screenRelations) do
                if last:is(otherScreen) then
                    relationship = func
                end
            end

            if relationship then
                relationship(screen)
            else
                --print("damn")
            end
        end
    end)
    
    function _RPC.ready(id, name, username, avatar)
        signal.emit(omp, "discord_ready")

        print("----------------------============================= OMP now activated... =============================----------------------")
        omp.updatePresence({
            state = "Nothin yet",
            details = "Menu"
        })
    end

    --main loop :)
    _SQ:start(function()
        _SQ:loop(function()
            local old = mains.current_screen
            _SQ:wait_for(function()
                --lol this is so half-assed I think its genius
                if _RPC then _RPC.runCallbacks() end
                return mains.current_screen ~= _S
            end)

            _S = mains.current_screen
            signal.emit(omp, "screen_changed", _S, old)
        end)
    end)
    
    _RPC.initialize(APP_NAME, true, steam.userId)
end

-----------------------------------------====================================== init
signal.register(omp, "screen_changed")
signal.register(omp, "error_in_game")
signal.register(omp, "error_in_rpc")
signal.register(omp, "discord_ready")
signal.register(omp, "ready")

--enable screen changed link (not b4 waiting for the game to load)
_SQ:start(function()
    _SQ:wait_for(function()
        return global_game ~= nil
    end)

    mains = game:get_main_screen()
    signal.emit(omp, "ready")
    omp.load()
end)

return omp