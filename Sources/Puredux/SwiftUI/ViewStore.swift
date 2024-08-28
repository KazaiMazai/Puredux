//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 28/08/2024.
//

import SwiftUI

/**
    A property wrapper that encapsulates a store object, providing a way to manage its lifecycle and
    access its value through a read-only `wrappedValue` property.

    The `ViewStore` property wrapper is designed to work with both `Store` and `StateStore` types, allowing these
    stores to be easily managed within SwiftUI views.
     
    By using `ViewStore`, you can integrate state management into your SwiftUI views, ensuring that state changes and side effects
    are properly handled and observed.
 
    In the example, ViewStore is used to wrap a StateStore instance:
 
    ```swift
    struct MyView: View {
        @State @ViewStore private var store = { cancellable in
            StateStore<ViewState, Action>(ViewState()) { state, dispatch in
                // ...
            }
            .onChangeEffect(cancellable) { state, dispatch in
                Effect {
                    // ...
                }
            }
        }

        @State var viewState: ViewState?

        var body: some View {
            Button(viewState?.title ?? "") {
                store.dispatch(.buttonTapped)
            }
            .subscribe(store) { viewState = $0 }
        }
    }
    ```
    
    While `ViewState` and `Action` can be defined as:
     
     ```swift
      
    extension MyView {
         
        struct ViewState: Equatable {
            // ...
        }
         
        enum Action {
            // ...
        }
    }
    ```
     
    The store is initialized with an initial state and a reducer that defines how the state changes in response to actions.
    The `onChangeEffect(...)` method is used to manage side effects based on state changes, using the provided `AnyCancellableEffect`.
     

    The `ViewStore` property wrapper can be used with both `Store` and `StateStore` types, allowing them to be
    easily managed within a view or other contexts that support property wrappers.

    - Parameters:
        - Value: The type of the store being wrapped, which can be either `Store` or `StateStore`.
*/
@propertyWrapper
struct ViewStore<Value> {
    /**
    A property that holds an instance of `AnyCancellableEffect`, which is used to manage subscriptions
    and effects associated with the store.
    */
    private let cancellable = AnyCancellableEffect()
    
    /**
     The store object being wrapped. This property is read-only to ensure
     encapsulation and controlled access.
    */
    private let store: Value
    
    /**
     The property that provides read-only access to the wrapped store object.
     
     - Returns: The current store instance.
     */
    var wrappedValue: Value { store }
}

extension ViewStore {
    /**
     Initializes a new `ViewStore` with a `Store` object. This initializer allows the creation of a `ViewStore`
     by providing a closure that takes an `AnyCancellableEffect` and returns a `Store` instance.
     
     - Parameters:
       - wrappedValue: A closure that takes an `AnyCancellableEffect` and returns a `Store` instance.
     
     - Note: This initializer is used when the type `Value` is `Store<S, A>`.
     */
    init<S, A>(wrappedValue: @escaping (AnyCancellableEffect) -> Value) where Value == Store<S, A> {
        self.store = wrappedValue(cancellable)
    }
    
    /**
     Initializes a new `ViewStore` with a `StateStore` object. This initializer allows the creation of a `ViewStore`
     by providing a closure that takes an `AnyCancellableEffect` and returns a `StateStore` instance.
     
     - Parameters:
       - wrappedValue: A closure that takes an `AnyCancellableEffect` and returns a `StateStore` instance.
     
     - Note: This initializer is used when the type `Value` is `StateStore<S, A>`.
     */
    
    init<S, A>(wrappedValue: @escaping (AnyCancellableEffect) -> Value) where Value == StateStore<S, A> {
        self.store = wrappedValue(cancellable)
    }
}

/**
 An extension for the `State` type that provides initializers to create a `State` instance with a wrapped store object.
 
 This extension includes two initializers, each tailored for different store types (`Store` and `StateStore`), allowing
 easy integration with the `ViewStore` property wrapper.
 */
extension State {
    /**
     Initializes a new `State` instance with a `ViewStore` wrapping a `Store` object.
     
     This initializer allows the creation of a `State` object by providing a closure that takes an `AnyCancellableEffect`
     and returns a `Store` instance. The `Store` is then wrapped in a `ViewStore` and passed as the initial value for `State`.
     
     Can be especially handy when used in initializers:
     
     ```swift
     extension MyView {
        init() {
            self._store = State { cancellable in
                StateStore<ViewState, Action>(ViewState()) { state, dispatch in
                     // ...
                }
                .onChangeEffect(cancellable) { state, dispatch in
                    Effect {
                         // ...
                     }
                 }
        }
     }
     ```

     - Parameters:
       - wrappedValue: A closure that takes an `AnyCancellableEffect` and returns a `Store` instance.

     - Note: This initializer is used when the `Value` type of `State` is `ViewStore<Store<S, A>>`.
    */
    init<S, A>(wrappedValue: @escaping (AnyCancellableEffect) -> Store<S, A>) where Value == ViewStore<Store<S, A>> {
        self.init(initialValue: ViewStore(wrappedValue: wrappedValue))
    }
    
    /**
    Initializes a new `State` instance with a `ViewStore` wrapping a `StateStore` object.
    
    This initializer allows the creation of a `State` object by providing a closure that takes an `AnyCancellableEffect`
    and returns a `StateStore` instance. The `StateStore` is then wrapped in a `ViewStore` and passed as the initial value for `State`.

    - Parameters:
      - wrappedValue: A closure that takes an `AnyCancellableEffect` and returns a `StateStore` instance.

    - Note: This initializer is used when the `Value` type of `State` is `ViewStore<StateStore<S, A>>`.
    */
    init<S, A>(wrappedValue: @escaping (AnyCancellableEffect) -> StateStore<S, A>) where Value == ViewStore<StateStore<S, A>> {
        self.init(initialValue: ViewStore(wrappedValue: wrappedValue))
    }
}

