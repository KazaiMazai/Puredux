//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 20/08/2024.
//

import Foundation
import SwiftUI
 

//@available(iOS 13.0, *)
//struct ViewController: View {
//    @InjectedStore(\.rootStore) var rootStore
//    @State var store = InjectedStore(\.rootStore).with(true, reducer: {_,_ in })
//    
//    var body: some View  {
//        Text("").onAppear {
//            store.dispatch(1)
//        }
//    }
//    
//    init() {
//        store = StateStore((1,true)) {_,_ in }
//        InjectedStores[\.rootStore] = .init(10) {_,_ in }
//        
//    }
//}

//extension InjectedStores {
//    @InjectedStoreEntry var rootStore = StateStore<Int?, Int>(10) {_,_ in }
//}
