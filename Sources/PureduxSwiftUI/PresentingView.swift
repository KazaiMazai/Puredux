//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import SwiftUI

public protocol PresentingView: View {
    associatedtype Content: View
    associatedtype Props
    associatedtype State
    associatedtype Action

    func props(for state: State, on store: EnvironmentStore<State, Action>) -> Props
    func map(props: Props) -> Content
}

public extension PresentingView {
    var body: some View {
        ConnectedView<State, Action, Content>(map: map)
    }

    private func map(_ state: State, _ store: EnvironmentStore<State, Action>) -> Content {
        map(props: props(for: state, on: store))
    }
}

private struct ConnectedView<State, Action, V: View>: View {
    @EnvironmentObject var store: EnvironmentStore<State, Action>

    let map: (_ state: State, _ store: EnvironmentStore<State, Action>) -> V

    var body: V {
        map(store.state, store)
    }
}
