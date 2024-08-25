//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 20/08/2024.
//

import Foundation
import SwiftUI
import PureduxMacros
 

@available(iOS 13.0, *)
struct ViewController: View {
    @StoreOf(\.root) var root
    @State var store = StoreOf(\.root).with(true, reducer: {_,_ in })
    
    var body: some View  {
        Text("").onAppear {
            store.dispatch(1)
        }
    }
    
    init() {
        store = StateStore((1,true)) {_,_ in }
        Injected[\.root] = .init(10) {_,_ in }
        
    }
}

extension Injected {
    @InjectEntry var root = StateStore<Int?, Int>(10) {_,_ in }
}
