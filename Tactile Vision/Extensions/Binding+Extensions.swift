//
//  Binding+Extensions.swift
//  Tactile Vision
//
//  Created by Pablo Aguirre on 18/09/24.
//

import SwiftUI

extension Binding where Value: OptionSet, Value == Value.Element {
    
    func bind(_ options: Value) -> Binding<Bool> {
        return .init(
            get: { self.wrappedValue.contains(options) },
            set: { insert in
                if insert {
                    self.wrappedValue.insert(options)
                } else {
                    self.wrappedValue.remove(options)
                }
            }
        )
    }
}
