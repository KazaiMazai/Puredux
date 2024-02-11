//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2021.
//

import Foundation

protocol Action {

}

struct UpdateIndex: Action {
    let index: Int
}

struct ResultAction: Action {
    let index: Int
}

struct AsyncAction: Action {
    let index: Int
}
