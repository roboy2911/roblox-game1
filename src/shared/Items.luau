-- Every item that can show up in the game, plus rarity and condition rules.
-- Shared so both the server and players' screens know names, rarities and colors.
-- The TRUE value of a specific item is rolled on the server and kept secret from players.

local Config = require(script.Parent.Config)

local Items = {}

-- Rarities, from most to least common. Weight = how often customers bring one in.
Items.Rarities = {
	Junk = { Order = 1, Weight = 30, Color = Color3.fromRGB(150, 150, 150) },
	Common = { Order = 2, Weight = 35, Color = Color3.fromRGB(255, 255, 255) },
	Uncommon = { Order = 3, Weight = 20, Color = Color3.fromRGB(90, 220, 110) },
	Rare = { Order = 4, Weight = 10, Color = Color3.fromRGB(70, 150, 255) },
	Epic = { Order = 5, Weight = 4, Color = Color3.fromRGB(190, 90, 255) },
	Legendary = { Order = 6, Weight = 1, Color = Color3.fromRGB(255, 185, 40) },
}

-- Condition multiplies the item's value.
Items.Conditions = {
	{ Name = "Broken", Weight = 10, Multiplier = 0.3 },
	{ Name = "Worn", Weight = 35, Multiplier = 0.7 },
	{ Name = "Good", Weight = 40, Multiplier = 1.0 },
	{ Name = "Mint", Weight = 15, Multiplier = 1.5 },
}

-- Id = internal name (also used to build its 3D model), Min/Max = base value range in $.
Items.List = {
	-- Junk
	{ Id = "RubberDuck", Name = "Rubber Duck", Rarity = "Junk", Min = 2, Max = 8 },
	{ Id = "OldBoot", Name = "Old Boot", Rarity = "Junk", Min = 3, Max = 10 },
	{ Id = "TinCan", Name = "Tin Can", Rarity = "Junk", Min = 1, Max = 6 },
	-- Common
	{ Id = "Toaster", Name = "Toaster", Rarity = "Common", Min = 15, Max = 40 },
	{ Id = "DeskLamp", Name = "Desk Lamp", Rarity = "Common", Min = 15, Max = 35 },
	{ Id = "TeddyBear", Name = "Teddy Bear", Rarity = "Common", Min = 10, Max = 30 },
	{ Id = "Skateboard", Name = "Skateboard", Rarity = "Common", Min = 25, Max = 60 },
	{ Id = "OldRadio", Name = "Old Radio", Rarity = "Common", Min = 20, Max = 55 },
	-- Uncommon
	{ Id = "Camera", Name = "Film Camera", Rarity = "Uncommon", Min = 60, Max = 180 },
	{ Id = "Trumpet", Name = "Trumpet", Rarity = "Uncommon", Min = 80, Max = 220 },
	{ Id = "AcousticGuitar", Name = "Acoustic Guitar", Rarity = "Uncommon", Min = 90, Max = 250 },
	{ Id = "GameConsole", Name = "Game Console", Rarity = "Uncommon", Min = 70, Max = 200 },
	-- Rare
	{ Id = "GoldWatch", Name = "Gold Watch", Rarity = "Rare", Min = 300, Max = 900 },
	{ Id = "ElectricGuitar", Name = "Electric Guitar", Rarity = "Rare", Min = 250, Max = 800 },
	{ Id = "Katana", Name = "Katana", Rarity = "Rare", Min = 400, Max = 1000 },
	{ Id = "Painting", Name = "Mystery Painting", Rarity = "Rare", Min = 250, Max = 1000 },
	-- Epic
	{ Id = "DiamondRing", Name = "Diamond Ring", Rarity = "Epic", Min = 1500, Max = 5000 },
	{ Id = "GoldTrophy", Name = "Golden Trophy", Rarity = "Epic", Min = 1000, Max = 3500 },
	{ Id = "AntiqueVase", Name = "Antique Vase", Rarity = "Epic", Min = 1200, Max = 4500 },
	-- Legendary
	{ Id = "RoyalCrown", Name = "Royal Crown", Rarity = "Legendary", Min = 8000, Max = 25000 },
	{ Id = "GoldenStatue", Name = "Golden Statue", Rarity = "Legendary", Min = 6000, Max = 20000 },
	{ Id = "Meteorite", Name = "Meteorite", Rarity = "Legendary", Min = 5000, Max = 18000 },
}

Items.ById = {}
for _, item in Items.List do
	Items.ById[item.Id] = item
end

local function pickWeighted(list, rng: Random)
	local total = 0
	for _, entry in list do
		total += entry.Weight
	end
	local roll = rng:NextNumber() * total
	for _, entry in list do
		roll -= entry.Weight
		if roll <= 0 then
			return entry
		end
	end
	return list[#list]
end

-- Picks a random item and gives it a condition and a true value.
-- Returns { Id, Name, Rarity, Condition, TrueValue, ApparentValue, Fake?, Treasure? }.
-- ApparentValue = what it looks like it's worth. It differs from TrueValue only for
-- fakes (look valuable, worth little) and hidden treasures (look like junk, worth a lot).
function Items.Roll(rng: Random?)
	rng = rng or Random.new()

	local rarityList = {}
	for name, rarity in Items.Rarities do
		table.insert(rarityList, { Name = name, Weight = rarity.Weight })
	end
	local rarity = pickWeighted(rarityList, rng).Name

	local choices = {}
	for _, item in Items.List do
		if item.Rarity == rarity then
			table.insert(choices, item)
		end
	end
	local item = choices[rng:NextInteger(1, #choices)]
	local condition = pickWeighted(Items.Conditions, rng)
	local base = rng:NextInteger(item.Min, item.Max)

	local value = math.max(1, math.round(base * condition.Multiplier))
	local rolled = {
		Id = item.Id,
		Name = item.Name,
		Rarity = item.Rarity,
		Condition = condition.Name,
		TrueValue = value,
		ApparentValue = value,
	}
	local order = Items.Rarities[rarity].Order
	if order >= Items.Rarities.Rare.Order and rng:NextNumber() < Config.FakeChance then
		rolled.Fake = true
		rolled.TrueValue = math.max(1, math.round(value * rng:NextNumber(Config.FakeValue.Min, Config.FakeValue.Max)))
	elseif order <= Items.Rarities.Common.Order and rng:NextNumber() < Config.TreasureChance then
		rolled.Treasure = true
		rolled.TrueValue = math.round(value * rng:NextNumber(Config.TreasureValue.Min, Config.TreasureValue.Max))
	end
	return rolled
end

-- 1234567 -> "$1,234,567"
function Items.FormatMoney(amount: number): string
	local text = tostring(math.floor(amount))
	local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return "$" .. formatted
end

return Items
