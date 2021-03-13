//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import SwiftUI
import Combine

public protocol PresentableView: View {
    associatedtype Content: View
    associatedtype Props
    associatedtype AppState
    associatedtype SubState: Equatable
    associatedtype Action

    func props(for substate: SubState, on store: EnvironmentStore<AppState, Action>) -> Props
    func substate(for state: AppState) -> SubState
    func content(for props: Props) -> Content
}

public extension PresentableView {
    var body: some View {
        PresentingView(substate: substate,
                       props: props,
                       content: content)
    }

    private func content(for substate: SubState,
                         on store: EnvironmentStore<AppState, Action>) -> Content {
        content(for: props(for: substate, on: store))
    }
}

public extension PresentableView where AppState: FalseEquatable, AppState == SubState {
    func substate(for state: AppState) -> SubState {
        state
    }
}
