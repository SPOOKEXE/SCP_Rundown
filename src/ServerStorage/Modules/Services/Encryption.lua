return {
	Encrypt = function(cipher, key)
		local key_bytes
		if type(key) == "string" then
			key_bytes = {}
			for key_index = 1, #key do
				key_bytes[key_index] = string.byte(key, key_index)
			end
		else
			key_bytes = key
		end
		local message_length = #cipher
		local key_length = #key_bytes
		local message_bytes = {}
		for message_index = 1, message_length do
			message_bytes[message_index] = string.byte(cipher, message_index)
		end
		local result_bytes = {}
		local random_seed = 0
		for key_index = 1, key_length do
			random_seed = (random_seed + key_bytes[key_index] * key_index) * 1103515245 + 12345
			random_seed = (random_seed - random_seed % 65536) / 65536 % 4294967296
		end
		for message_index = 1, message_length do
			local message_byte = message_bytes[message_index]
			for key_index = 1, key_length do
				local key_byte = key_bytes[key_index]
				local result_index = message_index + key_index - 1
				local result_byte = message_byte + (result_bytes[result_index] or 0)
				if result_byte > 255 then
					result_byte = result_byte - 256
				end
				result_byte = result_byte + key_byte
				if result_byte > 255 then
					result_byte = result_byte - 256
				end
				random_seed = (random_seed % 4194304 * 1103515245 + 12345)
				result_byte = result_byte + (random_seed - random_seed % 65536) / 65536 % 256
				if result_byte > 255 then
					result_byte = result_byte - 256
				end
				result_bytes[result_index] = result_byte
			end
		end
		local result_buffer = {}
		local result_buffer_index = 1
		for result_index = 1, #result_bytes do
			local result_byte = result_bytes[result_index]
			result_buffer[result_buffer_index] = string.format("%02x", result_byte)
			result_buffer_index = result_buffer_index + 1
		end
		return table.concat(result_buffer)
	end,
	
	Decrypt = function(cipher, key)
		local key_bytes
		if type(key) == "string" then
			key_bytes = {}
			for key_index = 1, #key do
				key_bytes[key_index] = string.byte(key, key_index)
			end
		else
			key_bytes = key
		end
		local cipher_raw_length = #cipher
		local key_length = #key_bytes
		local cipher_bytes = {}
		local cipher_length = 0
		local cipher_bytes_index = 1
		for byte_str in string.gmatch(cipher, "%x%x") do
			cipher_length = cipher_length + 1
			cipher_bytes[cipher_length] = tonumber(byte_str, 16)
		end
		local random_bytes = {}
		local random_seed = 0
		for key_index = 1, key_length do
			random_seed = (random_seed + key_bytes[key_index] * key_index) * 1103515245 + 12345
			random_seed = (random_seed - random_seed % 65536) / 65536 % 4294967296
		end
		for random_index = 1, (cipher_length - key_length + 1) * key_length do
			random_seed = (random_seed % 4194304 * 1103515245 + 12345)
			random_bytes[random_index] = (random_seed - random_seed % 65536) / 65536 % 256
		end
		local random_index = #random_bytes
		local last_key_byte = key_bytes[key_length]
		local result_bytes = {}
		for cipher_index = cipher_length, key_length, -1 do
			local result_byte = cipher_bytes[cipher_index] - last_key_byte
			if result_byte < 0 then
				result_byte = result_byte + 256
			end
			result_byte = result_byte - random_bytes[random_index]
			random_index = random_index - 1
			if result_byte < 0 then
				result_byte = result_byte + 256
			end
			for key_index = key_length - 1, 1, -1 do
				cipher_index = cipher_index - 1
				local cipher_byte = cipher_bytes[cipher_index] - key_bytes[key_index]
				if cipher_byte < 0 then
					cipher_byte = cipher_byte + 256
				end
				cipher_byte = cipher_byte - result_byte
				if cipher_byte < 0 then
					cipher_byte = cipher_byte + 256
				end
				cipher_byte = cipher_byte - random_bytes[random_index]
				random_index = random_index - 1
				if cipher_byte < 0 then
					cipher_byte = cipher_byte + 256
				end
				cipher_bytes[cipher_index] = cipher_byte
			end
			result_bytes[cipher_index] = result_byte
		end
		local result_characters = {}
		for result_index = 1, #result_bytes do
			result_characters[result_index] = string.char(result_bytes[result_index])
		end
		return table.concat(result_characters)
	end	

}