# HTTPURLRequest

**HTTPURLRequest** is an easy way of an HTTP networking in Swift.

`HTTPURLRequest` keeps the information about the request using [`URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest) and uses [`URLSession`](https://developer.apple.com/documentation/foundation/urlsession) to send the request to a server.
## Installation
### CocoaPods
[`CocoaPods`](https://cocoapods.org/) is a dependency manager for Swift and Objective-C Cocoa projects. To integrate `HTTPURLRequest` into your Xcode project using CocoaPods, specify it in your `Podfile`:
```ruby
pod 'HTTPURLRequest', git: 'https://github.com/HTTPURLRequest/HTTPURLRequest.git'
```
### Swift Package Manager
To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter `HTTPURLRequest` repository URL:
```
https://github.com/HTTPURLRequest/HTTPURLRequest.git
```
You can also navigate to your target’s General pane, and in the “Frameworks, Libraries, and Embedded Content” section, click the + button, select Add Other, and choose Add Package Dependency.

For more information, see [`Adding Package Dependencies to Your App`](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).
## Creating Request
There are available 3 request options: with [`String`](https://developer.apple.com/documentation/swift/string) path, [`URL`](https://developer.apple.com/documentation/foundation/url) and [`URLRequest`](https://developer.apple.com/documentation/foundation/urlrequest).
### Request with `String` path
> **Warning**. If the path is empty string or has an invalid value an error is thrown: `HTTPURLRequest.Error.emptyPath` or `HTTPURLRequest.Error.invalidPath(path)` accordingly.
```swift
let request = try? HTTPURLRequest(path: "http://example.com/")
```
For fast debug purposes you can use:
```swift
let result: Result<HTTPURLRequest, Error> = HTTPURLRequest.create(path: "http://example.com/")
print(result)
```
### Request with `URL`
```swift
let url = URL(string: "http://example.com/")!
let request = HTTPURLRequest(url: url)
```
### Request with `URLRequest`
```swift
let url = URL(string: "http://example.com/")!
let urlRequest = URLRequest(url: url)
let request = HTTPURLRequest(request: urlRequest)
```
## Making Requests
> **Warning**. Don't forget to pass the response to the main thread if necessary, as requests are executed in the background thread.
```swift
request.dataTask() { response in
    switch response {
    case let .success(result):
        print(result)
    case let .failure(error):
        print(error)
    }
}
```
`response` type is `Result<DataResponse, Error>`.

[`Result`](https://developer.apple.com/documentation/swift/result) is a value that represents either a success or a failure, including an associated value in each case from `Swift Standard Library Framework`.

`DataResponse` is simple [`Struct`](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html).
```swift
struct DataResponse: Equatable {
    let data: Data
    let response: HTTPURLResponse
}
```
If you are only interested in data, you can use the `success` property from `response`:
```swift
request.dataTask() { response in
    print(response.success)
}
```
To get `String` value from `response`:
```swift
let data: Data? = response.success?.data
let string: String? = data?.utf8String
```
To get `UIImage` value from `response` (_pass `response` to the main thread when working with `UI`_):
```swift
let data: Data? = response.success?.data
DispatchQueue.main.async {
    let image: UIImage? = data?.image
    ...
}
```
To get `Decodable` value from `response`:
> For more information about `Decodable`, see [`Encoding and Decoding Custom Types`](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types).
```swift
struct Product: Decodable {
    let title: String
}
let data: Data? = response.success?.data
let product: Product? = data?.decoding(type: Product.self).success
```
To get `jsonObject` value from `response`:
> For more information about `JSON in Swift`, see [`Working with JSON in Swift`](https://developer.apple.com/swift/blog/?id=37).
```swift
let data: Data? = response.success?.data
let jsonObject: Any? = data?.json().success
```
### Making `Decodable` Requests
```swift
struct Product: Decodable {
    let title: String
}
request.dataTask(decoding: Product.self) { response in
    switch response {
    case let .success(result):
        print(result.decoded)
    case let .failure(error):
        print(error)
    }
}
```
`response` type is `Result<DecodableResponse, Error>`.

[`Result`](https://developer.apple.com/documentation/swift/result) is a value that represents either a success or a failure, including an associated value in each case from `Swift Standard Library Framework`.

`DecodableResponse` is simple [`Struct`](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html).
```swift
struct DecodableResponse<T: Decodable> {
    let decoded: T
    let response: HTTPURLResponse
}
```
If you are only interested in data, you can use the `success` property from `response`:
```swift
struct Product: Decodable {
    let title: String
}
request.dataTask(decoding: Product.self) { response in
    let result: DecodableResponse<Product>? = response.success
    let product: Product? = result?.decoded
    print(product)
}
```
### Making `jsonObgect` Requests
```swift
request.jsonDataTask() { response in
    switch response {
    case let .success(result):
        print(result.json)
    case let .failure(error):
        print(error)
    }
}
```
`response` type is `Result<JSONResponse, Error>`.

[`Result`](https://developer.apple.com/documentation/swift/result) is a value that represents either a success or a failure, including an associated value in each case from `Swift Standard Library Framework`.

`JSONResponse` is simple [`Struct`](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html).
```swift
struct JSONResponse {
    let json: Any
    let response: HTTPURLResponse
}
```
If you are only interested in data, you can use the `success` property from `response`:
```swift
request.jsonDataTask() { response in
    let result: JSONResponse? = response.success
    let json: Any? = result?.json
    print(json)
}
```