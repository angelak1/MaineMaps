//
//  View+isVisible.swift
//  MaineMaps
//
//  Created by Angela Kearns on 12/31/23.
//

import Foundation
import SwiftUI

extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isVisible(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isVisible(false, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isVisible(_ visible: Bool, removeIfHidden: Bool = true) -> some View {
        if visible {
            self
        } else if !visible && removeIfHidden {
            EmptyView()
        } else {
            self.hidden()
        }
    }
}
