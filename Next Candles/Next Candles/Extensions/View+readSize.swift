//
//  SizePreferenceKey.swift
//  Tristy
//
//  Created by Frank Anderson on 6/12/25.
//


//
//  View+readSize.swift
//  WineBrowser
//
//  Created by Frank Anderson on 5/18/25.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {} // No reducing; use most recent caller.
}

extension View {
    /// Read the size of the wrapped view.
    ///
    /// # Usage
    /// ```swift
    /// @State var childSize
    /// var body: some View {
    ///     ChildView()
    ///         .readSize { newSize in
    ///             childSize = newSize
    ///         }
    /// }
    /// ```
    /// - Parameter onChange: What action to perform with the found size.
    /// - Returns: Size of the wrapped view.
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}
