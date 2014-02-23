if SERVER then
	AddCSLuaFile('lib/cfg_parser.lua')
	AddCSLuaFile('roundmusic/sh_roundmusic.lua')
	include('roundmusic/sh_roundmusic.lua')
end

if CLIENT then
	include('roundmusic/sh_roundmusic.lua')
end

if type(RM) ~= 'table' then error('unable to load roundmusic') end

RM:Initialize()

hook.Add('ShutDown', 'roundmusic_shutdown', function()
	RM:Shutdown()
end)