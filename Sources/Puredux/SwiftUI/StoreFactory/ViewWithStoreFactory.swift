//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 06.03.2023.
//

import SwiftUI

/// `ViewWithStoreFactory` is a view with a `EnvStoreFactory` injected into`Content` view via `environmentObject(...)`
///
/// It's  is supposed to be used on top of the views hierarchy.
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
///
public struct ViewWithStoreFactory<AppState, Aciton, Content: View>: View {
    private let storeFactory: EnvStoreFactory<AppState, Aciton>
    private let content: () -> Content

    public var body: some View {
        content().environmentObject(storeFactory)
    }
}

public extension ViewWithStoreFactory {
    /// Initializes a View with a `EnvStoreFactory` injected into`Content` view via `environmentObject(...)`
    ///
    /// - Parameter storeFactory: `EnvStoreFactory` that will be injected into the view hierarchy.
    /// - Parameter content: defines `Content`
    ///
    /// - Returns: `View` with injected EnvStoreFactory.
    init(_ storeFactory: EnvStoreFactory<AppState, Aciton>,
                content: @escaping () -> Content) {
        self.storeFactory = storeFactory
        self.content = content
    }
}
