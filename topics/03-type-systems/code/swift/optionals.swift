// Option and nullable types in Swift: Int? is an Int or nothing (nil).

// <<option>>
func showValue(_ opt: Int?) -> String {
    if let x = opt {
        return "The value is: \(x)"
    }
    return "No value"
}
// <<option.end>>

// <<nullable>>
func greeting(_ name: String?) -> String {
    guard let unwrapped = name else {      // early exit when name is nil
        return "No name provided."
    }
    return "Hello, \(unwrapped)!"
}

func greetUser(username: String) -> String {   // String, not String?
    return "Welcome, \(username)!"
}
// <<nullable.end>>

precondition(showValue(42) == "The value is: 42")
precondition(showValue(nil) == "No value")
precondition(greeting("Alice") == "Hello, Alice!")
precondition(greeting(nil) == "No name provided.")
precondition(greetUser(username: "Bob") == "Welcome, Bob!")
print("ok")
