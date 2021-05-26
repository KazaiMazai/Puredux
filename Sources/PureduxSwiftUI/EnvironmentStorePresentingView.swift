//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine

struct EnvironmentStorePresentingView<AppState, Action, LocalState, Props, Content>: View
    where
    Content: View {

    @EnvironmentObject private var store: ObservableStore<AppState, Action>

    let substate: (_ state: AppState) -> LocalState
    let props: (_ localState: LocalState, _ store: ObservableStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content
    let distinctStateChangesBy: (LocalState, LocalState) -> Bool

    var body: some View {
        StorePresentingView(
            store: store,
            substate: substate,
            props: props,
            content: content,
            distinctStateChangesBy: distinctStateChangesBy)
    }
}

