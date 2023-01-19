local HttpService = game:GetService('HttpService')
local MessagingService = game:GetService('MessagingService')

local EncryptModule = require(script.Encrypt)
local Base64Module = require(script.Base64)

local SHARED_MESSAGING_TOPIC = 'SHARED_MESSAGING_SERVICE'
local ENCRYPTION_KEY = 'bjsdbjoladfbjknask'

local CallbackBindableCache = {}
local CallbackEventCache = {}

local function GetMessagingCallbackBindable(topic)
	if not CallbackBindableCache[topic] then
		CallbackBindableCache[topic] = Instance.new('BindableEvent')
	end
	return CallbackBindableCache[topic]
end

local function GetMessagingCallbackConnection(topic, callback)
	if not CallbackEventCache[topic] then
		CallbackEventCache[topic] = GetMessagingCallbackBindable(topic).Event
	end
	return CallbackEventCache[topic]
end

-- // Module // --
local Module = {}

function Module:EncrptData(data)
	local encoded = HttpService:JSONEncode(data)
	local bs4 = Base64Module.encode(encoded)
	return 'ENC'..EncryptModule.encrypt(bs4, ENCRYPTION_KEY)
end

function Module:DecryptData(data)
	if string.sub(data, 1, 3) ~= 'ENC' then
		return false
	end
	data = string.sub(data, 4, #data)
	local decrypted = EncryptModule.decrypt(data, ENCRYPTION_KEY)
	local standard_form = Base64Module.decode(decrypted)
	return HttpService:JSONDecode(standard_form)
end

function Module:PublishAsync(topic, data)
	MessagingService:PublishAsync(topic, {Topic = topic, Data = Module:EncrptData(data)})
end

function Module:OnDataRecieve(topic, callback)
	return GetMessagingCallbackConnection(topic, callback)
end

task.spawn(pcall, function()
	MessagingService:SubscribeAsync(SHARED_MESSAGING_TOPIC, function(data)
		GetMessagingCallbackBindable(data.Topic):Fire(data.Data)
	end)
end)

return Module