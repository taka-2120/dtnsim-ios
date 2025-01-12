//
//  Dot.swift
//  DTN
//
//  Created by Yu Takahashi on 12/18/24.
//

import Foundation

struct Dot: Identifiable {
    let id = UUID()
    var position: CGPoint

    init(at position: CGPoint) {
        self.position = position
    }
}
