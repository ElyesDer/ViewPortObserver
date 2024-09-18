//
//  OldiOSViewPortPreview.swift
//  ViewPortObserver
//
//  Created by Elyes Derouiche on 17/09/2024.
//

import SwiftUI

struct OldiOSViewPortPreview: View {

    let coordinateSpace: ViewPortObserver.CoordinateSpaceProvider = .named("\(Self.self)ViewPortVisualCoordinates")

    @State
    private var currentViewState: ViewPortObserver.ViewLifeCycle = .appear

    let adIndex = 2

    let axis: Axis

    var scrollAxis: Axis.Set {
        if axis == .vertical {
            [.vertical]
        } else {
            [.horizontal]
        }
    }

    @ViewBuilder
    func conditionalLayout(size: CGSize) -> some View {
        ForEach(Array(quotes.enumerated()), id: \.offset) { index, element in
            if index == adIndex {
                Text("Ad")
                    .frame(width: 300, height: 200)
                    .background(Color.red)
                    .padding()
                    .observerViewPort(
                        axis: axis,
                        container: .init(
                            width: size.width,
                            height: size.height
                        ),
                        coordinatedSpace: coordinateSpace
                    ) { changes in
                        currentViewState = changes
                    }

            } else {
                Text(element)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(colors[index])
            }
        }
    }

    var body: some View {
        GeometryReader { reader in
            VStack(spacing: .zero) {
                Text("\(axis.description.capitalized) ViewPort Sample")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)

                ScrollView(scrollAxis) {
                    switch axis {
                    case .horizontal:
                        HStack {
                            conditionalLayout(size: reader.size)
                        }
                    case .vertical:
                        VStack {
                            conditionalLayout(size: reader.size)
                        }
                    }
                }
                .coordinateSpace(name: coordinateSpace.name)

                Text("Is Ad Visible ? \(currentViewState == .appear)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
            }
        }
    }
}
