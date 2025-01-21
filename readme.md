### requests.lua

requests.lua aims to replicate pythons 'requests' lib

only compatible with Roblox!!!!! 

roblox heavily limits what you can see and not see with httpService.
using requests.lua it facilitates the use of httpService and error-handling

ill most likely update this module a few more times to give it a few features in the future

#### use

download or paste the module inside roblox
require the module like so
`local requests = require(path.to.module)`

this is the base function, other functions such as .get and .post use .request under the hood with auto-filled parameters
`requests.request(...)`

`requests.get(url: string, headers: any)`
`requests.post(url: string, headers: any, data: any, compress: boolean?)`

send all the requests you want

#### features

list of features;

- uses types
- http error handling
- status codes
- re-sending the same requests (using :send())
- supports roblox.com requests (using roproxy)
- supports response headers (unlike :GetAsync and :PostAsync)
- all http methods supported

#### request struct

```lua
type Request = {
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
```