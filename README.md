# SimpleStateMachine

[![Build Status][image-1]][1] [![Swift Version][image-2]][2]

A simple Swift state machine package

### How to use
Define a class that implements the `SimpleStateMachineDelegate` protocol with:

####1. An enum to define the states of the machine:
```swift
public enum MockMachineDelegateState: SimpleStateMachineState, Equatable {
    case ready, doingSomething
    case done(Any)
    
    public func canTransition(from: StateType, to: StateType) -> Bool {
        switch (from, to) {
        case (_, .ready):
            return true
        case (.ready, .doingSomething):
            return true
        case (.doingSomething, .done(_)):
            return true
        default:
            return false
        }
    }
}
```

####2. The associated type for the state:
```swift
public typealias StateType = MockMachineDelegateState
```

####3. The method in which you implement your code for when the machine transitions to another state:
```swift
public func didTransition(from: StateType, to: StateType) {
    
    switch (from, to) {
    case (_, .ready):
        self.getReady()
    case (.ready, .doingSomething):
        self.doSomething() // Your own method
    case (.doingSomething, .done(let someResult)):
        self.handleDoneDoingSomething(with: someResult) // Your own method
        
    default:
        break
    }
}
```

##### Then instantiate a machine:
```swift
let machineDelegate = MockMachineDelegate()
machine = SimpleStateMachine<MockMachineDelegate>(initialState: .ready, delegate: machineDelegate)
// Let's do something
machine.state = .doSomething
```

[1]:    https://travis-ci.org/amorican/SimpleStateMachine
[2]:    https://swift.org "Swift"

[image-1]:  https://travis-ci.org/amorican/SimpleStateMachine.svg
[image-2]:  https://img.shields.io/badge/swift-version%203-blue.svg