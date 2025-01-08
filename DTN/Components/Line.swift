//
//  Line.swift
//  DTN
//
//  Created by Yu Takahashi on 12/18/24.
//

import SwiftUI

struct LineView: View {
    let start: CGPoint
    let end: CGPoint

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(Color.gray, lineWidth: 2)
    }
}
