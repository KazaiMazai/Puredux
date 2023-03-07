//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import SwiftUI
import Combine
import PureduxStore
import PureduxCommon

struct ViewWithRootStore<AppState, Action, Props, Content>: View
    where
    Content: View {

    @EnvironmentObject private var storeFactory: EnvStoreFactory<AppState, Action>

    let presenter: Presenter<AppState, Action, Props, Content>

    var body: some View {
        PresentingView(
            store: storeFactory.rootStore(),
            presenter: presenter
        )
    }
}
 
