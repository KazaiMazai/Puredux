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
    associatedtype Action

    func props(for state: AppState, on store: EnvironmentStore<AppState, Action>) -> Props

    func content(for props: Props) -> Content

    var equatingStates: Equating<AppState> { get }
}

public extension PresentableView {
    var body: some View {
        PresentingView(props: props,
                       content: content,
                       equatingStates: equatingStates)
    }

    var equatingStates: Equating<AppState> {
        .neverEqual
    }
}

