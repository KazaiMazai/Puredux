//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 27/08/2024.
//

import SwiftUI

 extension View {
     /**
      Attaches a state observer to the view, allowing it to respond to changes in the `Store`'s state and update itself accordingly.

      This method is used to create a connection between a `Store` and a `View` by subscribing the view to changes in the store. The view will be able to react to changes in the state and update itself based on the provided `props` and `observe` closure.

      - Parameters:
         - store: A `Store` instance that holds the state and dispatches actions.
         - props: A closure that maps the store's `State` and the `Store` itself to a `Props` instance. This `Props` instance will be passed to the `observe` closure whenever the state changes.
         - presentationQueue: A `DispatchQueue` that determines the queue on which props will be evaluabted. Defaults to `.sharedPresentationQueue`.
         - removeStateDuplicates: An optional `Equating` that determines if duplicate states should be filtered out to avoid unnecessary updates. This is used to compare the current state with the previous one to decide if the view needs to be updated.
         - observe: A closure that will be called with the `Props` instance whenever the state changes. This closure is used to update the view or based on the new `Props`.

      - Returns:
         A `View` that subscribes to the given `Store`. This view will automatically update when the `Store`'s state changes and the `observe` closure will be invoked with the updated `Props`.

      Usage Example:
      
      ```swift
      struct MyView: View {
        let store: Store<AppState, Action>
          
        @State var viewState: ViewState? = nil

        var body: some View {
            ContentView(viewState)
                .subscribe(
                    store: store,
                    props: { state, store in
                        // Create `ViewState` based on the state and store
                        ViewState(text: state.someText)
                    },
                    observe: {
                        props = $0
                    }
              )
        }
      }
      ```
    */
    func subscribe<State, Action, Props>(store: Store<State, Action>,
                                         props: @escaping (State, Store<State, Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         observe: @escaping (Props) -> Void) -> some View {
        withObserver { observer in
            observer.subscribe(
                store: store,
                props: props,
                presentationQueue: presentationQueue,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
    
     /**
      Attaches a state observer to the view, enabling it to react to changes in the `Store`'s state and update accordingly.

      This method integrates a `Store` with a `View` by subscribing to state changes. It allows the view to update based on the current state of the store, using a mapping function to derive properties and a closure to handle those properties.

      - Parameters:
         - store: A `Store` instance managing the application's state and dispatching actions.
         - props: A closure that converts the `State` and a `Dispatch` function into a `Props` instance. The `Dispatch` function is used to dispatch actions to the store. This `Props` object is used in the `observe` closure to update the view.
         - presentationQueue: A `DispatchQueue` specifying where view updates should occur. The default value is `.sharedPresentationQueue`.
         - removeStateDuplicates: An optional `Equating` that determines if duplicate states should be filtered to prevent redundant updates. This helps to avoid unnecessary view updates by comparing the current state with the previous state.
         - observe: A closure is performed when the state changes. This closure is invoked whenever the state updates and is used to update the view or trigger side effects.

      - Returns:
         A `View` that subscribes to the specified `Store`. This view will automatically update in response to state changes, and the `observe` closure will be called with the updated `Props`.
    */
    func subscribe<State, Action, Props>(_ store: Store<State, Action>,
                                         props: @escaping (State, @escaping Dispatch<Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         observe: @escaping (Props) -> Void) -> some View {
        withObserver { observer in
            observer.subscribe(
                store,
                props: props,
                presentationQueue: presentationQueue,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
    
     /**
      Subscribes a view to a `Store`, allowing it to observe and react to changes in the store's state.

      This method binds a `View` to a `Store` by subscribing it to state changes. It allows the view to update whenever the state in the store changes by directly observing the state.

      - Parameters:
         - store: A `Store` instance that manages the application's state and actions. It holds the state that the view will observe.
         - removeStateDuplicates: An optional `Equating` used to determine if duplicate states should be filtered out to avoid unnecessary updates. If provided, it compares the current state with the previous state to decide if the view should be updated. If `nil`, all state changes trigger an update.
         - observe: A closure that takes the current state and performs actions whenever the state changes. This closure is invoked whenever the state updates and is used to update the view or perform side effects based on the new state.

      - Returns:
         A `View` that subscribes to the specified `Store`. The view automatically updates in response to state changes, and the `observe` closure is called with the updated state.

      Usage Example:
      ```swift
      struct MyView: View {
        let store: Store<ViewState, Action>
            
        @State viewState: ViewState?
      
        var body: some View {
            ContentView(viewState)
                .subscribe(
                    store: store,
                    removeStateDuplicates: .keyPath(\.lastModified),
                    observe: {
                        viewState = $0
                    }
                )
        }
     }
     ```
    */
    func subscribe<State, Action>(_ store: Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State) -> Void) -> some View {
        withObserver { observer in
            observer.subscribe(
                store,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
     
    /**
     Subscribes a view to a `Store`, allowing it to observe and react to changes in the store's state, while also providing the ability to dispatch actions.

     This method binds a `View` to a `Store` by subscribing it to state changes. The view will update whenever the state in the store changes, and it can also dispatch actions using the provided `Dispatch` function.

     - Parameters:
         - store: A `Store` instance that manages the application's state and actions. It holds the state that the view will observe and the dispatch function for dispatching actions.
         - removeStateDuplicates: An optional `Equating` used to determine if duplicate states should be filtered out to avoid unnecessary updates. If provided, this closure compares the current state with the previous state to decide if the view should be updated. If `nil`, all state changes trigger an update.
         - observe: A closure that takes the current state and a `Dispatch` function, performing actions whenever the state changes. This closure is invoked on each state update and is used to update the view or perform side effects based on the new state. The `Dispatch` function allows for actions to be dispatched in response to state changes.

     - Returns:
        A `View` that subscribes to the specified `Store`. The view automatically updates in response to state changes, and the `observe` closure is called with the updated state and dispatch function.

     Usage Example:
      
     ```swift
     struct ContentView: View {
        let store = Store<AppState, Action>
        
        @State var viewState: ViewState?
     
        var body: some View {
            ContentView(viewState)
                .subscribe(
                    store: store,
                    removeStateDuplicates: keyPath(\.lastModified),
                    observe: { state, dispatch in
                        viewState = ViewState(state, dispatch)
                    }
                )
          }
      }
     ```
    */
    func subscribe<State, Action>(_ store: Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State, Dispatch<Action>) -> Void) -> some View {
        
        withObserver { observer in
            observer.subscribe(
                store,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
     /**
      Subscribes a view to a `Store`, allowing it to observe and react to changes in the store's state, while also having access to the store itself.

      This method binds a `View` to a `Store` by subscribing it to state changes. The view will update whenever the state in the store changes, and it can use the provided store to perform further actions or access its properties.

      - Parameters:
         - store: A `Store` instance that manages the application's state and actions. The store holds the state that the view will observe and provides functions for dispatching actions.
         - removeStateDuplicates: An optional `Equating` closure used to determine if duplicate states should be filtered out to avoid unnecessary updates. If provided, this closure compares the current state with the previous state to decide if the view should be updated. If `nil`, all state changes will trigger an update.
         - observe: A closure that takes the current state and the `Store` itself, performing actions whenever the state changes. This closure is invoked on each state update and is used to update the view or perform side effects based on the new state. It provides access to the store for additional interactions.

      - Returns:
         A `View` that subscribes to the specified `Store`. The view automatically updates in response to state changes, and the `observe` closure is called with the updated state and the store.

      Usage Example:
      ```swift
      struct ContentView: View {
        let store = Store<AppState, Action>
        
        @State var viewState: ViewState?
        
        var body: some View {
            ContentView(viewState)
                .subscribe(
                    store: store,
                    removeStateDuplicates: .keyPath(\.lastModified),
                    observe: { state, store in
                        viewState = ViewState(state, store)
                    }
                )
        }
      }
      ```
    */
    func subscribe<State, Action>(store: Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State, Store<State, Action>) -> Void) -> some View {
        
        withObserver { observer in
            observer.subscribe(
                store: store,
                removeStateDuplicates: equating,
                observe: observe
            )
        }
    }
}

 extension View {
    func subscribe<State, Action, Props>(store: StateStore<State, Action>,
                                         props: @escaping (State, Store<State, Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         observe: @escaping (Props) -> Void) -> some View {
        subscribe(
            store: store.strongStore(),
            props: props,
            presentationQueue: presentationQueue,
            removeStateDuplicates: equating,
            observe: observe
        )
    }
    
    func subscribe<State, Action, Props>(_ store: StateStore<State, Action>,
                                         props: @escaping (State, @escaping Dispatch<Action>) -> Props,
                                         presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                         removeStateDuplicates equating: Equating<State>? = nil,
                                         observe: @escaping (Props) -> Void) -> some View {
        subscribe(
            store.strongStore(),
            props: props,
            presentationQueue: presentationQueue,
            removeStateDuplicates: equating,
            observe: observe
        )
    }
    
    func subscribe<State, Action>(_ store: StateStore<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State) -> Void) -> some View {
        subscribe(
            store.strongStore(),
            removeStateDuplicates: equating,
            observe: observe
        )
    }
    
    func subscribe<State, Action>(_ store: StateStore<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State, Dispatch<Action>) -> Void) -> some View {
        
        subscribe(
            store.strongStore(),
            removeStateDuplicates: equating,
            observe: observe
        )
    }
    
    func subscribe<State, Action>(store: StateStore<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  observe: @escaping (State, Store<State, Action>) -> Void) -> some View {
        
        subscribe(
            store: store.strongStore(),
            removeStateDuplicates: equating,
            observe: observe
        )
    }
}
