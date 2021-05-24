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
    associatedtype AppState
    associatedtype Action
    associatedtype SubState

    func props(for state: SubState, on store: EnvironmentStore<AppState, Action>) -> Props

    func content(for props: Props) -> Content

    func substate(for state: AppState) -> SubState

    var distinctStateChangesBy: Equating<SubState> { get }
}

public extension PresentableView {
    var body: some View {
        PresentingView(
            substate: substate,
            props: props,
            content: content,
            distinctStateChangesBy: distinctStateChangesBy.predicate)
    }

    var distinctStateChangesBy: Equating<SubState> {
        .neverEqual
    }
}

public extension PresentableView where SubState == AppState {
    func substate(for state: AppState) -> SubState {
        state
    }
}
