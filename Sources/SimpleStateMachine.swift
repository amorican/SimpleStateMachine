//
//  SimpleStateMachine.swift
//  FLaws
//
//  Created by Frank Le Grand on 5/4/17.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

/**
 The state of SimpleStateMachine machine object is represented by an object which must conform to the protocol SimpleStateMachineState.
 Example:
 ```
 enum dataLoaderState {
    case ready, loading
    case success(Data)
    case failure(Error)
 }
 ```
 */
public protocol SimpleStateMachineState {
    
    /**
     The transition rules from one state to another are defined in the enum itself through the implementation of this method.
     - Parameter from: The state from which the machine wants to transition.
     - Parameter to: The state to which the machine proposes to transition.
     - Returns: A Bool indicating whether the machine is allowed to switch states.
     */
    func canTransition(from: Self, to: Self) -> Bool
}

/**
 A SimpleStateMachine's delegate defines the states of the machine, the transition rules between states, and gets notified when the machine state's has changed thru `didTransition(from:StateType, to:StateType)`.
 */
public protocol SimpleStateMachineDelegate: class {
    associatedtype StateType: SimpleStateMachineState
    func didTransition(from:StateType, to:StateType)
}

/**
 A SimpleStateMachine object exposes a thread safe state property and notifies its delegate when it changes.
 */
public class SimpleStateMachine<T: SimpleStateMachineDelegate> {
    
    private let accessQueue = DispatchQueue(label: "SimpleStateMachineAccess", attributes: .concurrent)
    
    private weak var delegate: T?
    
    private var _state: T.StateType {
        didSet {
            delegate?.didTransition(from: oldValue, to: _state)
        }
    }
    
    public var state: T.StateType {
        get {
            return _state
        }
        set {
            self.accessQueue.sync {
                if self._state.canTransition(from: self._state, to: newValue) {
                    self._state = newValue
                }
            }
        }
    }
    
    public init(initialState: T.StateType, delegate: T) {
        _state = initialState
        self.delegate = delegate
    }
}
