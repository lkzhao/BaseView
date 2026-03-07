//
//  LavaBGView.swift
//  Example
//
//  Created by Luke Zhao on 3/7/26.
//

import SwiftUI
import UIComponent

struct LavaBGComponent: ComponentBuilder {
    func build() -> some Component {
        SwiftUIComponent {
            LavaBGView()
        }.view().roundedCorner().clipsToBounds(true)
    }
}

struct LavaBGView: View {
    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSince1970
            let offsetX = Float(sin(time)) * 0.1
            let offsetY = Float(cos(time)) * 0.1
            let moltenOrange = Color(red: 1.00, green: 0.60, blue: 0.00)
            let baseOrange = Color(red: 0.98, green: 0.62, blue: 0.02)
            let amber = Color(red: 1.00, green: 0.77, blue: 0.20)
            let warmGold = Color(red: 0.98, green: 0.82, blue: 0.29)
            let softGold = Color(red: 0.98, green: 0.79, blue: 0.31)
            let paleGold = Color(red: 1.00, green: 0.86, blue: 0.43)
            
            MeshGradient(
                width: 4,
                height: 4,
                points: [
                    [0.0, 0.0],
                    [0.3, 0.0],
                    [0.7, 0.0],
                    [1.0, 0.0],
                    [0.0, 0.3],
                    [0.2 + offsetX, 0.4 + offsetY],
                    [0.7 + offsetX, 0.2 + offsetY],
                    [1.0, 0.3],
                    [0.0, 0.7],
                    [0.3 + offsetX, 0.8],
                    [0.7 + offsetX, 0.6],
                    [1.0, 0.7],
                    [0.0, 1.0],
                    [0.3, 1.0],
                    [0.7, 1.0],
                    [1.0, 1.0]
                ],
                colors: [
                    warmGold, amber, softGold, paleGold,
                    amber, moltenOrange, baseOrange, warmGold,
                    baseOrange, moltenOrange, amber, softGold,
                    paleGold, warmGold, amber, baseOrange
                ]
            )
        }
    }
}
