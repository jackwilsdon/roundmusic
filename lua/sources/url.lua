NET_PLAY = 0
NET_STOP = 1

SOURCE.ID = 'url'
SOURCE.CFG = table.Copy(CFG)

function SOURCE:SV_Init()
	self.CFG:AddFile(self.ID, 'roundmusic/sources/url.txt')
	self.CFG:AddDefaults(self.ID, {
		listurl = 'http://localhost/list.php',
		baseurl = 'http://localhost/music/'
	})
	self.CFG:Load()

	util.AddNetworkString('roundmusic_url_action')
end

function SOURCE:SV_Play()
	self:SV_Action(NET_PLAY, "http://localhost/music/April Showers.mp3")
	-- self:SV_GetSong(function(song)
	-- 	self:SV_Action(NET_PLAY, song)
	-- end)
end

function SOURCE:SV_Stop()
	self:SV_Action(NET_STOP)
end

function SOURCE:SV_GetSong(callback)
	local config = self.CFG:Get(self.ID)
	http.Fetch(config.listurl, function(body, len, headers, code)
		local songs = string.Explode(',', body)
		local index = math.random(#songs)
		local base = config.baseurl

		if #songs == 0 then return end
		callback(base .. '/' .. songs[index])
	end, function(err) print(err) end)
end

function SOURCE:SV_Action(action, url)
	net.Start('roundmusic_url_action')
		net.WriteInt(action, 8)

		if type(url) == 'string' then
			net.WriteString(url)
		end
	net.Broadcast()
end

function SOURCE:CL_Init()
	net.Receive('roundmusic_url_action', function(len)
		self:CL_Action(len)
	end)
end

function SOURCE:CL_Play(url)
	sound.PlayURL(url, "", function(stream)
		local ply = LocalPlayer()

		self:CL_Stop()

		ply.RM_Channel = stream
	end)
end

function SOURCE:CL_Stop()
	local ply = LocalPlayer()

	if IsValid(ply.RM_Channel) then
		ply.RM_Channel:Stop()
	end
end

function SOURCE:CL_Action(len)
	if len == 0 then error('invalid action') end

	local action = net.ReadInt(8)

	if action == NET_PLAY then
		local url = net.ReadString()
		self:CL_Play(url)
	elseif action == NET_STOP then
		self:CL_Stop()
	end
end

function SOURCE:Play()
	self:SV_Play()
end

function SOURCE:Stop()
	self:SV_Stop()
end