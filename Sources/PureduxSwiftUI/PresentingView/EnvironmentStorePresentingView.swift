//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine

//associatedtype MakeProps<AppState, Store, Props> = (_ state: AppState, _ store: Store) -> Props

struct EnvironmentStorePresentingView<AppState, Action, Props, Content>: View
    where
    Content: View {

    @EnvironmentObject private var store: ObservableStore<AppState, Action>

    let props: (_ state: AppState, _ store: ObservableStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content
    let distinctStateChangesBy: (AppState, AppState) -> Bool
    let presentationOptions: PresentationOptions

    var body: some View {
        StorePresentingView(
            store: store,
            props: props,
            content: content,
            distinctStateChangesBy: distinctStateChangesBy,
            presentationOptions: presentationOptions)
    }
}

