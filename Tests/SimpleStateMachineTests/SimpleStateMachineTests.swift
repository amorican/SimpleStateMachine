//
//  SimpleStateMachineTests.swift
//  FLaws
//
//  Created by Frank Le Grand on 5/8/17.
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

import XCTest
@testable import SimpleStateMachine

class SimpleStateMachineTests: XCTestCase {
    
    let machineDelegate = MockMachineDelegate()
    var machine: SimpleStateMachine<MockMachineDelegate>?
    
    override func setUp() {
        super.setUp()
        machine = SimpleStateMachine<MockMachineDelegate>(initialState: .ready, delegate: machineDelegate)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_whenMachineIsInstantiated_thenMachineIsInInitialState() {
        XCTAssert(machine?.state == .ready, "Machine state should be \".ready\".")
        XCTAssertFalse(machineDelegate.somethingHasStarted, "Something should not have started because the machine state is \".ready\".")
        XCTAssertFalse(machineDelegate.somethingIsDone, "Something should not have been done because the machine state is \".ready\".")
    }
    
    func test_whenStateIsChanged_thenMachineTransitionsOnlyToAllowedStates() {
        XCTAssert(machine?.state == .ready, "Machine state should be \".ready\".")
        XCTAssertFalse(machineDelegate.somethingHasStarted, "Machine delegate should not have done something.")
        
        machine?.state = .done
        XCTAssertFalse(machine?.state == .done, "Machine should not have transitioned from .ready to .done.")
        XCTAssertTrue(machine?.state == .ready, "Machine state should have remained .ready.")
        
        machine?.state = .doingSomething
        XCTAssertTrue(machine?.state == .doingSomething, "Machine state should be .doingSomething.")
        XCTAssertTrue(machineDelegate.somethingHasStarted, "Machine delegate should have done something.")
        
        machine?.state = .done
        XCTAssertTrue(machine?.state == .done, "Machine state should be .done")
        XCTAssertTrue(machineDelegate.somethingIsDone, "Machine delegate should have finished doing something.")
        
        machine?.state = .doingSomething
        XCTAssertFalse(machine?.state == .doingSomething, "Machine was done and shouldn't be doing something.")
        
        machine?.state = .ready
        XCTAssertTrue(machine?.state == .ready, "Machine state should be .ready.")
        XCTAssertFalse(machineDelegate.somethingHasStarted, "Machine delegate should be ready to start something, but has already started.")
        XCTAssertFalse(machineDelegate.somethingIsDone, "Machine delegate should be ready to start something, but is already done.")
    }
}

// MARK: - Mock Delegate

class MockMachineDelegate: SimpleStateMachineDelegate {
    
    // MARK: SimpleStateMachineDelegate Protocol Implementation
    
    public enum MockMachineDelegateState: SimpleStateMachineState, Equatable {
        case ready, doingSomething, done
        
        public func canTransition(from: StateType, to: StateType) -> Bool {
            switch (from, to) {
            case (_, .ready):
                return true
            case (.ready, .doingSomething):
                return true
            case (.doingSomething, .done):
                return true
            default:
                return false
            }
        }
    }
    
    public typealias StateType = MockMachineDelegateState
    
    public func didTransition(from: StateType, to: StateType) {
        
        switch (from, to) {
        case (_, .ready):
            self.getReady()
        case (.ready, .doingSomething):
            self.doSomething()
        case (.doingSomething, .done):
            self.handleDoneDoingSomething()
            
        default:
            break
        }
    }
    
    // MARK: Mock Class Implemention
    
    var somethingHasStarted = false
    var somethingIsDone = false
    
    func getReady() {
        somethingHasStarted = false
        somethingIsDone = false
    }
    
    func doSomething() {
        somethingHasStarted = true
    }
    
    func handleDoneDoingSomething() {
        somethingIsDone = true
    }
}
