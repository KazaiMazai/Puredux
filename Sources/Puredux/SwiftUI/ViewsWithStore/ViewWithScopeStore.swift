//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import SwiftUI

@available(*, deprecated, message: "Will be removed in 2.0")
struct ViewWithScopeStore<AppState, LocalState, Action, Props, Content>: View
    where
    Content: View {

    @EnvironmentObject private var storeFactory: EnvStoreFactory<AppState, Action>

    let localState: (AppState) -> LocalState
    let content: ViewWithStore<LocalState, Action, Props, Content>
    var presentationSettings: PresentationSettings<LocalState>

    var body: some View {
        ViewWithPublishingStore(
            store: storeFactory.scopeStore(to: localState),
            content: content,
            presentationSettings: presentationSettings
        )
    }
}
