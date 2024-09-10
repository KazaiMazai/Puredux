//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 09/09/2024.
//

import Foundation

#if hasFeature(RetroactiveAttribute)
extension KeyPath: @retroactive @unchecked Sendable {

}
#else
extension KeyPath: @unchecked Sendable {

}
#endif
 
