CFG = {}

CFG.files = {} -- A list of files to be loaded, and their names
CFG.defaults = {} -- A list of names and their default values
CFG.data = {} -- The loaded data

-- Utility functions

local function GetLength(var)
	local length = -1

	if type(var) == 'table' then
		length = 0

		for _, __ in pairs(var) do
			length = length + 1
		end
	elseif type(var) == 'string' then
		length = #var
	end

	return length
end

local function MkDirs(filename)
	local slashed = string.gsub(filename, '\\', '/')
	local dirs = string.Explode('/', slashed)

	table.remove(dirs)

	if #dirs == 0 then return end

	local alldirs = table.concat(dirs, '/')

	file.CreateDir(alldirs)
end

-- Configuration methods

function CFG:AddFile(name, filename)
	if type(name) ~= 'string' then error('invalid name') end
	if type(filename) ~= 'string' then error('invalid filename') end

	if type(self.files[name]) ~= 'nil' then error('name already taken') end

	if not file.Exists(filename, 'DATA') then
		MkDirs(filename)
		file.Write(filename, '')
	end

	self.files[name] = filename
end

function CFG:AddDefaults(name, defaults)
	if type(name) ~= 'string' then error('invalid name') end
	if type(defaults) ~= 'table' then error('invalid defaults') end

	if type(self.defaults[name]) ~= 'nil' then error('name already taken') end

	self.defaults[name] = defaults
end

function CFG:Get(name)
	if type(name) ~= 'string' then error('invalid name') end
	if type(self.data[name]) == 'nil' then error ('invalid name') end

	return table.Copy(self.data[name])
end

function CFG:ParseLine(line)
	local split = string.Explode('[ ]*=[ ]*', line, true)

	if GetLength(split) ~= 2 then
		return nil
	end

	local name = split[1]
	local value = split[2]

	return name, value
end

function CFG:Parse(lines)
	if GetLength(lines) == 0 then return {} end

	local out = {}

	for _, line in ipairs(lines) do
		if GetLength(line) > 0 then
			local k, v = self:ParseLine(line)
			
			if type(out[k]) ~= 'nil' then
				if type(out[k]) == 'table' then
					table.insert(out[k], v)
				else
					out[k] = {out[k], v}
				end
			else
				out[k] = v
			end
		end
	end

	return out
end

function CFG:Load()
	if GetLength(self.files) <= 0 then return end

	self.data = {}

	for name, filename in pairs(self.files) do
		local raw = file.Read(filename, 'DATA')
		local lines = string.Explode('\n', raw)
		local data = self:Parse(lines)

		self.data[name] = data
	end

	for name, default in pairs(self.defaults) do
		if type(self.data[name]) == 'nil' then
			self.data[name] = table.Copy(default)
		else
			for key, value in pairs(default) do
				if type(self.data[name][key]) == 'nil' then
					self.data[name][key] = value
				end
			end
		end
	end
end

function CFG:Save()
	if GetLength(self.data) <= 0 then return end

	local output = {}

	for name, data in pairs(self.data) do
		local lines = {}

		for key, value in pairs(data) do
			if type(value) == 'table' then
				for _, subvalue in ipairs(value) do
					table.insert(lines, key .. ' = ' .. tostring(subvalue))
				end
			else
				table.insert(lines, key .. ' = ' .. tostring(value))
			end
		end

		output[name] = lines
	end

	for name, lines in pairs(output) do
		local filename = self.files[name]
		local content = table.concat(lines, '\n')
		file.Write(filename, content)
	end
end