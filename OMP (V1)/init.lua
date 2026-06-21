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
--      by bmanseventeenkay (zavierxd)                            MMMMooov1 :)

local _screen = nil
local errored = false --kinda useless variable tbh

--other packaged deps
local repo = "mods.OMP (V1)"
local rpc = require(repo..".discordRPC")
local choiceNoMod, selectFromNormalOrRare = require(repo..".helpers")()
local messages = require(repo..".texts")
local behaviors = require(repo..".behaviors")

local omp = Object:extend("OminousPresence")

omp.sequencer = nil
omp.discordUser = nil
omp.messagesForScreen = {}
omp.rpcModule = rpc
omp.presence = { --the format for a discord presence. some of these may be nil and will therefore be erased from the table, but you can add them back.
    state = nil,
    details = nil,
    startTimestamp = nil,
    endTimestamp = nil,
    largeImageKey = nil,
    largeImageText = nil,
    smallImageKey = nil,
    smallImageText = nil,
    partyId = nil,
    partyMax = nil,
    matchSecret = nil,
    joinSecret = nil,
    spectateSecret = nil,
}

--default mod callbacks
function omp:new()
    self.sequencer = Sequencer()
end

function omp:on_load()
    rpc.initialize("1387171483515621497", true, tostring(steam.user.get_steam_id()))

    --link discord rpc callbacks
    function rpc.ready(id, name, discriminator, avatar)
        self.discordUser = {
            username = name,
            userId = id,
            avatarId = avatar
        }
        if self.onLoaded then
            --just incase any mods depend on this one
            self:onLoaded(id, name, discriminator, avatarId)
        end
        print("\n\n\n\n\n\n\n\n\n\n")
        print("Ominous Presence active...")
        print("\n\n\n\n\n\n\n\n\n\n")

        --show state of the current screen (should be pre-title screen or else something is terribly wrong)
        self:on_screen_changed(Screens.PreTitleScreen)
    end

    function rpc.errored(id, message)
        error(string.format("Discord had an oopsie: %s (Error code %s)", message, tostring(id)))
    end

    function rpc.disconnected(id, message)
        print(string.format("Discord has disconnected: %s (Error code %s)", message, tostring(id)))
    end
end

function omp:on_game_loaded()
    --love functions of goofy ass hijacking since mods are loaded before the game is apparently
    local defaultError = love.errorhandler
    function love.errorhandler(msg)
        if not errored then
            self:updatePresence({
                details = "Ooops LOL",
                state = "The game crashed..."
            })
            errored = true
        end
        
        return defaultError(msg)
    end

    local defaultQuit = love.quit
    function love.quit()
        defaultQuit()
        rpc.clearPresence()
        rpc.shutdown()
        print("die")
        return false
    end
end

--the meat of the whole mod xd
function omp:on_screen_changed(screen)
    if not self.discordUser then return end

    --remove all connections to omp: we don't need them anymore since the previous screen is gone + they'll be reestablished next time
    signal.cleanup(self)

    _screen = screen
    local name = tostring(screen)
    self.messagesForScreen = messages[name]

    if messages[name] and messages[name].normal then
        local message = selectFromNormalOrRare(messages[name])

        if behaviors and behaviors[name] then
            message = behaviors[name](self, message, screen)
        end

        self:updatePresence({
            details = message
        })
    end
end

function omp:update(dt)
    if self.sequencer then
        self.sequencer:update(dt)
    end
    rpc.runCallbacks()
end

--self-made mod callbacks
function omp:onLoaded(id, name, discriminator, avatarId)

end

--self-made mod functions
function omp:updatePresence(presence)
    if not self.discordUser then return end
    presence = presence or self.presence

     for k, v in pairs(self.presence) do
        if presence[k] == nil and k:find("Timestamp") == nil then
            presence[k] = v
        end
    end

    print("\nPresence should read:")
    print(presence.details or "")
    print(presence.state or "")
    print("If it doesn't the API's a bum\n")

    self.presence = presence
    rpc.updatePresence(self.presence)
end

function omp:inventListenerId(signalId)
    return "omp_track_"..signalId
end

function omp:connect(object, signalId, func)
    signal.connect(object, signalId, omp, self:inventListenerId(signalId), func)
end

function omp:disconnect(object, signalId)
    signal.disconnect(object, signalId, omp, self:inventListenerId(signalId))
end

--[[
function omp:connectToScreen(screen, signalId, func)
    self:connect(screen, signalId, func)
end

function omp:disconnectFromScreen(screen, signalId)
    self:disconnect(screen, signalId)
end

function omp:connectToCurrentScreen(signalId, func)
    self:connectToScreen(_screen, signalId, func)
end
]]

return omp