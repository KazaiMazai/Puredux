//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import Dispatch
import Foundation

/**
 A protocol that defines a presenter which subscribes to a store.
*/
public protocol PresenterProtocol {
    /**
    Subscribes the presenter to a store.
    */
    func subscribeToStore()
}

/**
 A protocol that defines a presentable UI component that observes state changes and can update its properties accordingly.
*/
public protocol Presentable: UIStateObserver {
    /**
     The type of properties that the presentable will use to update its UI.
    */
    associatedtype Props

    /**
     The presenter associated with the presentable that owns the state and handles state subscriptions.
    */
    @MainActor
    var presenter: PresenterProtocol? { get set }

    /**
     Sets the properties of the presentable component.

     - Parameter props: The properties to be set for the UI component.
     */
    @MainActor
    func setProps(_ props: Props)
}

public extension Presentable {
    /**
     Binds a presentable `UIView` or `UIViewController` to a store, allowing it to observe state changes and update its properties accordingly. This method is particularly suitable for the Model-View-Presenter (MVP) architecture design pattern.
     
     In the MVP architecture design pattern, the **View** (e.g., `UIView` or `UIViewController`) is responsible for displaying data and forwarding user interactions to the **Presenter**. The **Presenter** acts as an intermediary between the **View** and the **Model** (represented here by the `Store`). It subscribes to changes and updates the **View** accordingly.
     
     This method facilitates this interaction by binding the **View** to the **Store** through a **Presenter**, ensuring that the view is automatically updated when the state changes.

     - Parameters:
        - store: The store that holds the state and actions the presentable is interested in.
        - props: A closure that maps the state and store to the properties needed by the presentable.
        - presentationQueue: The dispatch queue on which the props will be evaluated. Defaults to `DispatchQueue.sharedPresentationQueue`. Must be **Serial DispatchQueue**
        - equating: An optional `Equating` that determines whether the state has changed to avoid redundant updates. Defaults to `nil`.
        - debounceFor: A time interval for debouncing rapid state changes. Defaults to `.uiDebounce`.

     Usage Example for `UIViewController`:

     ```swift
     class MyViewController: UIViewController, Presentable {
        var presenter: PresenterProtocol?

        override func viewDidLoad() {
            super.viewDidLoad()
            presenter.subscribeToStore()
        }

        func setProps(_ props: ViewState) {
            // Update UI elements with the new view state
        }
     }

    // Usage:

    let myViewController = MyViewController()
    let store = StateStore<AppState, Action>(...)

    myViewController.setPresenter(
         store: store,
         props: { state, store in
             // Derive view state from the app state and store
             ViewState(someValue: state.someValue, store: store)
         },
         presentationQueue: .sharedPresentationQueue,
         removeStateDuplicates: .keyPath(\.lastUpdated),
         debounceFor: 0.016
     )

     navigationController?.pushViewController(myViewController, animated: true)

     ```
    */
    @MainActor
    func setPresenter<State, Action>(store: any Store<State, Action>,
                                     props: @Sendable @escaping (State, AnyStore<State, Action>) -> Self.Props,
                                     presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                     removeStateDuplicates equating: Equating<State>? = nil,
                                     debounceFor timeInterval: TimeInterval = .uiDebounce) where State: Sendable,
                                                                                                 Action: Sendable,
                                                                                                 Props: Sendable {

        presenter = Presenter { [weak self] in
            guard let self else { return }
            subscribe(
                store: store,
                props: props,
                presentationQueue: presentationQueue,
                removeStateDuplicates: equating,
                debounceFor: timeInterval) { [weak self] props in
                    self?.setProps(props)
            }
        }
    }

    /**
     Binds the presentable to a store, allowing it to observe state changes and update its properties accordingly.
     
     - Parameters:
        - store: The store that holds the state and actions the presentable is interested in.
        - props: A closure that maps the state and dispatch closure to the properties needed by the presentable.
        - presentationQueue: The dispatch queue on which the props will be evaluated on. Defaults to `DispatchQueue.sharedPresentationQueue`. Must be **Serial DispatchQueue**
        - equating: An optional `Equating` that determines whether the state has changed to avoid redundant updates. Defaults to `nil`.
    */
    @MainActor
    func setPresenter<State, Action>(_ store: any Store<State, Action>,
                                     props: @Sendable @escaping (State, Dispatch<Action>) -> Self.Props,
                                     presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                     removeStateDuplicates equating: Equating<State>? = nil,
                                     debounceFor timeInterval: TimeInterval = .uiDebounce) where State: Sendable,
                                                                                                 Action: Sendable,
                                                                                                 Props: Sendable {

        presenter = Presenter { [weak self] in
            guard let self else { return }
            subscribe(
                store: store,
                props: { state, store in props(state, store.dispatch) },
                presentationQueue: presentationQueue,
                removeStateDuplicates: equating,
                debounceFor: timeInterval) { [weak self] props in
                    self?.setProps(props)
            }
        }
    }
}

private struct Presenter: PresenterProtocol {
    let subscribe: () -> Void

    func subscribeToStore() {
        subscribe()
    }
}
