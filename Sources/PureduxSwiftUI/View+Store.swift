//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 30.11.2021.
//

import SwiftUI
import PureduxCommon

public enum PresentationQueue {
   case sharedPresentationQueue
   case main
   case serialQueue(DispatchQueue)

   var dispatchQueue: DispatchQueue? {
       switch self {
       case .main:
           return DispatchQueue.main
       case .serialQueue(let queue):
           return queue
       case .sharedPresentationQueue:
           return nil
       }
   }
}

extension View {
    
    /**
    Initializes a View with `ContentView` connected  to the implicitly provided`RootEnvStore`.

    - Parameter removeStateDuplicates: allows to deduplicate state chages and evalutate `Props` when necessary
    - Parameter props: defines how `Props` are created from the state.
    - Parameter queue: defines on which presentation queue `Props` are evaluated
    - Parameter content: defines how `ContentView` is created from props.

    - Returns: `View` connected to RootEnvStore as defined

     Every time we dispatch an aciton to the store, it triggers view update cycle.
     `Props` are re-evalutated according to state deduplication rules.
     `Content` is re-rendered when props change.

     **Important to note:**  Before connecting Views, RootEnvStore should be injected in the view hierarchy as an `environmentObject`.
     This can be done via `StoreProvidingView`:

     ```
     let appState = AppState()
     let rootStore = RootStore<AppState, Action>(initialState: appState, reducer: reducer)
     let rootEnvStore = RootEnvStore(rootStore: rootStore)

     UIHostingController(
         rootView: StoreProvidingView(rootStore: rootEnvStore) {
             FancyView.withEnvStore(
                 props: presenter.makeProps,
                 content: { FancyView(props: $0) }
             )
         }
     )

     ```
     */

    public static func withEnvStore<AppState, Action, Props>(
        removeStateDuplicates by: Equating<AppState> = .neverEqual,
        props: @escaping (AppState, PublishingStore<AppState, Action>) -> Props,
        queue: PresentationQueue = .sharedPresentationQueue,
        content: @escaping (Props) -> Self) -> some View {

        EnvironmentStorePresentingView<AppState, Action, Props, Self>(
            props: props,
            content: content,
            removeDuplicates: by.predicate,
            queue: queue)
    }

    /**
    Initializes a View with `ContentView` connected  to the `PublishingStore`.

    - Parameter removeStateDuplicates: allows to deduplicate state chages and evalutate `Props` when necessary
    - Parameter props: closure describing how `Props` are created from the state.
    - Parameter queue: defines on which presentation queue `Props` are evaluated
    - Parameter content: closure defines how `ContentView` is created from props.

    - Returns: `View` connected to the provided `PublishingStore` as defined

     Every time we dispatch an aciton to the store, it triggers view update cycle.
     `Props` are re-evalutated according to state deduplication rules.
     `Content` is re-rendered when props change.

     ```
     let appState = AppState()
     let rootStore = RootStore<AppState, Action>(initialState: appState, reducer: reducer)
     let rootEnvStore = RootEnvStore(rootStore: rootStore)
     let fancyFeatureStore = rootEnvStore.store().proxy { $0.yourFancyFeatureSubstate }

     let presenter = FancyViewPresenter()

     UIHostingController(
         rootView: FancyView.with(
             store: fancyFeatureStore,
             props: presenter.makeProps,
             content: { FancyView(props: $0) }
         )
     )

     ```
     */
    public static func with<AppState, Action, Props>(
        store: PublishingStore<AppState, Action>,
        removeStateDuplicates by: Equating<AppState> = .neverEqual,
        props: @escaping (AppState, PublishingStore<AppState, Action>) -> Props,
        queue: PresentationQueue = .sharedPresentationQueue,
        content: @escaping (Props) -> Self) -> some View {

        StorePresentingView(
            store: store,
            props: props,
            content: content,
            removeDuplicates: by.predicate,
            queue: queue)
    }
}
