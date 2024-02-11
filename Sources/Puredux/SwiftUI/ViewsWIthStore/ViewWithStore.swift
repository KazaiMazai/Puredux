//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 09.03.2023.
//

import SwiftUI



/// ViewWithStore connects its `ContentView`  to the store.
///
/// Every time we dispatch an action to the store, it triggers view update cycle.
/// `Props` are re-evalutated according to state deduplication rules.
/// `Content` is re-rendered when props change.
///
/// **Props Evaluation**
///
///  The typical flow is:
///
///  `State` -> `Props` -> `Content`.
///
///  It allows to optimize the `Props` evaluation by hoping to a global queue.
///
///  However, `Props` is an extra layer which is not required and can be skipped.
///  Making the flow more simple:
///
///  `State` -> `Content`.
///
/// **Important to note:**
///
/// Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.
///
/// **Usage:**
///
/// ```swift
/// let factory = StoreFactory(
///    initialState: AppState(),
///    reducer: { state, action in state.reduce(action) }
/// )
///
/// let envFactory = EnvStoreFactory(factory)
///
/// UIHostingController(
///     rootView: ViewWithStoreFactory(envFactory) {
///
///        ViewWithStore { state, dispatch in
///            FancyView(
///                title: state.title
///                onTap: { dispatch(TapAction()) }
///            )
///        }
///   }
/// )
/// ```
@available(iOS 13.0, *)
public struct ViewWithStore<ViewState, Action, Props, Content: View>: View {
    let props: (_ state: ViewState, _ store: PublishingStore<ViewState, Action>) -> Props
    let content: (_ props: Props) -> Content
    private(set) var presentationSettings: PresentationSettings<ViewState> = .default

    public var body: some View {
        ViewWithRootStore(
            content: self,
            presentationSettings: presentationSettings
        )
    }
}

@available(iOS 13.0, *)
public extension ViewWithStore {
    /// View modier that updates `ViewWithStore` deduplication settings.
    ///
    /// Allows to deduplicate state chages and skip evalutation of `Props` when not necessary.
    /// When new state is equal to the previous one, deduplication occurs.
    ///
    ///  **Important to note:**
    ///  By default, deduplication is not applied
    ///
    ///  - Parameter equating: defines the rule allowing to consider states as equal
    ///
    ///  - Returns: `ViewWithStore` with modified deduplication settings
    ///
    func removeStateDuplicates(_ equating: Equating<ViewState>) -> Self {
        var selfCopy = self
        selfCopy.presentationSettings.removeDuplicates = equating.predicate
        return selfCopy
    }

    /// View modier that updates `ViewWithStore` presentation settings.
    ///
    /// Allows to  choose the queue on which evalutation of `Props` would occur.
    /// The following PresentationQueue configs are supported:
    /// - Shared presentation queue - global serial queue with userInteractive qos
    /// - Main - main queue
    /// - Serial queue - use queue provided by developer
    ///
    ///  **Important to note:**
    ///  - By default,  shared presentation queue is used
    ///  - Serial queue config should be used with exactly *serial* queue
    ///
    ///  - Parameter equating: defines the rule allowing to consider states as equal
    ///
    ///  - Returns: `ViewWithStore` with modified deduplication settings
    ///
    func usePresentationQueue(_ queue: PresentationQueue) -> Self {
        var selfCopy = self
        selfCopy.presentationSettings.queue = queue
        return selfCopy
    }
}

@available(iOS 13.0, *)
public extension ViewWithStore {

