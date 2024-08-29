//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import Dispatch

public protocol PresenterProtocol {
    func subscribeToStore()
}

public protocol Presentable: UIStateObserver {
    associatedtype Props

    var presenter: PresenterProtocol? { get set }

    func setProps(_ props: Props)
}

public extension Presentable {
    
    func with<State, Action>(_ store: StateStore<State, Action>,
                             props: @escaping (State, Store<State, Action>) -> Self.Props,
                             presentationQueue: DispatchQueue = .sharedPresentationQueue,
                             removeStateDuplicates equating: Equating<State>? = nil) {

        with(store.strongStore(),
             props: props,
             presentationQueue: presentationQueue,
             removeStateDuplicates: equating)
    }
    
    func with<State, Action>(_ store: Store<State, Action>,
                             props: @escaping (State, Store<State, Action>) -> Self.Props,
                             presentationQueue: DispatchQueue = .sharedPresentationQueue,
                             removeStateDuplicates equating: Equating<State>? = nil) {
        
        presenter = Presenter { [weak self] in
            guard let self else { return }
            subscribe(
                store: store,
                props: props,
                presentationQueue: presentationQueue,
                removeStateDuplicates: equating) { [weak self] props in
                    self?.setProps(props)
            }
        }
    }
}

public extension Presentable {
    
    @available(*, deprecated, renamed: "with(_:props:presentationQueue:removeStateDuplicates:)", message: "Will be removed in 2.0")
    func with<State, Action>(store: StateStore<State, Action>,
                             props: @escaping (State, Store<State, Action>) -> Self.Props,
                             presentationQueue: PresentationQueue = .sharedPresentationQueue,
                             removeStateDuplicates equating: Equating<State>? = nil) {
        
        with(store.strongStore(),
             props: props,
             presentationQueue: presentationQueue.dispatchQueue,
             removeStateDuplicates: equating)
    }
    
    @available(*, deprecated, renamed: "with(_:props:presentationQueue:removeStateDuplicates:)", message: "Will be removed in 2.0")
    func with<State, Action>(store: Store<State, Action>,
                             props: @escaping (State, Store<State, Action>) -> Self.Props,
                             presentationQueue: PresentationQueue = .sharedPresentationQueue,
                             removeStateDuplicates equating: Equating<State>? = nil) {
        
        with(store,
             props: props,
             presentationQueue: presentationQueue.dispatchQueue,
             removeStateDuplicates: equating)
    }
}

struct Presenter: PresenterProtocol {
    let subscribe: () -> Void

    func subscribeToStore() {
        subscribe()
    }
}
