//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26/08/2024.
//

import UIKit
import SwiftUI

extension UIViewController: UIStateObserver { }

extension UIView: UIStateObserver {
    
}

public protocol UIStateObserver: AnyObject { }

extension UIStateObserver {
    var cancellable: AnyCancellableEffect { AnyCancellableEffect(self) }
}
 
public extension UIStateObserver {
    func subscribe<State, Action, Props>(store: Store<State, Action>,
                                         props: @escaping (State, Store<State, Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         debounceFor timeInterval: TimeInterval = .uiDebounce,
                                         observe: @escaping (Props) -> Void) {
        
        store.effect(
            cancellable,
            withDelay: timeInterval,
            removeStateDuplicates: equating,
            on: presentationQueue) { state, _ in
                Effect {
                    let props = props(state, store)
                    guard presentationQueue == DispatchQueue.main else {
                        DispatchQueue.main.async { observe(props) }
                        return
                    }
                    observe(props)
                }
            }
    }
    
    func subscribe<State, Action, Props>(_ store: Store<State, Action>,
                                         props: @escaping (State, @escaping Dispatch<Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         debounceFor timeInterval: TimeInterval = .uiDebounce,
                                         observe: @escaping (Props) -> Void) {
        
        subscribe(
            store: store,
            props: { state, store in props(state, store.dispatch) },
            presentationQueue: presentationQueue,
            removeStateDuplicates: equating,
            debounceFor: timeInterval,
            observe: observe
        )
    }
    
    func subscribe<State, Action>(_ store: Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  debounceFor timeInterval: TimeInterval = .uiDebounce,
                                  observe: @escaping (State) -> Void) {
        
        subscribe(
            store,
            props: { state, _ in state },
            presentationQueue: .main,
            removeStateDuplicates: equating,
            debounceFor: timeInterval,
            observe: observe
        )
    }
    
    func subscribe<State, Action>(_ store: Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  debounceFor timeInterval: TimeInterval  = .uiDebounce,
                                  observe: @escaping (State, Dispatch<Action>) -> Void) {
        
        subscribe(
            store: store,
            removeStateDuplicates: equating,
            debounceFor: timeInterval,
            observe: { state, store in observe(state, store.dispatch) }
        )
    }
    
    func subscribe<State, Action>(store: Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  debounceFor timeInterval: TimeInterval = .uiDebounce,
                                  observe: @escaping (State, Store<State, Action>) -> Void) {
        
        subscribe(
            store: store,
            props: { state, store in (state, store) },
            presentationQueue: .main,
            removeStateDuplicates: equating, 
            debounceFor: timeInterval,
            observe: observe
        )
    }
}
//
//public extension UIStateObserver {
//    func subscribe<State, Action, Props>(store: StateStore<State, Action>,
//                                         props: @escaping (State, Store<State, Action>) -> Props,
//                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
//                                         removeStateDuplicates equating: Equating<State>? = nil,
//                                         observe: @escaping (Props) -> Void) {
//        
//        subscribe(
//            store: store.strongStore(),
//            props: props,
//            presentationQueue: presentationQueue,
//            removeStateDuplicates: equating,
//            observe: observe
//        )
//    }
//    
//    func subscribe<State, Action, Props>(_ store: StateStore<State, Action>,
//                                         props: @escaping (State, @escaping Dispatch<Action>) -> Props,
//                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
//                                         removeStateDuplicates equating: Equating<State>? = nil,
//                                         observe: @escaping (Props) -> Void) {
//        
//        subscribe(
//            store.strongStore(),
//            props: props,
//            presentationQueue: presentationQueue,
//            removeStateDuplicates: equating,
//            observe: observe
//        )
//    }
//    
//    func subscribe<State, Action>(_ store: StateStore<State, Action>,
//                                  removeStateDuplicates equating: Equating<State>? = nil,
//                                  observe: @escaping (State) -> Void) {
//        
//        subscribe(
//            store.strongStore(),
//            removeStateDuplicates: equating,
//            observe: observe
//        )
//    }
//    
//    func subscribe<State, Action>(_ store: StateStore<State, Action>,
//                                  removeStateDuplicates equating: Equating<State>? = nil,
//                                  observe: @escaping (State, Dispatch<Action>) -> Void) {
//        
//        subscribe(
//            store.strongStore(),
//            removeStateDuplicates: equating,
//            observe: observe
//        )
//    }
//    
//    func subscribe<State, Action>(store: StateStore<State, Action>,
//                                  removeStateDuplicates equating: Equating<State>? = nil,
//                                  observe: @escaping (State, Store<State, Action>) -> Void) {
//        
//        subscribe(
//            store: store.strongStore(),
//            removeStateDuplicates: equating,
//            observe: observe
//        )
//    }
//}
