//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/09/2024.
//

import Foundation

@propertyWrapper
public struct Dependency<T> {
    private let keyPath: WritableKeyPath<Injected, T>

    public var wrappedValue: T {
        get { Injected[keyPath] }
    }

    public init(_ keyPath: WritableKeyPath<Injected, T>) {
        self.keyPath = keyPath
    }
    
    public static subscript(_ keyPath: WritableKeyPath<Injected, T>) -> T {
        get {
            Injected[keyPath]
        }
    }
}

 
  
protocol Service {
    
}

struct ServiceImp: Service {
    
}

extension Injected {
    @InjectEntry var intValue = 1
    
    @InjectEntry var uuid = { UUID() }
    
    
}

class Foo {
    @Dependency(\.intValue) var value
    
    var uuidValue = Dependency[\.uuid]
    
     
}


struct DI: DependencyContainer {
    @InjectEntry var intValue = 1
    
    @InjectEntry var uuid = { UUID() }
    
    
}
