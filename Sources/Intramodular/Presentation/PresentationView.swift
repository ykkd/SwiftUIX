//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A view for presenting a stack of views.
///
/// Like `NavigationView`, but for modal presentation.
public struct PresentationView<Content: View>: View {
    private let content: Content

    @State private var _presenter: DynamicViewPresenter?

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
        content
            .environment(\._presenter, _presenter)
            ._resolveAppKitOrUIKitViewControllerIfAvailable()
            .onAppKitOrUIKitViewControllerResolution {
                self._presenter = $0
            }
        #else
        content
        #endif
    }
}
