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
    associatedtype AppState
    associatedtype Action
    associatedtype Props
    associatedtype Content: View

    func props(for state: AppState, on store: ObservableStore<AppState, Action>) -> Props

    func content(for props: Props) -> Content

    var distinctStateChangesBy: Equating<AppState> { get }
}

public extension PresentableView {
    var body: some View {
        EnvironmentStorePresentingView(
            props: props,
            content: content,
            distinctStateChangesBy: distinctStateChangesBy.predicate)
    }

    var distinctStateChangesBy: Equating<AppState> {
        .neverEqual
    }
}
