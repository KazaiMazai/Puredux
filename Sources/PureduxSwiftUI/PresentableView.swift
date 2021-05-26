//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import SwiftUI
import Combine
import PureduxCommon

public protocol PresentableView: View {
    associatedtype Content: View
    associatedtype Props
    associatedtype LocalState
    associatedtype AppState
    associatedtype Action

    func props(for state: LocalState, on store: ObservableStore<AppState, Action>) -> Props

    func content(for props: Props) -> Content

    func substate(for state: AppState) -> LocalState

    var distinctStateChangesBy: Equating<LocalState> { get }
}

public extension PresentableView {
    var body: some View {
        EnvironmentStorePresentingView(
            substate: substate,
            props: props,
            content: content,
            distinctStateChangesBy: distinctStateChangesBy.predicate)
    }

    var distinctStateChangesBy: Equating<LocalState> {
        .neverEqual
    }
}

public extension PresentableView where LocalState == AppState {
    func substate(for state: AppState) -> LocalState {
        state
    }
}
