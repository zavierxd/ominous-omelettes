--Remember: behaviors are run before the presence is updated: which means I could make changes to the presence before it's sent off to Discord.
local choiceNoMod, selectFromNormalOrRare = require("mods.OMP (V1).helpers")()

return {
    MainMenuScreen = function(self, original)
        self.presence.state = ""
        self.presence.smallImageKey = ""
        return original
    end,
    LeaderboardScreen = function(self, original, screen)
        local world = screen.worlds[1]

        local function reset()
            --turns messages like "Looking at the leaderboards" into "Looking at the Lvl20 leaderboards"
            local ltI, ltJ = string.lower(original):find(" leaderboard")
            if not ltI or not ltJ then return original end

            local lookupCategories = {
                score20 = "Lvl 20",
                speed = "Speed",
                score = "Score",
                depth = "Depth",
            }

            return original:sub(1, ltI)..lookupCategories[world.sort_by]..original:sub(ltI, string.len(original))
        end
        
        --refreshes presence whenever the leaderboard type changes
        self:connect(world.sort_button, "pressed", function()
            self:updatePresence({
                state = "",
                details = reset()
            })
        end)

        return reset()
    end,
    GameScreen = function(self, original, screen)
        --functions
        local function beautifyNumber(n, sep)
            assert(type(n) == "number", "arg 'n' must be a number")

            n = tostring(n)
            sep = sep or ","
            
            --adds those little commas you see in proper number notation (e.g. 1000 to 1,000 and 129031120 to 129,031,120)
            local groups = {}
            for i = math.floor(string.len(n)/3), 0, -1 do
                local r = n:sub(math.max((string.len(n)+1)-((i+1)*3), 0), math.min(string.len(n)-(i*3), string.len(n)))
                if r ~= "" then table.insert(groups, r) end
                print(i,math.floor(string.len(n)/3),r)
            end

            return (#groups > 1) and table.concat(groups, sep) or n
        end

        local function getHeartString()
            local hp = game_state.hearts
            return string.rep("❤️", hp)..string.rep("🖤", game_state.max_hearts - hp)
        end

        local function updatePresenceWithHearts()
            local heartString = getHeartString()
            self:updatePresence({
                state = string.format(getHeartString().." (%s)", selectFromNormalOrRare(self.messagesForScreen.health[game_state.hearts])),
            })            
        end
        
        local function updatePresenceWithScore()
            self:updatePresence({
                details = string.format("Lvl %d / %s Score", game_state.level, beautifyNumber(game_state.score))
            })
        end

        local function refineString(s)
            --turns strings like "too bad" into "Too Bad" and "hgggggh" into "Hgggggh"
            local words = string.split(s.." ", " ")
            for i, part in ipairs(words) do
                local refinedPart = part:sub(1, 1):upper()..part:sub(2, string.len(part)):lower()
                words[i] = refinedPart --overwrite the og part
            end

            --i gotta write this doesn't work cause ivy realized table.concat is a thing and FORGOT TO RETURN A VALUE i think thats really funny i hope he doesn't take offense tho
            --local out = string.join(words, " ")

            return table.concat(words, " ")
        end
                
        --why tf is this referenced differently? idk ...
        local world = screen.game_layer.world

        --link thingies to the game
            --player heart count changes
        self:connect(game_state, "player_heart_gained", updatePresenceWithHearts)
        self:connect(game_state, "player_heart_lost", updatePresenceWithHearts)
          
            --player gains score
        local oldScore = 0
        local s = self.sequencer
        s:start(function()
            while game_state.elapsed > 0 do
                s:wait_for(function()
                    return oldScore ~= game_state.score
                end)
                oldScore = game_state.score

                --update the
                updatePresenceWithScore()
            end
        end)
        
                --we do abit of hijacking with this one LOL
        local oldState = ""
        local defaultChangeState = world.change_state
        world.change_state = function(...)
            local self, state = ...

            if state == "LevelTransition" then
                updatePresenceWithScore()
            end

            defaultChangeState(...)
            oldState = state
        end
                --This is apparently an oversight cause Ivy forgot to make it work LMFAO so i had to hijack the game as seen above
        --self:connect(world, "level_transition_started", updatePresenceWithBuild)
        
            --player died
        self:connect(world, "player_died", function()
            self:updatePresence({
                state = string.format(string.rep("💔", game_state.max_hearts).." (%s)", selectFromNormalOrRare(self.messagesForScreen.death)),
            })
        end)

            --player just hatched and is deciding on the first room
        self:connect(game_state, "hatched", function()
            self:updatePresence({
                details = selectFromNormalOrRare(self.messagesForScreen)
            })
        end)

            --game restarted
        self:connect(screen, "restart_requested", function()
            self:updatePresence({
                details = selectFromNormalOrRare(self.messagesForScreen.egg)
            })
        end)

            --player got secondary weapon
        self:connect(game_state, "player_secondary_weapon_gained", function(weapon)
            self.presence.smallImageKey = "weapon_"..weapon.key.."_large"
            self.presence.smallImageText = string.format("Main Weapon (%s)", refineString(tr("weapon_"..weapon.key.."_name")))
            self:updatePresence()
        end)

            --player lost secondary weapon?? i don't think this can happen
        self:connect(game_state, "player_secondary_weapon_lost", function(weapon)
            self.presence.smallImageKey = ""
            self:updatePresence()
        end)

            --player beat the game
        self:connect(world, "room_cleared", function()
            print("wow great jonb")
            if game_state.final_room_entered then
                self.presence.state = self.presence.details
                self.presence.details = selectFromNormalOrRare(self.messagesForScreen.win)
                self:updatePresence()
            end
        end)

        --init everything else
            --this will only happen initially
        self.presence.state = string.format(getHeartString().." (%s)", selectFromNormalOrRare(self.messagesForScreen.health[game_state.hearts]))
        self.presence.smallImageKey = ""

        return selectFromNormalOrRare(self.messagesForScreen.egg)
    end,
}