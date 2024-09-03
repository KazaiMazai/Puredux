//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26/08/2024.
//

import Dispatch
import Foundation

#if canImport(UIKit)
import UIKit

extension UIViewController: UIStateObserver { }

extension UIView: UIStateObserver { }

#endif

public protocol UIStateObserver: AnyObject { }

extension UIStateObserver {
    var cancellable: AnyCancellableEffect { AnyCancellableEffect(self) }
}

public extension UIStateObserver {
    /**
     Subscribes a `UIView` or `UIViewController` to a `Store`, allowing it to observe and react to changes in the store's state, while also having access to the store itself.

     This method integrates a `Store` with a `UIView` or `UIViewController` by observing state changes and deriving properties through the `props` closure. The view or view controller will update whenever the state changes, and it can utilize the provided store to perform further actions or access additional information.

     - Parameters:
        - store: A `Store` instance that manages the application's state and actions. It holds the state that the view or view controller will observe and provides functions for dispatching actions.
        - props: A closure that takes the current state and the `Store` itself, and returns a `Props` instance. This `Props` instance is used to update the view or view controller or trigger side effects. The `props` closure allows for deriving view-specific properties from the state and store.
        - presentationQueue: A `DispatchQueue` specifying where props evaluation should occur. The default value is `.sharedPresentationQueue`.  Must be a **serial queue**.
        - removeStateDuplicates: An optional `Equating` used to determine if duplicate states should be filtered out to avoid unnecessary updates. If provided, this closure compares the current state with the previous state to decide if the view or view controller should be updated. If `nil`, all state changes will trigger an update.
        - debounceFor: A `TimeInterval` that specifies the debounce duration for state changes. If multiple state changes occur within this interval, only the last change will trigger an update. This helps reduce the frequency of updates and improve performance by preventing redundant view updates. The default value is `.uiDebounce`.
        - observe: A closure that is called whenever the state changes. This closure is invoked with the updated `Props` instance and is used to update the view or view controller or perform side effects based on the new properties.

     - Returns:
        This method does not return a value. It subscribes the view or view controller to the `Store` and sets up the necessary logic to handle state changes and updates.

     Usage Example for `UIViewController`:
     
     ```swift
     class MyViewController: UIViewController {
         let store = AnyStore<AppState, Action>
         
         override func viewDidLoad() {
             super.viewDidLoad()
             
             subscribe(
                 store: store,
                 props: { state, store in
                     // Derive view state from the app state and store
                     ViewState(someValue: state.someValue, store: store)
                 },
                 presentationQueue: .main,
                 removeStateDuplicates: .keyPath(\.lastUpdated),
                 debounceFor: 0.016, // Debounce interval for props evaluations
                 observe: { [weak self] viewState in
                     // Handle updates with the derived props
                     self?.updateUI(with: viewState)
                 }
             )
         }
         
         private func updateUI(with viewState: ViewState) {
             // Update UI elements with the new view state
         }
     }
     ```
     */
    func subscribe<State, Action, Props>(store: any Store<State, Action>,
                                         props: @escaping (State, AnyStore<State, Action>) -> Props,
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
                    let props = props(state, store.eraseToAnyStore())
                    guard presentationQueue == DispatchQueue.main else {
                        DispatchQueue.main.async { observe(props) }
                        return
                    }
                    observe(props)
                }
            }
    }

    /**
     Subscribes a `UIView` or `UIViewController` to a `Store`, allowing it to observe and react to changes in the store's state, while also having access to the store's dispatch function.

     This method integrates a `Store` with a `UIView` or `UIViewController` by observing state changes and deriving properties through the `props` closure. The view or view controller will update whenever the state changes, and it can use the dispatch function provided by the store to perform actions.

     - Parameters:
        - store: A `Store` instance that manages the application's state and actions. It holds the state that the view or view controller will observe and provides functions for dispatching actions.
        - props: A closure that takes the current state and the store's dispatch function, and returns a `Props` instance. This `Props` instance is used to update the view or view controller or trigger side effects. The `props` closure allows for deriving view-specific properties from the state and store.
        - presentationQueue: A `DispatchQueue` specifying where props evaluation should occur. The default value is `.sharedPresentationQueue`.  Must be a **serial queue**.
        - removeStateDuplicates: An optional `Equating` used to determine if duplicate states should be filtered out to avoid unnecessary updates. If provided, this closure compares the current state with the previous state to decide if the view or view controller should be updated. If `nil`, all state changes will trigger an update.
        - debounceFor: A `TimeInterval` that specifies the debounce duration for state changes. If multiple state changes occur within this interval, only the last change will trigger an update. This helps reduce the frequency of updates and improve performance by preventing redundant view updates. The default value is `.uiDebounce`.
        - observe: A closure that is called whenever the state changes. This closure is invoked with the updated `Props` instance and is used to update the view or view controller or perform side effects based on the new properties.

     - Returns:
        This method does not return a value. It subscribes the view or view controller to the `Store` and sets up the necessary logic to handle state changes and updates.

     Usage Example for `UIViewController`:
     
     ```swift
     class MyViewController: UIViewController {
                
         let store = AnyStore<AppState, Action>()
         
         override func viewDidLoad() {
             super.viewDidLoad()
             
             subscribe(
                 store: store,
                 props: { state, dispatch in
                     // Derive props from the state and dispatch function
                     ViewState(someValue: state.someValue, dispatch: dispatch)
                 },
                 presentationQueue: DispatchQueue.yourCustomQueue, // offload heavy lifting in props evaluation to a separate queue
                 removeStateDuplicates: .keyPath(\.lastUpdated),
                 debounceFor: 0.016, // Debounce interval for props evaluation
                 observe: { [weak self] viewState in
                     // Handle updates with the derived props
                     self?.updateUI(with: viewState)
                 }
             )
         }
         
         private func updateUI(with viewState: ViewState) {
             // Update UI elements with the new props
         }
     }
     ```
    */
    func subscribe<State, Action, Props>(_ store: any Store<State, Action>,
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

    /**
     Subscribes a `UIView` or `UIViewController` to a `Store`, allowing it to observe and react to changes in the store's state directly.

     This method integrates a `Store` with a `UIView` or `UIViewController` by observing state changes. The view or view controller will update whenever the state changes, using the provided `observe` closure.

     - Parameters:
        - store: A `Store` instance that manages the application's state and actions. It holds the state that the view or view controller will observe.
        - removeStateDuplicates: An optional `Equating` used to determine if duplicate states should be filtered out to avoid unnecessary updates. If provided, this closure compares the current state with the previous state to decide if the view or view controller should be updated. If `nil`, all state changes will trigger an update.
        - debounceFor: A `TimeInterval` that specifies the debounce duration for state changes. If multiple state changes occur within this interval, only the last change will trigger an update. This helps reduce the frequency of updates and improve performance by preventing redundant view updates. The default value is `.uiDebounce`.
        - observe: A closure that is called whenever the state changes. This closure is invoked with the updated state and is used to update the view or view controller or perform side effects based on the new state.

     - Returns:
        This method does not return a value. It subscribes the view or view controller to the `Store` and sets up the necessary logic to handle state changes and updates.

     Usage Example for `UIViewController`:
     
     ```swift
     class MyViewController: UIViewController {
         let store = AnyStore<AppState, Action>
         
         override func viewDidLoad() {
             super.viewDidLoad()
             
             subscribe(
                 store: store,
                 removeStateDuplicates: .keyPath(\.lastUpdated),
                 debounceFor: 0.015, // Debounce interval for observe updates
                 observe: { [weak self] state in
                     // Handle updates with the new state
                     self?.updateUI(with: state)
                 }
             )
         }
         
         private func updateUI(with state: AppState) {
             // Update UI elements based on the new state
         }
     }
    ```
    */
    func subscribe<State, Action>(_ store: any Store<State, Action>,
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

    /**
     Subscribes a `UIView` or `UIViewController` to a `Store`, allowing it to observe and react to changes in the store's state, and providing access to the store's dispatch function.

     This method integrates a `Store` with a `UIView` or `UIViewController` by observing state changes and allowing the view or view controller to react to these changes while having access to the store's dispatch function. This setup is useful for directly updating the UI and dispatching actions in response to state changes.

     - Parameters:
        - store: A `Store` instance that manages the application's state and actions. It holds the state that the view or view controller will observe and provides functions for dispatching actions.
        - removeStateDuplicates: An optional `Equating` used to determine if duplicate states should be filtered out to avoid unnecessary updates. If provided, this closure compares the current state with the previous state to decide if the view or view controller should be updated. If `nil`, all state changes will trigger an update.
        - debounceFor: A `TimeInterval` specifying the debounce duration for state changes. If multiple state changes occur within this interval, only the last change will trigger an update. This helps reduce the frequency of updates and improve performance by preventing redundant view updates. The default value is `.uiDebounce`.
        - observe: A closure that is called whenever the state changes. This closure is invoked with the updated state and the store's dispatch function. It is used to update the view or view controller or perform side effects based on the new state and provides the dispatch function to dispatch actions if needed.

     - Returns:
        This method does not return a value. It subscribes the view or view controller to the `Store` and sets up the necessary logic to handle state changes and updates.

     Usage Example for `UIViewController`:
     
     ```swift
     class MyViewController: UIViewController {
         let store = AnyStore<AppState, Action>
         
         override func viewDidLoad() {
             super.viewDidLoad()
             
             subscribe(
                 store: store,
                 removeStateDuplicates: .keyPath(\.lastUpdated),
                 debounceFor: 0.015, // Debounce interval for UI updates
                 observe: { [weak self] state, dispatch in
                     // Handle updates with the new state and dispatch actions if needed
                     self?.updateUI(with: state, dispatch: dispatch)
                 }
             )
         }
         
         private func updateUI(with state: AppState, dispatch: @escaping Dispatch<Action>) {
             // Update UI elements based on the new state
         }
     }
    ```
    */
    func subscribe<State, Action>(_ store: any Store<State, Action>,
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

    /**
     Subscribes a `UIView` or `UIViewController` to a `Store`, allowing it to observe and react to changes in the store's state and interact with the store directly.

     This method integrates a `Store` with a `UIView` or `UIViewController` by observing state changes. The view or view controller will update whenever the state changes, and it can also use the provided store for additional interactions.

     - Parameters:
        - store: A `Store` instance that manages the application's state and actions. It holds the state that the view or view controller will observe and provides functions for dispatching actions.
        - removeStateDuplicates: An optional `Equating` used to determine if duplicate states should be filtered out to avoid unnecessary updates. If provided, this closure compares the current state with the previous state to decide if the view or view controller should be updated. If `nil`, all state changes will trigger an update.
        - debounceFor: A `TimeInterval` specifying the debounce duration for state changes. If multiple state changes occur within this interval, only the last change will trigger an update. This helps reduce the frequency of updates and improve performance by preventing redundant view updates. The default value is `.uiDebounce`.
        - observe: A closure that is called whenever the state changes. This closure is invoked with the updated state and the store itself. It is used to update the view or view controller or perform side effects based on the new state, and provides direct access to the store for additional interactions.

     - Returns:
        This method does not return a value. It subscribes the view or view controller to the `Store` and sets up the necessary logic to handle state changes and updates.

     Usage Example for `UIViewController`:
     
     ```swift
     class MyViewController: UIViewController {
         let store = AnyStore<AppState, Action>
         
         override func viewDidLoad() {
             super.viewDidLoad()
             
             subscribe(
                 store: store,
                 removeStateDuplicates: .keyPath(\.lastUpdated),
                 debounceFor: 0.015, // Debounce interval to throttle updates
                 observe: { [weak self] state, store in
                     // Handle updates with the new state and the store
                     self?.updateUI(with: state, store: store)
                 }
             )
         }
         
         private func updateUI(with state: AppState, store: AnyStore<AppState, Action>) {
             // Update UI elements based on the new state
         }
     }
    ```
    */
    func subscribe<State, Action>(store: any Store<State, Action>,
                                  removeStateDuplicates equating: Equating<State>? = nil,
                                  debounceFor timeInterval: TimeInterval = .uiDebounce,
                                  observe: @escaping (State, AnyStore<State, Action>) -> Void) {

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
