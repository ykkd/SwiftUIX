//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A container view that recursively defines its content as a function of the content's size.
public struct IntrinsicSizeReader<Content: View>: View {
    private let content: (CGSize) -> Content

    @State private var size: CGSize = .zero
    
    public init(@ViewBuilder content: @escaping (CGSize) -> Content) {
        self.content = content
    }
        
    public var body: some View {
        content(size).background {
            GeometryReader { geometry in
                ZeroSizeView()
                    .onAppear {
                        self.size = geometry.size
                    }
                    .onChange(of: geometry.size) { newSize in
                        self.size = newSize
                    }
            }
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        }
    }
}

/// A container view that recursively defines its content as a function of the content's size.
public struct _IntrinsicGeometryValueReader<Content: View, Value: Equatable>: View {
    private let getValue: (CGRect) -> Value
    private let content: (Value) -> Content
    
    @State private var value: Value
    
    public init(
        _ value: KeyPath<CGRect, Value>,
        default defaultValue: Value,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.getValue = { $0[keyPath: value] }
        self.content = content
        self._value = .init(initialValue: defaultValue)
    }
    
    public init<T>(
        _ value: KeyPath<CGRect, T>,
        @ViewBuilder _ content: @escaping (Value) -> Content
    ) where Value == Optional<T> {
        self.getValue = { $0[keyPath: value] }
        self.content = content
        self._value = .init(initialValue: nil)
    }
    
    public var body: some View {
        content(value).background {
            GeometryReader { geometry in
                ZeroSizeView()
                    .onAppear {
                        self.value = getValue(geometry.frame(in: .global))
                    }
                    .onChange(of: geometry.frame(in: .global)) { frame in
                        self.value = getValue(frame)
                    }
            }
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        }
    }
}
