function copyPrototype(type, name, newName)
  if not data.raw[type][name] then error("type "..type.." "..name.." doesn't exist") end
  local p = table.deepcopy(data.raw[type][name])
  p.name = newName
  if p.minable and p.minable.result then
    p.minable.result = newName
  end
  if p.place_result then
    p.place_result = newName
  end
  if p.result then
    p.result = newName
  end
  if p.results then
		for _,result in pairs(p.results) do
			if result.name == name then
				result.name = newName
			end
		end
	end
  return p
end

function setScale(array, scaleRatio)
	for i,v in ipairs(array) do
		if v.hr_version ~= nil then
			if v.hr_version.scale ~= nil then
				v.hr_version.scale = v.hr_version.scale * scaleRatio
			else
				v.hr_version.scale = scaleRatio
			end
		end
		
		if v.scale ~= nil then
			v.scale = v.scale * scaleRatio
		else
			v.scale = scaleRatio
		end
	end
end

scan_tower = copyPrototype("accumulator", "accumulator", "scan-tower")

scan_tower.energy_source = {
      type = "electric",
      buffer_capacity = "600KJ",
      usage_priority = "secondary-input",
      input_flow_limit = "450KW",
      output_flow_limit = "0W",
      drain = "6W",
    }

scan_tower_item = copyPrototype("item","accumulator","scan-tower")

--[[scan_tower_EEI = {
  type = "electric-energy-interface",
  energy_source= {
    type = "electric",
    emissions_per_minute = 60,
    usage_priority = "secondary-input",
    buffer_capacity = "600KW",
    input_flow_limit = "330KW/second",
    output_flow_limit = 0
  },
  minable = false,
  name = "scan-tower",
}]]--

--[[howitzer_cannon = copyPrototype("ammo-turret","gun-turret","howitzer-cannon")
howitzer_cannon.attack_parameters.ammo_category = "howitzer-shell"
howitzer_cannon.attack_parameters.min_range = 25
howitzer_cannon.attack_parameters.range = 50
howitzer_cannon.attack_parameters.turn_range = 0.25
howitzer_cannon.attack_parameters.cooldown = 450
howitzer_cannon.turret_base_has_direction = true

howitzer_cannon.projectile_creation_distance = 500

setScale(howitzer_cannon.attacking_animation, 1.5)
setScale(howitzer_cannon.base_picture.layers, 1.5)
setScale(howitzer_cannon.folded_animation.layers, 1.5)
setScale(howitzer_cannon.folding_animation.layers, 1.5)
setScale(howitzer_cannon.prepared_animation.layers, 1.5)
setScale(howitzer_cannon.preparing_animation.layers, 1.5)

howitzer_cannon.collision_box = { {-1.05, -1.05},{1.05, 1.05} }



howitzer_item = copyPrototype("item","gun-turret","howitzer-cannon")
local howitzer_rounds = {
      type = "ammo",
      ammo_type = {
        action = {
          action_delivery = {
            direction_deviation = 0,
            projectile = "howitzer-projectile",
            range_deviation = 0,
            source_effects = {
              entity_name = "artillery-cannon-muzzle-flash",
              type = "create-explosion"
            },
            starting_speed = 1,
            type = "artillery"
          },
          type = "direct"
        },
        category = "howitzer-shell",
        target_type = "position"
      },
      icon = "__base__/graphics/icons/cannon-shell.png",
      icon_size = 32,
      name = "howitzer-shell",
      order = "d[explosive-cannon-shell]-d[artillery]",
      stack_size = 20,
	  stackable = true,
      subgroup = "ammo",
	  min_range = 25,
	  max_range = 40,
    }
	
local howitzer_projectile = {
      action = {
        action_delivery = {
          target_effects = {
            {
              action = {
                action_delivery = {
                  target_effects = {
                    {
                      damage = {
                        amount = 50,
                        type = "physical"
                      },
                      type = "damage"
                    },
                    {
                      damage = {
                        amount = 150,
                        type = "explosion"
                      },
                      type = "damage"
                    }
                  },
                  type = "instant"
                },
                radius = 6,
                type = "area"
              },
              type = "nested-result"
            },
            {
              initial_height = 0,
              max_radius = 3.5,
              offset_deviation = {
                {
                  -4,
                  -4
                },
                {
                  4,
                  4
                }
              },
              repeat_count = 240,
              smoke_name = "artillery-smoke",
              speed_from_center = 0.05,
              speed_from_center_deviation = 0.005,
              type = "create-trivial-smoke"
            },
            {
              entity_name = "big-explosion",
              type = "create-entity"
            }
          },
          type = "instant"
        },
        type = "direct"
      },
      final_action = {
        action_delivery = {
          target_effects = {
            {
              check_buildability = true,
              entity_name = "small-scorchmark",
              type = "create-entity"
            }
          },
          type = "instant"
        },
        type = "direct"
      },
      flags = {
        "not-on-map"
      },
      height_from_ground = 4.375,
      map_color = {
        b = 0,
        g = 1,
        r = 1
      },
      name = "howitzer-projectile",
      picture = {
        filename = "__base__/graphics/entity/artillery-projectile/hr-shell.png",
        height = 64,
        scale = 0.5,
        width = 64
      },
      shadow = {
        filename = "__base__/graphics/entity/artillery-projectile/hr-shell-shadow.png",
        height = 64,
        scale = 0.5,
        width = 64
      },
	  reveal_map = false,
      type = "artillery-projectile"
    }

--Add the Howitzer technology to the requirements of the Artillery, to incentivize players to use it as an intermediate.
local artytechpre = data.raw["technology"]["artillery"].prerequisites
artytechpre[#artytechpre+1] = "howitzer-manufacture"

table.insert(data.raw.technology["physical-projectile-damage-5"].effects,{type = "ammo-damage", ammo_category = "howitzer-shell", modifier = 0.9})
table.insert(data.raw.technology["physical-projectile-damage-6"].effects,{type = "ammo-damage", ammo_category = "howitzer-shell", modifier = 1.3})
table.insert(data.raw.technology["physical-projectile-damage-7"].effects,{type = "ammo-damage", ammo_category = "howitzer-shell", modifier = 1.0})

table.insert(data.raw.technology["weapon-shooting-speed-5"].effects,{type = "gun-speed", ammo_category = "howitzer-shell", modifier = 0.8})
table.insert(data.raw.technology["weapon-shooting-speed-6"].effects,{type = "gun-speed", ammo_category = "howitzer-shell", modifier = 1.5})

local howitzer_technology = {
	type = "technology",
	name = "howitzer-manufacture",
	icon = "__base__/graphics/technology/artillery.png",
	icon_size = 128,
	effects = {
		{
			recipe = "howitzer-turret-recipe",
			type = "unlock-recipe"
		},
		{
			recipe = "howitzer-shell",
			type = "unlock-recipe"
		},
	},
	prerequisites = {
		"military-3",
	},
	unit = {
        count = 300,
        ingredients = {
          {
            "automation-science-pack",
            1
          },
          {
            "logistic-science-pack",
            1
          },
          {
            "military-science-pack",
            1
          },
          {
            "chemical-science-pack",
            1
          }
        },
        time = 60
    },
}
]]--

data:extend({
  {
    type = "recipe",
    name = "scan-tower-recipe",
    enabled = "true",
    ingredients =
    {
      {"radar", 1},
      {"iron-gear-wheel", 15},
      {"steel-plate", 20},
      {"advanced-circuit", 5},
    },
    energy_required = 15,
    result="scan-tower",
  },
  scan_tower,
  scan_tower_item,
  }
)
