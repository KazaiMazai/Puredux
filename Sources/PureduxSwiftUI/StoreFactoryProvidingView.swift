//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.03.2023.
//

import SwiftUI

public struct StoreFactoryProvidingView<AppState, Aciton, Content: View>: View {
    private let storeFactory: EnvStoreFactory<AppState, Aciton>
    private let content: () -> Content

    public var body: some View {
        content().environmentObject(storeFactory)
    }

    /**
    Initializes a View with a `RootEnvStore` injected into`Content` view via `environmentObject(...)` injection

    - Parameter rootStore: `RootEnvStore` that will be injected into the view hierarchy.
    - Parameter content: defines `Content`

    - Returns: `View` with injected RootEnvStore.

     `StoreProvidingView` is supposed to be used somewhere on top of the app's views hierarchy.

     **Important to note:**  Before connecting Views to RootEnvStore, it should be injected into the view hierarchy as an `environmentObject`.
     `StoreProvidingView` does exactly this:

     ```
     UIHostingController(
         rootView: StoreProvidingView(rootStore: rootStore) {
             FancyView.withEnvStore(
                 props: presenter.makeProps,
                 content: { FancyView(props: $0) }
             )
         }
     )

     ```
     */

    public init(storeFactory: EnvStoreFactory<AppState, Aciton>,
                content: @escaping () -> Content) {
        self.storeFactory = storeFactory
        self.content = content
    }
}
