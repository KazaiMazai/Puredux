//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import SwiftUI
import PureduxStore
import PureduxCommon

struct ViewWithScopeStore<AppState, LocalState, Action, Props, Content>: View
    where
    Content: View {

    @EnvironmentObject private var storeFactory: EnvStoreFactory<AppState, Action>

    let scopeStore: ScopeStore<AppState, LocalState>
    let presenter: Presenter<LocalState, Action, Props, Content>

    var body: some View {
        PresentingView(
            store: storeFactory.scopeStore(toLocalState: scopeStore.toLocalState),
            presenter: presenter
        )
    }
}

