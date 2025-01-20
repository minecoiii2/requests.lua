-- similar to python 'requests', only compatible with roblox

local http = game:GetService("HttpService")

export type HttpMethod = 'GET'|'POST'|'PATCH'|'DELETE'|'PUT'|'OPTIONS'
export type Request = {
	request: {
		url: string,
		method: HttpMethod,
		headers: {}?,
		data: any?,
		compress: boolean,
	},
	
	completed: boolean,
	ok: boolean,
	status: number,
	content: string,
	
	json: (Request) -> any?,
	
	send: (Request) -> Request,
}

local request = {
	baseUrl = nil
}
request.__index = request

-- sets a prefix for all requests
function request.set_base_url(url: string?)
	request.baseUrl = url
end

-- send the request
function request.send(self: Request)
	self.completed = false

	local req = self.request
	local ok, result = pcall(http.RequestAsync, http, {
		Url = req.url,
		Method = req.method,
		Headers = req.headers,
		Data = http:JSONEncode(req.data),
		Compress = Enum.HttpCompression[if req.compress then 'Gzip' else 'None']
	}) 
	
	result = if result == nil then '' else tostring(result)
	
	self.completed = true
	self.ok = ok
	
	if ok then
		self.status = 200
		self.content = result
	else
		local err: string = result:lower()
		
		if err:find('http') then
			local status_code = err:match("%d%d%d")
			
			if status_code == nil then
				self.status = 400
			else
				self.status = tonumber(status_code) :: number
			end
		else
			self.status = 400
		end
	end
	
	return self
end

-- retrieve json from response
function request.json(self: Request): any
	assert(self.completed, 'request needs to be completed')
	return http:JSONDecode(self.content)
end

-- constructor
function request.request(url: string, method: HttpMethod, headers: {}?, data: any?, compress: boolean?)
	local editedUrl = ((if request.baseUrl == nil then '' else request.baseUrl) .. url)
	
	editedUrl = editedUrl:gsub('(.+)%.roblox%.com', '%1.roproxy.com')
	
	local self = setmetatable({
		request = {
			url = editedUrl,
			method = method,
			headers = headers,
			data = data,
			compress = compress or false,
		},
		
		completed = false,
		ok = false,
		status = 100,
		content = '',
	}, request)
	
	return self:send() :: Request
end

return request