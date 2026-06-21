--ts annoying
local utils = {}

--picks a random element from a non-keyed table without modifying the original table; rng:pick has this problem
function utils.choiceNoMod(t)
    return t[rng:randi(1, #t)]
end

function utils.selectFromNormalOrRare(t)
    assert(t and t.normal, "Table must have a 'normal' field and an optional 'rare' field. Also it must not be nil.")
    if t.normal then
        local thing

        --2% chance for rare message
        if t.rare and rng:percent(2) then
            thing = utils.choiceNoMod(t.rare)
            
        else
            thing = utils.choiceNoMod(t.normal)
        end
        return thing
    end
end

--metamethods
function utils:__call()
    return utils.choiceNoMod, utils.selectFromNormalOrRare
end

return setmetatable(utils, utils)