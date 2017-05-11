//
//  SimpleStateMachine.swift
//  FLaws
//
//  Created by Frank Le Grand on 5/4/17.
//
//

import Foundation

public protocol SimpleStateMachineState {
    func canTransition(from: Self, to: Self) -> Bool
}

public protocol SimpleStateMachineDelegate: class {
    associatedtype StateType: SimpleStateMachineState
    func didTransition(from:StateType, to:StateType)
}

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
