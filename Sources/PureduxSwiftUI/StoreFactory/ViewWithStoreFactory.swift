//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.03.2023.
//

import SwiftUI

public struct ViewWithStoreFactory<AppState, Aciton, Content: View>: View {
    private let storeFactory: EnvStoreFactory<AppState, Aciton>
    private let content: () -> Content

    public var body: some View {
        content().environmentObject(storeFactory)
    }

    /**
    Initializes a View with a `EnvStoreFactory` injected into`Content` view via `environmentObject(...)` injection

    - Parameter storeFactory: `EnvStoreFactory` that will be injected into the view hierarchy.
    - Parameter content: defines `Content`

    - Returns: `View` with injected EnvStoreFactory.

     `ViewWithStoreFactory` is supposed to be used on top of the views hierarchy.

     ```
     let factory = StoreFactory(
        initialState: AppState(),
        reducer: { state, action in state.reduce(action) }
     )

     let storeFactory = EnvStoreFactory(factory)

     UIHostingController(
         rootView: ViewWithStoreFactory(storeFactory) {

            ViewWithStore { state, dispatch in
                FancyView(
                    title: state.title
                    onTap: { dispatch(TapAction()) }
                )
            }
        }
     )

     ```
     */

    public init(_ storeFactory: EnvStoreFactory<AppState, Aciton>,
                content: @escaping () -> Content) {
        self.storeFactory = storeFactory
        self.content = content
    }
}
