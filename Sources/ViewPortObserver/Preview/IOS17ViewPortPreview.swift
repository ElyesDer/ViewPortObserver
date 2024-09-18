//
//  HorizontalViewPortPreview.swift
//  ViewPortObserver
//
//  Created by Elyes Derouiche on 17/09/2024.
//

import SwiftUI

@available(iOS 17.0, *)
struct IOS17ViewPortPreview: View {

    let coordinateSpace: ViewPortObserver.CoordinateSpaceProvider = .named("\(Self.self)ViewPortVisualCoordinates")

    @State
    private var currentViewState: ViewPortObserver.ViewLifeCycle = .appear

    let axis: Axis

    var scrollAxis: Axis.Set {
        if axis == .vertical {
            [.vertical]
        } else {
            [.horizontal]
        }
    }

    var body: some View {
        VStack(spacing: .zero) {
            Text("\(axis.description.capitalized) ViewPort Sample")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)

            let conditionalLayout = (axis == .horizontal) ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())

            ScrollView(scrollAxis) {
                conditionalLayout {
                    ForEach(Array(quotes.enumerated()), id: \.offset) { index, element in
                        if index == adIndex {
                            Text("Ad")
                                .frame(width: 300, height: 200)
                                .background(Color.red)
                                .padding()
                                .border(Color.red)
                                .observerViewPort(
                                    axis: axis,
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
            }
            .coordinateSpace(name: coordinateSpace.name)

            Text("Is Ad Visible ? \(currentViewState == .appear)")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
        }
    }
}

