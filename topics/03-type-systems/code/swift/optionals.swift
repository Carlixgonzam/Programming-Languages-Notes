
func showValue(_ opt: Int?) -> String {
    if let x = opt {
        return "The value is: \(x)"
    }
    return "No value"
}

func greeting(_ name: String?) -> String {
    guard let unwrapped = name else {
        return "No name provided."
    }
    return "Hello, \(unwrapped)!"
}

func greetUser(username: String) -> String {
    return "Welcome, \(username)!"
}

precondition(showValue(42) == "The value is: 42")
precondition(showValue(nil) == "No value")
precondition(greeting("Alice") == "Hello, Alice!")
precondition(greeting(nil) == "No name provided.")
precondition(greetUser(username: "Bob") == "Welcome, Bob!")
print("ok")
