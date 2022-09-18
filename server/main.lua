local gumCore = {}

TriggerEvent("getCore",function(core)
gumCore = core
end)

inv = exports.gum_inventory:gum_inventoryApi()
gum = exports.gum_core:gumAPI()

local SelectedHorseId = {}
local Horses

CreateThread(function()
	if GetCurrentResourceName() ~= "mino-stable" then
		print("^1=====================================")
		print("^1SCRIPT NAME OTHER THAN ORIGINAL")
		print("^1YOU SHOULD STOP SCRIPT")
		print("^1CHANGE NAME TO: ^2mino-stable^1")
		print("^1=====================================^0")
	end
end)

RegisterNetEvent("mino-stable:UpdateHorseComponents", function(components, idhorse, MyHorse_entity)
	local src = source
	local encodedComponents = json.encode(components)
	local gum_user = gumCore.getUser(source)
    local char = gum_user.getUsedCharacter
	local Playercid = char.identifier
	local charid = char.charIdentifier
	local id = idhorse
	exports.ghmattimysql:update("UPDATE horses SET `components`=@components WHERE `cid`=@cid AND `id`=@id AND `charid`=@charid", {components = encodedComponents, cid = Playercid, id = id, charid = charid}, function(done)
		TriggerClientEvent("mino-stable:client:UpdadeHorseComponents", src, MyHorse_entity, components)
	end)
end)

RegisterNetEvent("mino-stable:CheckSelectedHorse", function()
	local src = source
	local gum_user = gumCore.getUser(source)
    local char = gum_user.getUsedCharacter
	local Playercid = char.identifier
	local charid = char.charIdentifier

	exports.ghmattimysql:query('SELECT * FROM horses WHERE `charid`=@charid AND `cid`=@cid;', {charid = charid, cid = Playercid}, function(horses)
		if #horses ~= 0 then
			for i = 1, #horses do
				if horses[i].selected == 1 then
					TriggerClientEvent("VP:HORSE:SetHorseInfo", src, horses[i].model, horses[i].name, horses[i].components)
				end
			end
		end
	end)
end)

RegisterNetEvent("mino-stable:AskForMyHorses", function()
	local src = source
	local horseId = nil
	local components = nil
	local gum_user = gumCore.getUser(source)
    local char = gum_user.getUsedCharacter
	local Playercid = char.identifier
	local charid = char.charIdentifier
	exports.ghmattimysql:query('SELECT * FROM horses WHERE `charid`=@charid AND `cid`=@cid;', {charid = charid, cid = Playercid}, function(horses)
		if horses[1]then
			horseId = horses[1].id
		else
			horseId = nil
		end

		exports.ghmattimysql:query('SELECT * FROM horses WHERE `charid`=@charid AND `cid`=@cid;', {charid = charid, cid = Playercid}, function(components)
			if components[1] then
				components = components[1].components
			end
		end)
		TriggerClientEvent("mino-stable:ReceiveHorsesData", src, horses)
	end)
end)

RegisterNetEvent("mino-stable:BuyHorse", function(data, name)
	local src = source
	local gum_user = gumCore.getUser(source)
    local char = gum_user.getUsedCharacter
	local Playercid = char.identifier
	local charid = char.charIdentifier
	local gum_money = char.money
    local gum_gold = char.gold

	exports.ghmattimysql:query('SELECT * FROM horses WHERE `charid`=@charid AND `cid`=@cid;', {charid = charid, cid = Playercid}, function(horses)
		if #horses >= 3 then
			print('Hai il massimo di 3 cavalli')
			return
		end
		Wait(200)
		if data.IsGold then
			if gum_gold >= data.Gold then
				char.removeCurrency(src, 1, tonumber(data.Gold))
			else
				print('not enough money')
				return
			end
		else
			if gum_money >= data.Dollar then
				char.removeCurrency(src, 0, tonumber(data.Dollar))
			else
				print('not enough money')
				return
			end
		end
	exports.ghmattimysql:update('INSERT INTO horses (`cid`, `name`, `model`,`charid`) VALUES (@Playercid, @name, @model, @charid);',
		{
			Playercid = Playercid,
			name = tostring(name),
			model = data.ModelH,
			charid = charid
		}, function(rowsChanged)
		end)
	end)
end)

RegisterNetEvent("mino-stable:SelectHorseWithId", function(id)
	local src = source
	local gum_user = gumCore.getUser(source)
    local char = gum_user.getUsedCharacter
	local Playercid = char.identifier
	local charid = char.charIdentifier
	exports.ghmattimysql:query('SELECT * FROM horses WHERE `charid`=@charid AND `cid`=@cid;', {charid = charid, cid = Playercid}, function(horse)
		for i = 1, #horse do
			local horseID = horse[i].id
			exports.ghmattimysql:update("UPDATE horses SET `selected`='0' WHERE `charid`=@charid AND `cid`=@cid AND `id`=@id", {charid = charid, cid = Playercid,  id = horseID}, function(done)
			end)

			Wait(300)

			if horse[i].id == id then
				exports.ghmattimysql:update("UPDATE horses SET `selected`='1' WHERE `charid`=@charid AND `cid`=@cid AND `id`=@id", {charid = charid, cid = Playercid, id = id}, function(done)
					TriggerClientEvent("VP:HORSE:SetHorseInfo", src, horse[i].model, horse[i].name, horse[i].components)
				end)
			end
		end
	end)
end)

RegisterNetEvent("mino-stable:SellHorseWithId", function(id)
	local modelHorse = nil
	local src = source
	local gum_user = gumCore.getUser(source)
    local char = gum_user.getUsedCharacter
	local Playercid = char.identifier
	local charid = char.charIdentifier
	local gum_money = char.money
    local gum_gold = char.gold
	exports.ghmattimysql:query('SELECT * FROM horses WHERE `charid`=@charid AND `cid`=@cid;', {charid = charid, cid = Playercid}, function(horses)

		for i = 1, #horses do
		   if tonumber(horses[i].id) == tonumber(id) then
				modelHorse = horses[i].model
				exports.ghmattimysql:query('DELETE FROM horses WHERE `charid`=@charid AND `cid`=@cid AND`id`=@id;', {charid = charid, cid = Playercid,  id = id}, function(result)
				end)
			end
		end

		for k,v in pairs(Config.Horses) do
			for models,values in pairs(v) do
				if models ~= "name" then
					if models == modelHorse then
						local price = tonumber(values[3]/2)
						char.addCurrency(src, 0, price)
					end
				end
			end
		end
	end)
end)
