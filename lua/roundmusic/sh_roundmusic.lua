RM = {}

RM.CFG = {}
RM.Sources = {}

include('../lib/cfg_parser.lua')

local function IsValidSource(source)
	if type(source) ~= 'table' then return false end
	if type(source.ID) ~= 'nil' and type(source.ID) ~= 'string' then return false end
	if type(source.Init) ~= 'nil' and type(source.Init) ~= 'function' then return false end
	if type(source.SV_Init) ~= 'nil' and type(source.SV_Init) ~= 'function' then return false end
	if type(source.CL_Init) ~= 'nil' and type(source.CL_Init) ~= 'function' then return false end
	if type(source.Play) ~= 'function' or type(source.Stop) ~= 'function' then return false end

	return true
end

function RM:LoadCFG()
	self.CFG = table.Copy(CFG)

	self.CFG:AddFile('roundmusic', 'roundmusic/roundmusic.txt')
	self.CFG:AddDefaults('roundmusic', {
		source = 'base'
	})

	self.CFG:Load()
end

function RM:LoadSources()
	local files = file.Find('sources/*.lua', 'LUA')

	for _, file in ipairs(files) do
		if SERVER then AddCSLuaFile('sources/' .. file) end

		if not string.StartWith(file, '__') then
			SOURCE = {}
			SOURCE.ID = ''

			include('sources/' .. file)

			if #SOURCE.ID == 0 then SOURCE.ID = string.gsub(file, '.lua', '') end

			if not IsValidSource(SOURCE) then error('invalid source ' .. SOURCE.ID) end

			if type(self.Sources[SOURCE.ID]) ~= 'nil' then
				error('source id ' .. SOURCE.ID .. ' already exists')
			end

			self.Sources[SOURCE.ID] = SOURCE
		end
	end

	SOURCE = nil
end

function RM:Initialize()
	self:LoadCFG()
	self:LoadSources()

	local source = self:GetCurrentSource()

	if type(source.Init) == 'function' then source:Init() end

	if SERVER then
		if type(source.SV_Init) == 'function' then source:SV_Init() end
	else
		if type(source.CL_Init) == 'function' then source:CL_Init() end
	end
end

function RM:Shutdown()
	self.CFG:Save()
end

function RM:GetCurrentSource()
	local config = self.CFG:Get('roundmusic')
	local source = self.Sources[config.source]

	if not IsValidSource(source) then error('invalid source ' .. config.source) end

	return source or {}
end

function RM:Play()
	local source = self:GetCurrentSource()

	source:Play()
end

function RM:Stop()
	local source = self:GetCurrentSource()

	source:Stop()
end