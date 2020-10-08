# HTTPURLRequest

**HTTPURLRequest** is an easy way of an HTTP networking in Swift.

`HTTPURLRequest` keeps the information about the request using [`URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest) and uses [`URLSession`](https://developer.apple.com/documentation/foundation/urlsession) to send the request to a server.

## Making Requests
```swift
try? HTTPURLRequest(path: "http://example.com").dataTask() { response in
    switch response {
    case let .success(result):
        print(result)
    case let .failure(error):
        print(error)
    }
}

try? HTTPURLRequest(path: "http://example.com").dataTask() { response in
    print(response.output.success)
}

let url = URL(string: "http://example.com")
HTTPURLRequest(url: url).dataTask() { response in
    switch response {
    case let .success(result):
        print(result)
    case let .failure(error):
        print(error)
    }
}

let url = URL(string: "http://example.com")
let request = URLRequest(url: url)
HTTPURLRequest(request: request).dataTask() { response in
    switch response {
    case let .success(result):
        print(result)
    case let .failure(error):
        print(error)
    }
}
```