    /// Initializes ViewWithStore which  connects its `ContentView`  to the store.
    /// - Parameter props: defines how `Props` are created from the state and store for action dispatching
    /// - Parameter content: defines how `ContentView` is created from props.
    ///
    ///  This constructor is provided mainly for backward compatibility and easier migration.
    ///  The following Construction with dispatch closure is preferable:
    ///
    ///  ```
    ///    init(props: @escaping (ViewState, @escaping Dispatch<Action>) -> Props,
    ///         content: @escaping (Props) -> Content) {
    ///         ...
    ///    }
    ///  ```
    ///
    /// **Usage:**
    ///
    /// ```
    /// UIHostingController(
    ///     rootView: ViewWithStoreFactory(envFactory) {
    ///
    ///        ViewWithStore(
    ///             props: { state, store in
    ///                 FancyView.Props(
    ///                     title: state.title,
    ///                     onTap: { store.dispatch(TapAction()) }
    ///                 )
    ///             },
    ///             content: { FancyView(props: $0) }
    ///         )
    ///     }
    /// )
    /// ```
    ///
    init(props: @escaping (ViewState, PublishingStore<ViewState, Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.props = props
        self.content = content
    }

    /// Initializes ViewWithStore which  connects its `ContentView`  to the store.
    /// - Parameter props: defines how `Props` are created from the state and action dispatching closure.
    /// - Parameter content: defines how `ContentView` is created from props.
    ///
    /// Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.
    ///
    /// **Usage:**
    /// ```
    /// UIHostingController(
    ///     rootView: ViewWithStoreFactory(envFactory) {
    ///
    ///        ViewWithStore(
    ///             props: { state, dispatch in
    ///                 FancyView.Props(
    ///                     title: state.title,
    ///                     onTap: { dispatch(TapAction()) }
    ///                 )
    ///             },
    ///             content: { FancyView(props: $0) }
    ///         )
    ///     }
    /// )
    /// ```
    ///
    init(props: @escaping (ViewState, @escaping Dispatch<Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.props = { state, store in props(state, store.dispatch) }
        self.content = content
    }
}

@available(iOS 13.0, *)
public extension ViewWithStore where Props == (ViewState, PublishingStore<ViewState, Action>) {
    /// Initializes ViewWithStore which  connects its `ContentView`  to the store.
    ///
    /// - Parameter content: defines how `ContentView` is created from the state and store for action dispatching
    ///
    ///  This constructor is provided mainly for backward compatibility and easier migration.
    ///  The following Construction with dispatch closure is preferable:
    ///
    ///  ```
    ///    init(content: @escaping (Props) -> Content) {
    ///         ...
    ///    }
    ///  ```
    ///
    /// **Usage:**
    ///
    /// ```
    /// UIHostingController(
    ///     rootView: ViewWithStoreFactory(envFactory) {
    ///
    ///        ViewWithStore { state, store in
    ///            FancyView(
    ///                title: state.title
    ///                onTap: { store.dispatch(TapAction()) }
    ///            )
    ///        }
    ///   }
    /// )
    /// ```
    ///
    init(_ content: @escaping (Props) -> Content) {
        self.props = { state, store in (state, store) }
        self.content = content
    }
}

@available(iOS 13.0, *)
public extension ViewWithStore where Props == (ViewState, PublishingStore<ViewState, Action>) {
    /// Initializes ViewWithStore which  connects its `ContentView`  to the store.
    ///
    /// - Parameter content: defines how `ContentView` is created from the state and store for action dispatching
    ///
    /// Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.
    ///
    /// **Usage:**
    ///
    /// ```
    /// UIHostingController(
    ///     rootView: ViewWithStoreFactory(envFactory) {
    ///
    ///        ViewWithStore { state, dispatch in
    ///            FancyView(
    ///                title: state.title
    ///                onTap: { dispatch(TapAction()) }
    ///            )
    ///        }
    ///   }
    /// )
    /// ```
    ///
    init(_ content: @escaping (ViewState, @escaping Dispatch<Action>) -> Content) {
        self.props = { state, store in (state, store) }
        self.content = { props in content(props.0, props.1.dispatch) }
    }
}

@available(iOS 13.0, *)
public extension ViewWithStore {
    /// Connects ViewWithStore's  `ContentView`  to the provided store.
    ///
    /// This method allows to skip using `EnvStoreFactory`'s root store and connect `ContentView` to the provided store directly.
    ///
    /// This can be useful for manually crafted store configurations or tests purposes.
    ///
    /// - Parameter store: provided store to connect to
    /// - Returns: `ViewWithStore` connected to the provided store
    ///
    /// **Usage:**
    ///
    /// ```
    /// let testState = AppState()
    /// let statePublisher = CurrentValueSubject<TestAppState, Never>(testState)
    ///
    /// let testStore = PublishingStore(
    ///     statePublisher: statePublisher.eraseToAnyPublisher(),
    ///     dispatch: { action in print(action) }
    /// )
    ///
    /// UIHostingController(
    ///     rootView: ViewWithStore { state, dispatch in
    ///            FancyView(
    ///                title: state.title
    ///                onTap: { dispatch(TapAction()) }
    ///            )
    ///            .store(testStore)
    ///        }
    /// )
    /// ```
    ///
    func store(_ store: PublishingStore<ViewState, Action>) -> some View {
        ViewWithPublishingStore(
            store: store,
            content: self,
            presentationSettings: presentationSettings
        )
    }

    /// Connects ViewWithStore's  `ContentView`  to the scope store.
    ///
    /// Scope store is a proxy to the EnvStoreFactory's root store with a mapping of root store state to local state.
    ///
    /// - Parameter localState: root to local state mapping
    ///
    ///  - Returns: `ViewWithStore` connected to the scope store`
    ///
    /// All dispatched Actions are forwarded to the root store.
    /// PublishingStore's state publisher is a mapping of the root store state publisher.
    ///
    /// **Important to note:**
    ///
    /// Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.
    ///
    /// **Usage:**
    /// ```
    /// let factory = StoreFactory(
    ///    initialState: AppState(),
    ///    reducer: { state, action in state.reduce(action) }
    /// )
    ///
    /// let envFactory = EnvStoreFactory(factory)
    ///
    /// UIHostingController(
    ///     rootView: ViewWithStoreFactory(envFactory) {
    ///
    ///        ViewWithStore { state, dispatch in
    ///            FancyView(
    ///                title: state.title
    ///                onTap: { dispatch(TapAction()) }
    ///            )
    ///        }
    ///        .scopeStore { (appState: AppState) in state.substate }
    ///     }
    /// )
    /// ```
    ///
    func scopeStore<AppState>(to localState: @escaping (AppState) -> ViewState) -> some View {
        ViewWithScopeStore(
            localState: localState,
            content: self,
            presentationSettings: presentationSettings
        )
    }

    /// Connects ViewWithStore's  `ContentView`  to the child store.
    ///
    /// - Parameter initialState: initial state child store
    /// - Parameter stateMapping: mapping of root state and child state in the the view state
    /// - Parameter qos: qualitity of service for the child store
    /// - Parameter reducer: reducer for the child state
    ///
    ///  - Returns: `ViewWithStore` connected to the child store
    ///
    /// ChildStore is a composition of root store and newly created local store.
    /// ChildStore's state is a mapping of the local state and root store's state.
    ///
    /// ChildStore's lifecycle along with its LocalState is determined by `ViewWithStore's` lifecycle.
    /// Child state would be destroyed when ViewWithStore disappears from the hierarchy.
    ///
    /// **RootStore vs ChildStore Action Dispatch.**
    ///
    /// When action is dispatched to RootStore:
    /// - action is delivered to root store's reducer
    /// - action is not delivered to child store's reducer
    /// - root state update triggers root store's subscribers
    /// - root state update triggers child stores' subscribers
    /// - Interceptor dispatches additional actions to RootStore
    ///
    /// When action is dispatched to ChildStore:
    /// - action is delivered to root store's reducer
    /// - action is delivered to child store's reducer
    /// - root state update triggers root store's subscribers.
    /// - root state update triggers child store's subscribers.
    /// - local state update triggers child stores' subscribers.
    /// - Interceptor dispatches additional actions to ChildStore
    ///
    /// **Important to note:**
    ///
    /// Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.
    ///
    /// **Usage:**
    /// ```
    /// let factory = StoreFactory(
    ///    initialState: AppState(),
    ///    reducer: { state, action in state.reduce(action) }
    /// )
    ///
    /// let envFactory = EnvStoreFactory(factory)
    ///
    /// UIHostingController(
    ///     rootView: ViewWithStoreFactory(envFactory) {
    ///
    ///        ViewWithStore { state, dispatch in
    ///            FancyView(
    ///                title: state.title
    ///                onTap: { dispatch(TapAction()) }
    ///            )
    ///        }
    ///        .childStore(
    ///             initialState: ChildState(),
    ///             stateMapping: { appState, childState in
    ///                 StateComposition(appState, childState)
    ///             },
    ///             reducer: { state, action in state.reduce(action) }
    ///        )
    ///     }
    /// )
    /// ```
    ///
    func childStore<AppState, ChildState>(initialState: ChildState,
                                          stateMapping: @escaping (AppState, ChildState) -> ViewState,
                                          qos: DispatchQoS = .userInteractive,
                                          reducer: @escaping Reducer<ChildState, Action>) -> some View {

        ViewWithChildStore(
            initialState:initialState,
            stateMapping: stateMapping,
            qos: qos,
            reducer: reducer,
            content: self,
            presentationSettings: presentationSettings
        )
    }

    /// Connects ViewWithStore's  `ContentView`  to the child store.
    ///
    /// - Parameter initialState: initial state child store
    /// - Parameter qos: qualitity of service for the child store
    /// - Parameter reducer: reducer for the child state
    ///
    ///  - Returns: `ViewWithStore` connected to the child store
    ///
    /// ChildStore is a composition of root store and newly created local store.
    /// ChildStore's state is a mapping of the local state and root store's state.
    ///
    /// ChildStore's lifecycle along with its LocalState is determined by `ViewWithStore's` lifecycle.
    /// Child state would be destroyed when ViewWithStore disappears from the hierarchy.
    ///
    /// **RootStore vs ChildStore Action Dispatch.**
    ///
    /// When action is dispatched to RootStore:
    /// - action is delivered to root store's reducer
    /// - action is not delivered to child store's reducer
    /// - root state update triggers root store's subscribers
    /// - root state update triggers child stores' subscribers
    /// - Interceptor dispatches additional actions to RootStore
    ///
    /// When action is dispatched to ChildStore:
    /// - action is delivered to root store's reducer
    /// - action is delivered to child store's reducer
    /// - root state update triggers root store's subscribers.
    /// - root state update triggers child store's subscribers.
    /// - local state update triggers child stores' subscribers.
    /// - Interceptor dispatches additional actions to ChildStore
    ///
    /// **Important to note:**
    ///
    /// Before using `ViewWithStore`, `EnvStoreFactory` should be injected on top of the view hierarchy via `ViewWithStoreFactory`.
    ///
    /// **Usage:**
    /// ```
    /// let factory = StoreFactory(
    ///    initialState: AppState(),
    ///    reducer: { state, action in state.reduce(action) }
    /// )
    ///
    /// let envFactory = EnvStoreFactory(factory)
    ///
    /// UIHostingController(
    ///     rootView: ViewWithStoreFactory(envFactory) {
    ///
    ///        ViewWithStore { state, dispatch in
    ///            FancyView(
    ///                title: state.title
    ///                onTap: { dispatch(TapAction()) }
    ///            )
    ///        }
    ///        .childStore(
    ///             initialState: ChildState(),
    ///             reducer: { state, action in state.reduce(action) }
    ///        )
    ///     }
    /// )
    /// ```
    ///
    func childStore<AppState, ChildState>(initialState: ChildState,
                                          qos: DispatchQoS = .userInteractive,
                                          reducer: @escaping Reducer<ChildState, Action>) -> some View

    where ViewState == (AppState, ChildState) {

        ViewWithChildStore(
            initialState:initialState,
            stateMapping: { ($0, $1) },
            qos: qos,
            reducer: reducer,
            content: self,
            presentationSettings: presentationSettings
        )
    }
}
