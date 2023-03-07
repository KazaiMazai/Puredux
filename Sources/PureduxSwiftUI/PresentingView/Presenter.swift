//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.02.2023.
//

import SwiftUI

struct Presenter<AppState, Action, Props, Content: View> {
    let props: (_ state: AppState, _ store: PublishingStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content

    let removeDuplicates: (AppState, AppState) -> Bool
    let queue: PresentationQueue
}
