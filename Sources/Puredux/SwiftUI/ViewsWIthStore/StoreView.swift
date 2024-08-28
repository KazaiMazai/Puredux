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
            .withObserver { observer in
            
                observer.subscribe(
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
    
    var cancellables = Set<CancellableEffect>()
    let store = StoreOf(\.root)
        .with(true) { _, _ in }
        .map { $0.1 }
        .toggleEffect(&cancellables) { state, dispatch in
            Effect { print(state) }
        }
    
    store.dispatch(true)
}

typealias SomeViewStore = Store<(intValue: Int, boolValue: Bool), Bool>
//
//extension Store {
//    
//    static func someViewStore(_ cancellables: inout Set<CancellableEffect>) -> SomeViewStore {
//        
//        StoreOf(\.root)
//            .with(true) { _, _   in }
//            .map { (intValue: $0.0, boolValue: $0.1) }
//            .effect(&cancellables, toggle: \.boolValue) { state, _ in
//                Effect { print(state) }
//            }
//    }
//}

@propertyWrapper
struct ViewStore<T> {
    private var cancellable = CancellableEffect()
    private(set) var store: T
    
    var wrappedValue: T {
        get { store }
        set { store = newValue }
    }
}

extension ViewStore {
    init<S, A>(wrappedValue: @escaping (CancellableEffect) -> T) where T == Store<S, A> {
        self.store = wrappedValue(cancellable)
    }
    
    init<S, A>(wrappedValue: @escaping (CancellableEffect) -> T) where T == StateStore<S, A> {
        self.store = wrappedValue(cancellable)
    }
}

typealias ViewStateStore<T> = State<ViewStore<T>>

extension State  {
    init<S, A>(wrappedValue: @escaping (CancellableEffect) -> StateStore<S, A>)
    where
    Value == ViewStore<StateStore<S, A>> {
        
        self.init(wrappedValue: ViewStore(wrappedValue: wrappedValue))
    }
    
    init<S, A>(wrappedValue: @escaping (CancellableEffect) -> Store<S, A>)
    where
    Value == ViewStore<Store<S, A>> {
        
        self.init(wrappedValue: ViewStore(wrappedValue: wrappedValue))
    }
}

struct SomeViewBinding<Action, Content: View>: View {
//    init(boolValue: Bool) {
//         
//        _store = State(
//            initialValue: ViewStore { cancellable in
//                
//                StoreOf(\.root)
//                    .store()
//                    .with(boolValue) { _, _   in }
//                    .map { (intValue: $0.0, boolValue: $0.1) }
//                    .effect(cancellable,
//                            toggle: \.boolValue) { state, dispatch in
//                        
//                        Effect {
//                            dispatch(true)
//                        }
//                    }
//            }
//        )
//    }
    
    
    @State @ViewStore var store = { cancellable in
        
        StoreOf(\.root)
            .with(true) { _, _   in }
            .map { (intValue: $0.0, boolValue: $0.1) }
            .effect(cancellable,
                    toggle: \.boolValue) { state, dispatch in
                
                Effect {
                    dispatch(true)
                }
            }
    }
    
    @State private var viewState: Bool?
 
    var body: some View {
        Text("\(viewState ?? false)")
            .subscribe(store) {
                viewState = $0.1
            }
            .onAppear { store.dispatch(true) }
    }
}
 
