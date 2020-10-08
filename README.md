# HTTPURLRequest

**HTTPURLRequest** is an easy way of an HTTP networking in Swift.

`HTTPURLRequest` keeps the information about the request using [`URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest) and uses [`URLSession`](https://developer.apple.com/documentation/foundation/urlsession) to send the request to a server.

## Making Requests
There are available 3 request options: with [`String`](https://developer.apple.com/documentation/swift/string) path, [`URL`](https://developer.apple.com/documentation/foundation/url) and [`URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest).
### Requests with String path
> **Warning**. If the path is empty string or has an invalid value an error is thrown: `HTTPURLRequest.Error.emptyPath` or `HTTPURLRequest.Error.invalidPath(path)` accordingly.
```swift
try? HTTPURLRequest(path: "http://example.com").dataTask() { response in
    switch response {
    case let .success(result):
        print(result)
    case let .failure(error):
        print(error)
    }
}
```
`response` type is `Result<HTTPData, Error>`.

[`Result`](https://developer.apple.com/documentation/swift/result) is a value that represents either a success or a failure, including an associated value in each case from `Swift Standard Library Framework`.

`HTTPData` is simple [`Struct`](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html).
```swift
struct HTTPData: Equatable {
    let data: Data
    let response: HTTPURLResponse
}
```
If you are only interested in data, you can use the `output.success` property from `response`:
```swift
try? HTTPURLRequest(path: "http://example.com").dataTask() { response in
    print(response.output.success)
}
```
### Requests with URL
```swift
let url = URL(string: "http://example.com")
HTTPURLRequest(url: url).dataTask() { response in
    switch response {
    case let .success(result):
        print(result)
    case let .failure(error):
        print(error)
    }
}
```
### Requests with URLRequest
```swift
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