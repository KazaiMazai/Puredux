//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 21/08/2024.
//

import SwiftUI
import Dispatch
import Combine

public struct StoreView<ViewState, Action, Props, Content: View>: View {
    let store: Store<ViewState, Action>
    let props: (ViewState, @escaping Dispatch<Action>) -> Props
    let content: (_ props: Props) -> Content
    
    private(set) var removeStateDuplicates: Equating<ViewState>?
    private(set) var presentationQueue: DispatchQueue = .sharedPresentationQueue
    
    @State private var currentProps: Props?

    public var body: some View {
        makeContent()
            .effect(store) { uiStateObserver, store in
            
                uiStateObserver.subscribe(
                    store,
                    props: props,
                    presentationQueue: presentationQueue,
                    removeStateDuplicates: removeStateDuplicates,
                    observe: { props in currentProps = props  }
                )
        }
    }
}


extension StoreView {
    @ViewBuilder
    func makeContent() -> some View {
        if let props = currentProps {
            content(props)
        } else {
            Color.clear
        }
    }
}


public extension StoreView {
     
    func removeStateDuplicates(_ equating: Equating<ViewState>) -> Self {
        var selfCopy = self
        selfCopy.removeStateDuplicates = equating
        return selfCopy
    }
 
    func usePresentationQueue(_ queue: PresentationQueue) -> Self {
        var selfCopy = self
        selfCopy.presentationQueue = queue.dispatchQueue
        return selfCopy
    }
}


public extension StoreView {
    init(_ store: Store<ViewState, Action>,
         props: @escaping (ViewState, @escaping Dispatch<Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.store = store
        self.props = props
        self.content = content
    }
}

public extension StoreView where Props == (ViewState, Dispatch<Action>)  {
     
    init(_ store: Store<ViewState, Action>,
         content: @escaping (Props) -> Content) {
        self.store = store
        self.props = { state, store in (state, store) }
        self.content = content
    }
}

extension Injected {
    @InjectEntry var root = StateStore<Int, Bool>(10) {_, _ in }
    
}
 
final class SharedSomething: ObservableObject {
    func foo() -> Int {
        1
    }
}

func foo() {
    let store = StoreOf(\.root)
       .with(true) { _, _ in }
       .map { $0.1 }
    
    store.effect(\.self) { state in
        Effect { print(state) }
    }
    
    store.dispatch(true)
}

struct SomeStoreView<Action, Content: View>: View {
    @EnvironmentObject var env: SharedSomething
    
    @State var store = StoreOf(\.root)
        .with(true) { _, _   in }
        .with(.running(maxAttempts: 10)) {_,_ in }
        .effect(\.1) { state in
            Effect { print(state) }
        }
        .flatMap()
        .map { $0.1}
        

    @State private var currentProps: Bool?

    var body: some View {
        Text("\(currentProps ?? false)")
            .subscribe(store,
                       props: { state, dispatch in state }) {
                
                store.dispatch(true)
                currentProps = $0
            }
            .onAppear { store.dispatch(true) }
    }

}
 
