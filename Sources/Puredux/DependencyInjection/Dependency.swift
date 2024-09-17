//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

@propertyWrapper
public struct Dependency<T> {
    private let keyPath: WritableKeyPath<Dependencies, T>

    public var wrappedValue: T {
        get { Dependencies[keyPath] }
    }

    public init(_ keyPath: WritableKeyPath<Dependencies, T>) {
        self.keyPath = keyPath
    }
    
    public static subscript(_ keyPath: WritableKeyPath<Dependencies, T>) -> T {
        get {
            Dependencies[keyPath]
        }
    }
}


protocol Service {
    
}

struct ServiceImp: Service {
    
}

extension Dependencies {
    @DependencyEntry var intValue = 1
    
    @DependencyEntry var uuid = { UUID() }
    @DependencyEntry var now = { Date() }
    
}

class Foo {
    @Dependency(\.intValue) var value
    
    var uuidValue = Dependency[\.uuid]
    
    func ffofofo() {
        Dependencies[\.now] = { .distantPast }
    }
}

 
