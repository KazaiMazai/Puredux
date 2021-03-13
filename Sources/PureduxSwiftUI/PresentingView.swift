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
    @State private var observableProps: Props?

    let distinctStateBy: Equating<AppState>
    let props: (_ substate: AppState, _ store: EnvironmentStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content

    var body: some View {
        content(latestProps)
            .onReceive(propsPublisher) { observableProps = $0 }
    }

    private var latestProps: Props {
        observableProps ?? props(store.state, store)
    }


    private var propsPublisher: AnyPublisher<Props, Never> {
        store.stateSubject
            .removeDuplicates(by: distinctStateBy.equals)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
