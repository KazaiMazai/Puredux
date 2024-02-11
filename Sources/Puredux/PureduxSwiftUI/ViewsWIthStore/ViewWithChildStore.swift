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

struct ViewWithChildStore<AppState, ChildState, LocalState, Action, Props, Content>: View
    where Content: View {

    @EnvironmentObject private var storeFactory: EnvStoreFactory<AppState, Action>
    @State private var publishingChildStore: PublishingStoreObject<LocalState, Action>? = nil

    let initialState: ChildState
    let stateMapping: (AppState, ChildState) -> LocalState
    let qos: DispatchQoS
    let reducer: Reducer<ChildState, Action>

    let content: ViewWithStore<LocalState, Action, Props, Content>
    var presentationSettings: PresentationSettings<LocalState>

    var body: some View {
        makeContent().onAppear {
            publishingChildStore = storeFactory.childStore(
                initialState: initialState,
                stateMapping: stateMapping,
                qos: qos,
                reducer: reducer
            )
        }
    }

    @ViewBuilder
    func makeContent() -> some View {
        if let publishingChildStore {
            ViewWithPublishingStore(
                store: publishingChildStore.store(),
                content: content,
                presentationSettings: presentationSettings
            )
        } else {
            Color.clear
        }
    }
}
