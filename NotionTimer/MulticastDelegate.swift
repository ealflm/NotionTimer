//
//  MulticastDelegate.swift
//  NotionTimer
//
//  Created by Đào Phương Nam on 03/05/2023.
//

class MulticastDelegate<T> {
    private var delegates = [Weak]()
    
    func addDelegate(_ delegate: T) {
        delegates.append(Weak(value: delegate as AnyObject))
    }
    
    func removeDelegate(_ delegate: T) {
        if let index = delegates.firstIndex(where: { $0.value === delegate as AnyObject }) {
            delegates.remove(at: index)
        }
    }
    
    func invokeDelegates(_ closure: (T) -> Void) {
        for (index, delegate) in delegates.enumerated().reversed() {
            if let delegate = delegate.value as? T {
                closure(delegate)
            } else {
                delegates.remove(at: index)
            }
        }
    }
    
    private class Weak: Equatable {
        weak var value: AnyObject?
        
        init(value: AnyObject) {
            self.value = value
        }
        
        static func ==(lhs: Weak, rhs: Weak) -> Bool {
            return lhs.value === rhs.value
        }
    }
}

