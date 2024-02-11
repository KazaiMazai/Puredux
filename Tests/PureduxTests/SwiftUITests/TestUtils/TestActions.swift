//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 30.11.2021.
//

import Foundation

protocol Action {

}

struct NonMutatingStateAction: Action {

}

struct UpdateTitle: Action {
    let title: String
}

struct UpdateIndex: Action {
    let index: Int
}
