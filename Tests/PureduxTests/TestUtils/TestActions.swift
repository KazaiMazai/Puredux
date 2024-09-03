//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation
import Puredux

protocol Action {

}

struct UpdateIndex: Action {
    let index: Int
}

struct ResultAction: Action {
    let index: Int
}

struct AsyncResultAction: Action {
    let index: Int
}

struct AsyncIndexAction: Action & AsyncAction {
    let index: Int
    
    func execute(completeHandler: @escaping (ResultAction) -> Void) {
        completeHandler(ResultAction(index: index))
    }
}
 
struct NonMutatingStateAction: Action {

}

struct UpdateTitle: Action {
    let title: String
}
  
struct UpdateIndexCallBack: Action & AsyncAction {
    let index: Int
    let executionCallback: () -> Void
    
    func execute(completeHandler: @escaping (ResultAction) -> Void) {
        executionCallback()
    }
}
