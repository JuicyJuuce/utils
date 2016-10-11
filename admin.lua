-- @module admin
-- A 3Ra Gaming creation

-- Handle spectate gui click
-- @param event gui click event
local function gui_click(event)
    local i = event.player_index
    local p = game.players[i]
    local e = event.element.name
    if p.gui.top.spectate ~= nil then
        if e ~= nil then
            if e == "spectate" then
                if not p.admin then
                    p.gui.left.spectate.destroy()
                    p.print("You are no longer an admin.")
                    return
                end
                force_spectators(i)
            end
        end
    end
end

-- Announce an admin's joining and give them the admin gui
-- @param event player joined event
local function admin_joined(event)
    local player = game.players[event.player_index]
    if player.admin then
        if not player.gui.top.spectate then
            local adminframe = player.gui.top.add{name = "spectate", type = "button", direction = "horizontal", caption = "Spectate"}
        end
        game.print("All Hail Admin "..player.name)
    end

end

-- Toggle the player's spectator state
-- @param index index of the player to change
function force_spectators(index)
    local player = game.players[index]
    global.player_spectator_state = global.player_spectator_state or {}
    global.player_spectator_character = global.player_spectator_character or {}
    global.player_spectator_force = global.player_spectator_force or {}
    if global.player_spectator_state[index] then
        --remove spectator mode
        if player.character == nil and global.player_spectator_character[index] then
            local pos = player.position
            if global.player_spectator_character[index].valid then
                player.set_controller{type=defines.controllers.character, character=global.player_spectator_character[index]}
            else
                player.set_controller{type=defines.controllers.character, character=player.surface.create_entity{name="player", position = {0,0}, force = global.player_spectator_force[index]}}
            end
            player.teleport(pos)
		end
        global.player_spectator_state[index] = false
        player.force = game.forces[global.player_spectator_force[index].name]
        player.print("Summoning your character")
        player.gui.top.spectate.caption = "Spectate"
    else
        --put player in spectator mode
        if player.character then
            player.walking_state = {walking = false, direction = defines.direction.north}
            global.player_spectator_character[index] = player.character
            global.player_spectator_force[index] = player.force
    		player.set_controller{type = defines.controllers.god}
        end
        if not game.forces["Spectators"] then game.create_force("Spectators") end
		player.force = game.forces["Spectators"]
        global.player_spectator_state[index] = true
		player.print("You are now a spectator")
        player.gui.top.spectate.caption = "Return"
    end
end

-- Event handlers
Event.register(defines.events.on_player_joined_game, admin_joined)
Event.register(defines.events.on_gui_click, gui_click)
