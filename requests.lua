-- similar to python 'requests', only compatible with roblox

local http = game:GetService("HttpService")

export type HttpMethod = 'GET'|'POST'|'PATCH'|'DELETE'|'PUT'|'OPTIONS'|'HEAD'
export type Request = {
	request: {
		url: string,
		method: HttpMethod,
		headers: {}?,
		data: string?,
		compress: boolean,
	},

	completed: boolean,
	debounce: boolean,
	ok: boolean,
	headers: {},
	status: number,
	status_type: number,
	content: string,
	error: string,

	json: (Request) -> any?,

	send: (Request) -> Request,
	_set_status: (Request, code: number) -> nil,
}

local request = {
	baseUrl = nil,
	baseHeaders = nil,
	debug = false,
}

function request._set_status(self: Request, code: number)
	self.status = code
	self.status_type = tonumber(tostring(self.status):sub(1, 1)) :: number
	self.ok = self.status_type == 2
end

-- send the request
function request.send(self: Request)
	assert(not self.debounce, 'cannot send while another request is on-going')
	self.completed = false
	self.debounce = true
	self:_set_status(100)
	
	local req = self.request
	local body = req.data 
	local url = req.url
	local headers = req.headers
	
	local compress = req.compress do
		local alg = if compress then 'Gzip' else nil
		compress = Enum.HttpCompression[alg or 'None']
	end
	
	if request.debug then
		print(
			req.method,
			url,
			headers,
			body,
			compress
		)
	end
	
	local response = http:RequestAsync({
		Url = url,
		Method = req.method,
		Headers = headers,
		Body = body,
		Compress = compress
	}) :: {
		Success: boolean,
		StatusCode: number,
		StatusMessage: string,
		Headers: {},
		Body: string?,
	}
	response.Body = response.Body or ''
	
	if request.debug then
		print(response.StatusCode, response.Body)
	end
	
	self.completed = true
	self.debounce = false
	
	self:_set_status(response.StatusCode)
	
	self.headers = response.Headers
	self.content = if self.ok then response.Body else ''
	self.error = if not self.ok then response.StatusMessage else ''
	
	return self
end

-- retrieve json from response
function request.json(self: Request): any
	assert(self.completed, 'request needs to be completed')
	if not self.ok then return nil end
	local data = http:JSONDecode(self.content)
	if data._request == nil then
		data._request = self
	end
	return data
end

-- constructors

type exampleHeader = {Authorization: string?, Accept: string?}|{}

-- base constructor
function request.request(
	method: HttpMethod, 
	url: string, 
	headers: exampleHeader?, 
	data: string|any?, 
	compress: boolean?
): Request
	
	local url = (
		(if request.baseUrl == nil then '' else request.baseUrl) .. url
	)
		:gsub('(.+)%.roblox%.com', '%1.roproxy.com') -- change roblox to compatible proxy
		:gsub('([^:])(\/+)', '%1/') -- remove double slashes
	
	local bodyless = method == 'GET' or method == 'HEAD'
	
	local data = data do
		if typeof(data) == 'table' then
			data = http:JSONEncode(data)
		end
		
		if bodyless then
			data = nil
		end
	end
	
	local headers = headers do
		if headers ~= nil then
			assert(headers['User-Agent'] == nil, 'User-Agent is locked')
		end
	end
	
	local compress = (compress or false) do
		if bodyless then
			compress = false
		end
	end
	
	local self = setmetatable({
		request = {
			url = url,
			method = method,
			headers = headers or request.baseHeaders,
			data = data,
			compress = compress or false,
		},

		completed = false,
		debounce = false,
		content = '',
		error = '',
	}, {
		__index = request
	})
	
	self:_set_status(100)

	return self:send() :: Request
end

function request.post(url: string, headers: exampleHeader?, data: string|any?, compress: boolean?)
	return request.request('POST', url, headers, data, compress)
end

function request.get(url: string, headers: exampleHeader?)
	return request.request('GET', url, headers)
end

return request