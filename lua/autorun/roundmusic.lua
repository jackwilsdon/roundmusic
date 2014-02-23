if SERVER then
	AddCSLuaFile('lib/cfg_parser.lua')
	AddCSLuaFile('roundmusic/sh_roundmusic.lua')
	include('roundmusic/sh_roundmusic.lua')
end

if CLIENT then
	include('roundmusic/sh_roundmusic.lua')
end

if type(RM) ~= 'table' then error('unable to load roundmusic') end

hook.Add('Initialize', 'roundmusic_initialize', function()
	RM:Initialize()
end)

hook.Add('ShutDown', 'roundmusic_shutdown', function()
	RM:Shutdown()
end)