//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 31/08/2024.
//

import SwiftUI

/**
 A SwiftUI view that binds to a `Store` object to observe its state and dispatch actions.

 - Note: `StoreView` is intended to make the migration from `ViewWithStore` to Puredux 2.0 process easier.
    Otherwise consider using `view.subscribe(...)` API directly
 
 - Parameters:
   - ViewState: The type representing the state of the view.
   - Action: The type representing the actions that can be dispatched to modify the state.
   - Props: The type representing the properties derived from the state to be passed to the content view.
   - Content: A view builder that generates the content for the view based on the provided `Props`.
 
*/
public struct StoreView<ViewState, Action, Props, Content: View>: View {
    private let store: any StoreProtocol<ViewState, Action>
    private let props: (_ state: ViewState, _ store: Store<ViewState, Action>) -> Props
    private let content: (_ props: Props) -> Content
    private(set) var removeStateDuplicates: Equating<ViewState>?
    private(set) var presentationQueue: DispatchQueue = .sharedPresentationQueue

    @State private var currentProps: Props?

    public var body: some View {
        makeContent()
            .subscribe(
                store: store,
                props: props,
                presentationQueue: presentationQueue,
                removeStateDuplicates: removeStateDuplicates) {
                    currentProps = $0
                }
    }

    @ViewBuilder
    private func makeContent() -> some View {
        switch currentProps {
        case .none:
            Color.clear
        case .some(let value):
            content(value)
        }
    }
}

public extension StoreView {
    /**
     Returns a copy of the `StoreView` with a custom predicate for removing state duplicates.
     
     - Parameter equating: An `Equating` object that defines the predicate for determining if two states are considered duplicates.
     - Returns: A new instance of `StoreView` with the updated state duplication removal predicate.
    */
    func removeStateDuplicates(_ equating: Equating<ViewState>) -> Self {
        var selfCopy = self
        selfCopy.removeStateDuplicates = equating
        return selfCopy
    }

    /**
     Returns a copy of the `StoreView` configured to use a specific `DispatchQueue` for state presentation updates.
     
     - Parameter queue: A `DispatchQueue` on which state updates should be presented.
     - Returns: A new instance of `StoreView` with the updated presentation queue.
     - Note: `DispatchQueue` cannot be concurrent. Only serial queue is supported
    */
    func usePresentationQueue(_ queue: DispatchQueue) -> Self {
        var selfCopy = self
        selfCopy.presentationQueue = queue
        return selfCopy
    }
}

public extension StoreView {
    /**
     Initializes a `StoreView` with a store that conforms to `StoreProtocol`, and provides closures for deriving properties and content.
     
     - Parameters:
       - store: An instance of `StoreProtocol` that conforms to `ViewState` and `Action`. The store is converted to a `Store` using `getStore()`.
       - props: A closure that takes the current state and store, and returns the properties for the content view.
       - content: A closure that takes the derived properties and returns the SwiftUI view to display.
    */
    init(store: any StoreProtocol<ViewState, Action>,
         props: @escaping (ViewState, Store<ViewState, Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.store = store.eraseToAnyStore()
        self.props = props
        self.content = content
    }

    /**
     Initializes a `StoreView` with a store that conforms to `StoreProtocol`, and provides closures for deriving properties and content, where the store dispatch function is directly accessible.
         
     - Parameters:
        - store: An instance of `StoreProtocol` that conforms to `ViewState` and `Action`. The store is converted to a `Store` using `getStore()`.
        - props: A closure that takes the current state and a dispatch function, and returns the properties for the content view.
        - content: A closure that takes the derived properties and returns the SwiftUI view to display.
    */
    init(_ store: any StoreProtocol<ViewState, Action>,
         props: @escaping (ViewState, @escaping Dispatch<Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.store = store.eraseToAnyStore()
        self.props = { state, store in props(state, store.dispatch) }
        self.content = content
    }
}

public extension StoreView where Props == (ViewState, Store<ViewState, Action>) {
    /**
     Initializes a `StoreView` where `Props` is a tuple of `(ViewState, Store<ViewState, Action>)`.
     
    - Parameters:
        - store: An instance of `StoreProtocol` that conforms to `ViewState` and `Action`.
        - content: A closure that takes a tuple containing the current state and the store, and returns the SwiftUI view to display.
    */
    init(store: any StoreProtocol<ViewState, Action>,
         content: @escaping (Props) -> Content) {
        self.store = store
        self.props = { state, store in (state, store) }
        self.content = content
    }
}

public extension StoreView where Props == (ViewState, Store<ViewState, Action>) {
    /**
     Initializes a `StoreView` where `Props` is a tuple of `(ViewState, Store<ViewState, Action>)`, with a content closure that uses a dispatch function.
         
    - Parameters:
        - store: An instance of `StoreProtocol` that conforms to `ViewState` and `Action`.
        - content: A closure that takes the current state and a dispatch function, and returns the SwiftUI view to display.
    */
    init(_ store: any StoreProtocol<ViewState, Action>,
         content: @escaping (ViewState, @escaping Dispatch<Action>) -> Content) {
        self.store = store
        self.props = { state, store in (state, store) }
        self.content = { props in content(props.0, props.1.dispatch) }
    }
}
