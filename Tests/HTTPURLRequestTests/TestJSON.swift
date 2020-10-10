struct TestJSON: Decodable, Equatable {
    let names: [String]
}
let jsonString = #"{"names":["Bob","Tim","Tina"]}"#
