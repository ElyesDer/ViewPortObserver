//
//  VerticalViewPortPreview.swift
//
//
//  Created by Elyes Derouiche on 28/12/2023.
//

import SwiftUI

let quotes: [String] = [
    "Storms make oaks take deeper root.\nGeorge Herbert (1593 - 1633)",
    "Never promise more than you can perform.\n Publilius Syrus (~100 BC)",
    "Lawyers spend a great deal of their time shoveling smoke.\nOliver Wendell Holmes Jr. (1841 - 1935)",
    "Youth would be an ideal state if it came a little later in life.\nHerbert Henry Asquith (1852 - 1928)",
    "We rarely think people have good sense unless they agree with us.\nFrancois de La Rochefoucauld (1613 - 1680)",
    "So this is how liberty dies. With thunderous applause.\nGeorge Lucas (1944 - )"
]

let colors: [Color] = [
    .blue,
    .secondary,
    .green,
    .pink,
    .purple,
    .yellow
]

let adIndex = 2

#Preview {
    if #available(iOS 17.0, *) {
        VStack {
            IOS17ViewPortPreview(
                axis: Axis.horizontal
            )

            IOS17ViewPortPreview(
                axis: Axis.vertical
            )
        }
    } else {
        VStack(spacing: .zero) {
            // Fallback on earlier versions
            OldiOSViewPortPreview(
                axis: .horizontal
            )

            OldiOSViewPortPreview(
                axis: .vertical
            )
        }
    }
}
