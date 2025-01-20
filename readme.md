### requests.lua

requests.lua aims to replicate pythons 'requests' lib

only compatible with Roblox!!!!! 

roblox heavily limits what you can see and not see with httpService.
using requests.lua it facilitates the use of httpService and error-handling

ill most likely update this module a few more times to give it a few features in the future (very unlikely)

#### features

list of features not natively supported by httpService

- error handling
- status codes
- can re-send the same requests using :send()
- supports roblox requests (using roproxy)
- can set a baseUrl using .set_base_url(baseUrl: string?)
- uses types
- basic type checking

#### request struct

```lua
type Request = {
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
	
	json: (Request) -> any?, -- converts self.content to JSON
	
	send: (Request) -> Request,
}
```