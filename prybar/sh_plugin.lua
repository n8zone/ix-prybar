PLUGIN.name = "Prying Crowbars"
PLUGIN.author = "Generic"
PLUGIN.description = "Allows you to pry open doors with a crowbar."

ix.config.Add("pryTime", 5, "How long it takes to pry open a door.", nil, {
	data = {min = 1, max = 10, decimals = 0},
	category = "Prying"
})

ix.config.Add("pryChance", 50, "The chance of a door being pryable.", nil, {
	data = {min = 1, max = 100, decimals = 0},
	category = "Prying"
})