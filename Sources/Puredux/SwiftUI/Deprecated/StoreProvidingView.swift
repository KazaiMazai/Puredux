//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import SwiftUI

@available(*, deprecated, message: "Will be removed in 2.0. Check ViewWithStore migration guide")
public struct StoreProvidingView<AppState, Aciton, Content: View>: View {
    private let rootStore: RootEnvStore<AppState, Aciton>
    private let content: () -> Content

    public var body: some View {
        content().environmentObject(rootStore)
    }

    ///    Initializes a View with a `RootEnvStore` injected into`Content` view via `environmentObject(...)` injection
    ///
    ///    - Parameter rootStore: `RootEnvStore` that will be injected into the view hierarchy.
    ///    - Parameter content: defines `Content`
    ///
    ///    - Returns: `View` with injected RootEnvStore.
    ///
    ///     `StoreProvidingView` is supposed to be used somewhere on top of the app's views hierarchy.
    ///
    ///     **Important to note:**  Before connecting Views to RootEnvStore, it should be injected into the view hierarchy as an `environmentObject`.
    ///     `StoreProvidingView` does exactly this:
    ///
    ///     ```
    ///     UIHostingController(
    ///         rootView: StoreProvidingView(rootStore: rootStore) {
    ///             FancyView.withEnvStore(
    ///                 props: presenter.makeProps,
    ///                 content: { FancyView(props: $0) }
    ///             )
    ///         }
    ///     )
    ///
    ///     ```
    @available(*, deprecated, message: "Will be removed in 2.0. Use EnvStoreFactory and ViewWithStoreFactory instead")
    public init(rootStore: RootEnvStore<AppState, Aciton>,
                content: @escaping () -> Content) {
        self.rootStore = rootStore
        self.content = content
    }
}
