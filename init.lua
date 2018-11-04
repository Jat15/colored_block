--[[

[Colored_block] 
Mod pour avoir différent type de block de couleurs.

Inspirée 
	
		Speedwall par turbogus
		https://github.com/turbogus/speedwall
		
		Backedclay par TenPlus1
		https://notabug.org/TenPlus1/bakedclay
		
		Colouredbrickstone par Craig Davison
		https://github.com/davisonio/colouredstonebricks
	
	Mod pris en compte
	
		angledwalls
		https://github.com/TumeniNodes/angledwalls
		
		moreblocks
		https://github.com/minetest-mods/moreblocks
		
		letter
		https://github.com/minetest-mods/letters
		
	
	
Codé par Jat sous licence GPL v3 ou superieur
Graphisme par Onyx sous WTFPL


]]--

function Colored_Block_Create(ModName, SubName, NodeLink, BlockDeBase,Variable)
--function Colored_Block_Create(mod, TypeDeBlock, BlockDeBase,Variable)

	--if type(mod) == "string" and type(TypeDeBlock) == "string" then
	--	mod = {mod}
	--	TypeDeBlock = {TypeDeBlock}
	--end

	local Couper = Variable.moreblocks and minetest.global_exists("moreblocks")
	local Letters = Variable.letters and minetest.global_exists("letters")
	local AngledWalls = Variable.angledwalls and minetest.global_exists("angledwalls")
	
	BlockDeBase.groups.ud_param2_colorable = 1
	
	-- Ajoute du groups auquelle il appartien si ce n est pas deja fait
	if not( BlockDeBase["groups"][SubName]== 1) then
		BlockDeBase["groups"][SubName] = 1
	end
	
	if Couper then
		BlockDeBase.palette = "unifieddyes_palette_greys.png"
		BlockDeBase.paramtype2 = "colorfacedir"
		BlockDeBase.airbrush_replacement_node = ModName..":"..SubName.."_grey"
	else
		BlockDeBase.palette = "unifieddyes_palette_extended.png"
		BlockDeBase.paramtype2 = "color"
		BlockDeBase.airbrush_replacement_node = ModName..":"..SubName
	end

	
	if not Couper then
		minetest.register_lbm({
			name = ":"..ModName..":"..SubName.."_".."extended",
			label = "Convert",
			run_at_every_load = true,
			nodenames = NodeLink,
			action = function(pos, node)
				if node.param2 ~= 240 then
					minetest.swap_node(pos, {name = node.name, param2 = 240})
					minetest.get_meta(pos):set_int("palette_index", 240)
				end
			end
		})
	end
		
	for _,Node in pairs(NodeLink) do
		minetest.override_item(Node, {
			paramtype = "light",
			on_construct = unifieddyes.on_construct,
			palette = BlockDeBase.palette,
			paramtype2 = BlockDeBase.paramtype2,
			airbrush_replacement_node = BlockDeBase.airbrush_replacement_node,
			groups = BlockDeBase.groups,
		})
	end
	
	local Colored_Block = table.copy(BlockDeBase)
	Colored_Block.groups.not_in_creative_inventory = 1
	Colored_Block.airbrush_replacement_node = nil
	Colored_Block.description = "Colored block of "..SubName
	Colored_Block.on_construct = unifieddyes.on_construct
	Colored_Block.paramtype = "light"
	
	if not Couper then
		minetest.register_node(":"..ModName..":"..SubName, Colored_Block)
	end
	
	
	for _,Node in pairs(NodeLink) do
		if not Couper then
			unifieddyes.register_color_craft({
				output = ModName..":"..SubName,
				palette = "extended",
				type = "shapeless",
				neutral_node = Node,
				recipe = {
					"NEUTRAL_NODE",
					"MAIN_DYE"
				}
			})
		else
			unifieddyes.register_color_craft({
				output_prefix = ModName..":"..SubName.."_",
				output_suffix = "",
				palette = "split",
				type = "shapeless",
				neutral_node = Node,
				recipe = {
					"NEUTRAL_NODE",
					"MAIN_DYE"
				}
			})		
		end
	end
		
	local Colored_Block_Cut = table.copy(Colored_Block)

	--Retiré le groups	
	Colored_Block_Cut["groups"][SubName] = nil
	
	for _,color in ipairs(unifieddyes.HUES_WITH_GREY) do
		--Création moreblocks
		local Colored_Block_Cut = table.copy(Colored_Block_Cut)
		local Colored_Block = table.copy(Colored_Block)
		
		
		Colored_Block.palette = "unifieddyes_palette_"..color.."s.png"
		Colored_Block_Cut.palette = Colored_Block.palette
		
		if Couper then	
			stairsplus:register_all(ModName, SubName.."_"..color, ModName..":"..SubName.."_"..color, Colored_Block_Cut)	
		end
		if AngledWalls then
			angledwalls.register_angled_wall_and_low_angled_wall_and_corner(
				SubName.."_"..color,
				ModName..":"..SubName.."_"..color,
				SubName.."Angled Wall",
				SubName.."Low Angled Wall",
				SubName.."Corner",
				Colored_Block_Cut
			)
		end
		if Couper or AngledWalls then
			minetest.register_node(":"..ModName..":"..SubName.."_"..color, Colored_Block)
		end
	end
	
	if Couper then		
		for typenode,_ in pairs(stairsplus.defs) do
			for alternate,_ in pairs(stairsplus.defs[typenode]) do	
				for _,Node in pairs(NodeLink) do
					local ModNode, NameNode = Node:match("(.*):(.*)")
					
					if ModNode == "default" then
						ModNode = "moreblocks"
					end
					
					local name = ModNode..":"..typenode.."_"..NameNode..alternate

					if minetest.registered_nodes[name] then
						unifieddyes.register_color_craft({
							output_prefix = ModName..":"..typenode.."_"..SubName.."_",
							output_suffix = alternate,
							palette = "split",
							type = "shapeless",
							neutral_node = name,
							recipe = {
								"NEUTRAL_NODE",
								"MAIN_DYE"
							}
						})	

						minetest.override_item(name, {
							on_construct = unifieddyes.on_construct,
							paramtype2 = "colorfacedir",
							palette = "unifieddyes_palette_greys.png",
							airbrush_replacement_node = ModName..":"..typenode.."_"..SubName.."_grey"..alternate,
							groups = Colored_Block_Cut.groups,
						})
					end
				end
			end
		end
	end
	
	if AngledWalls then
		local prefix_list={
			"angledwalls:angled_wall",
			"angledwalls:low_angled_wall",
			"angledwalls:corner"
		}
		
		local Colored_Block_Angled_Wall_Groups = table.copy(Colored_Block_Cut.groups)
		Colored_Block_Angled_Wall_Groups["not_in_creative_inventory"] = nil
		
		for _,prefix in pairs(prefix_list) do
			for _,Node in pairs(NodeLink) do
				local ModNode, NameNode = Node:match("(.*):(.*)")
				unifieddyes.register_color_craft({
					output_prefix = prefix..SubName.."_",
					output_suffix = "",
					palette = "split",
					type = "shapeless",
					neutral_node = prefix .. NameNode,
					recipe = {
						"NEUTRAL_NODE",
						"MAIN_DYE"
					}
				})	
			
			
				local name = prefix..NameNode
				

				
				minetest.override_item(name, {
					on_construct = unifieddyes.on_construct,
					paramtype2 = "colorfacedir",
					palette = "unifieddyes_palette_greys.png",
					airbrush_replacement_node = prefix..SubName.."_grey",
					groups = Colored_Block_Angled_Wall_Groups,
				})
			end
		end	
	end
	
	if Letters then
		local Table_Letters = {
			{"al", "au", "a", "A"},
			{"bl", "bu", "b", "B"},
			{"cl", "cu", "c", "C"},
			{"dl", "du", "d", "D"},
			{"el", "eu", "e", "E"},
			{"fl", "fu", "f", "F"},
			{"gl", "gu", "g", "G"},
			{"hl", "hu", "h", "H"},
			{"il", "iu", "i", "I"},
			{"jl", "ju", "j", "J"},
			{"kl", "ku", "k", "K"},
			{"ll", "lu", "l", "L"},
			{"ml", "mu", "m", "M"},
			{"nl", "nu", "n", "N"},
			{"ol", "ou", "o", "O"},
			{"pl", "pu", "p", "P"},
			{"ql", "qu", "q", "Q"},
			{"rl", "ru", "r", "R"},
			{"sl", "su", "s", "S"},
			{"tl", "tu", "t", "T"},
			{"ul", "uu", "u", "U"},
			{"vl", "vu", "v", "V"},
			{"wl", "wu", "w", "W"},
			{"xl", "xu", "x", "X"},
			{"yl", "yu", "y", "Y"},
			{"zl", "zu", "z", "Z"},
		}
		
		local Colored_Block_Letters = table.copy(Colored_Block)
		Colored_Block_Letters.paramtype2 = "colorwallmounted"
		Colored_Block_Letters.palette = "unifieddyes_palette_colorwallmounted.png"
		Colored_Block_Letters.groups = {
			not_in_creative_inventory=1,
			not_in_craft_guide=1,
			oddly_breakable_by_hand=1,
			attached_node=1,
			ud_param2_colorable=1
		}

		letters.register_letters(
			ModName, 
			SubName,
			ModName..":"..SubName,
			SubName,
			Colored_Block_Letters.tiles[1],
			Colored_Block_Letters
		)

		for _,row in pairs(Table_Letters) do
			for _,Node in pairs(NodeLink) do	
				unifieddyes.register_color_craft({
					output= ModName..":"..SubName.. "_letter_"..row[1],
					palette = "wallmounted",
					type = "shapeless",
					neutral_node = Node.."_letter_"..row[1],
					recipe = {
						"NEUTRAL_NODE",
						"MAIN_DYE"
					}
				})
				unifieddyes.register_color_craft({
					output= ModName..":"..SubName.. "_letter_"..row[2],
					palette = "wallmounted",
					type = "shapeless",
					neutral_node = Node.."_letter_"..row[2],
					recipe = {
						"NEUTRAL_NODE",
						"MAIN_DYE"
					}
				})
		

				minetest.override_item(Node.."_letter_"..row[1], {
					on_construct = unifieddyes.on_construct,
					paramtype2 = "colorwallmounted",
					palette = "unifieddyes_palette_colorwallmounted.png",
					airbrush_replacement_node = ModName..":"..SubName.. "_letter_"..row[1],
					groups = Colored_Block_Letters.groups,
				})
				minetest.override_item(Node.."_letter_"..row[2], {
					on_construct = unifieddyes.on_construct,
					paramtype2 = "colorwallmounted",
					palette = "unifieddyes_palette_colorwallmounted.png",
					airbrush_replacement_node = ModName..":"..SubName.."_letter_"..row[2],
					groups = Colored_Block_Letters.groups,
				})
			end

		end
	end
end