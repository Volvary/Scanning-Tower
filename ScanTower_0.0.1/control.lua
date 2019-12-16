script.on_init(function()
  global = {

    -- towers[unit_number] = { eei, current_range, signals = {LuaCustomChartTag, unit}, circuit_outputs}
    towers = {},

    TOWER_CONSUMPTION = 300,

    TOWER_MIN_RANGE = 150,

    TOWER_MAX_RANGE = 400,

    TOWER_INCREMENT_SPEED = 2,
    TOWER_DECREMENT_SPEED = 4,
  }
end)

script.on_event({defines.events.on_tick}, function(e)
  if e.tick % 60 == 0 then
    for index,tower in pairs(global.towers) do
      if tower.eei == nil then
        --Remove all signals placed by tower, then delete from global.towers
        --continue
      else
        if tower.eei.energy >= global.TOWER_CONSUMPTION then
          tower.eei.energy = tower.eei.energy - global.TOWER_CONSUMPTION
          tower.current_range = GetTowerRangeIncrement() + tower.current_range
          if tower.current_range > global.TOWER_MAX_RANGE then
            tower.current_range = global.TOWER_MAX_RANGE
          end
          --TODO: Scan
          if tower.eei.surface ~= nil then
            local enemyCountInRange = tower.eei.surface.count_entities_filtered{position = tower.eei.position, radius = tower.current_range , force="enemy"}
            local nonStructureUnits = 0
            if enemyCountInRange > 0 then
              local enemiesInRange = tower.eei.surface.find_entities_filtered{position = tower.eei.position, radius = tower.current_range , force="enemy"}
              local nonStructureUnits = 0
              for index,enemy in pairs(enemiesInRange) do
                if enemy.type == "unit" then
                  nonStructureUnits = nonStructureUnits + 1
                elseif enemy.type == "turret" then
                  local WormSignal = FindExistingTag(tower.signals, enemy)
                  if WormSignal == nil then
                    local signal = tower.eei.force.add_chart_tag(tower.eei.surface, {icon = {type = "virtual", name = "signal-W"}, position = enemy.position})
                    AddTagToEntity(tower, signal, enemy)
                  end
                --else if enemy.type == "unit-spawner" then
                  --TODO: Tag enemy structures
                end
              end
            end
          else
            game.print("Surface invalid")
          end
          tower.eei.get_or_create_control_behavior().output_signal = { type = "virtual", name = "signal-B", count= nonStructureUnits }
        else
          tower.current_range = tower.current_range - global.TOWER_DECREMENT_SPEED
          if tower.current_range < global.TOWER_MIN_RANGE then
            tower.current_range = global.TOWER_MIN_RANGE
          end
            --TODO: Clear any signals out of reach
        end
        --TODO: Clear any invalid signals
      end
    end
  end
end)

script.on_event({defines.events.on_robot_built_entity,defines.events.on_built_entity}, function(event)
  local entity = event.created_entity
  if entity.name == "scan-tower" then
    local position = {entity.position.x,entity.position.y+1}

    global.towers[entity.unit_number] = {eei = entity, current_range = global.TOWER_MIN_RANGE, signals = {}, circuit_outputs = {}}
    --[[local chest = entity.surface.find_entity('entity-ghost', position)
    if chest then
      _,chest = chest.revive()
    else
      chest = entity.surface.create_entity{
        name='botshots-chest',
        position = position,
        force = entity.force
      }
    end
    
    chest.minable=false
    chest.destructible = false

    global.cannons[entity.unit_number] = {
      cannon = entity,
      chest = chest,
    }
    ]]--
    local _signal = entity.force.add_chart_tag(entity.surface, {icon = {type = "virtual", name = "signal-A"}, position = position})
    AddTagToEntity(global.towers[entity.unit_number],_signal)

  end
end)

script.on_event({defines.events.on_robot_mined_entity,defines.events.on_player_mined_entity,defines.events.on_entity_died}, function(event)
  local entity = event.entity
  if entity.name == "scan-tower" then
    local tower = global.towers[entity.unit_number]
    game.print(serpent.block(tower))
    for i,sig in pairs(tower.signals) do
      sig.signal.destroy()
    end
    global.towers[entity.unit_number] = nil
  end
end)

function GetTowerRangeIncrement() 

  --TODO: Calculate using Research + base increase speed.
  return global.TOWER_INCREMENT_SPEED

end

function GetTowerRangeDecrement() 

  --TODO: Calculate using Research + base increase speed.
  return global.TOWER_DECREMENT_SPEED

end

function FindExistingTag(signals, unit)

  for index,signal in pairs(signals) do
    if signal.unit ~= nil and signal.unit == unit then
      return signal
    end
  end
end

function AddTagToEntity(entity, inSignal, inUnit)
  unit = unit or nil

  local _signal = {signal = inSignal, unit = inUnit}
  if entity.signals ~= nil then
    table.insert(entity.signals, _signal)
  else
    entity.signals = {_signal}
  end
end

function AddTowerToNextAvailableTick(tower, currentTick)
  local bFoundTick = false
  local initialTick, nextTickToTest = e.tick % 60

  while bFoundTick == false do
    if global.towers[nextTickToTest] == nil then
      global.towers[nextTickToTest] = tower
      bFoundTick = true
    else 
      nextTickToTest = (nextTickToTest + 1) % 60
      if nextTickToTest == initialTick then
        
      end
    end
  end

end
