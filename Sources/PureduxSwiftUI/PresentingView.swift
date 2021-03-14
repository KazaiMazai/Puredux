//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine

struct PresentingView<AppState, Action, Props, Content>: View where Content: View {
    @EnvironmentObject private var store: EnvironmentStore<AppState, Action>

    @State private var latestProps: Props?
    @State private var propsPublisher: AnyPublisher<Props, Never>?

    let props: (_ state: AppState, _ store: EnvironmentStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content
    let stateEquatingPredicate: (AppState, AppState) -> Bool

    var body: some View {
        content(latestProps ?? props(store.state, store))
            .onAppear { propsPublisher = makePropsPublisher() }
            .onReceive(propsPublisher ?? makePropsPublisher()) { self.latestProps = $0 }
    }

    private func makePropsPublisher() -> AnyPublisher<Props, Never> {
        store.stateSubject
            .removeDuplicates(by: stateEquatingPredicate)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

