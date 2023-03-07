//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import SwiftUI
import Combine
import PureduxStore
import PureduxCommon


struct ViewWithChildStore<AppState, LocalState, ChildState, Action, Props, Content>: View
    where Content: View {

    @EnvironmentObject private var storeFactory: EnvStoreFactory<AppState, Action>
    @State private var publishingChildStore: PublishingStoreObject<ChildState, Action>? = nil

    let childStore: ChildStore<AppState, LocalState, ChildState, Action>
    let presenter: Presenter<ChildState, Action, Props, Content>

    var body: some View {
        makeContent().onAppear {
            publishingChildStore = storeFactory.childStore(
                initialState: childStore.initialState,
                stateMapping: childStore.stateMapping,
                qos: childStore.qos,
                reducer: childStore.reducer
            )
        }
    }

    @ViewBuilder
    func makeContent() -> some View {
        if let publishingChildStore {
            PresentingView(
                store: publishingChildStore.store(),
                presenter: presenter
            )
        } else {
            Color.clear
        }
    }
}

