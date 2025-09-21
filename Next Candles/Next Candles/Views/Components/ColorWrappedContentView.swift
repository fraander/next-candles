//
//  ColorWrappedContent.swift
//  WineBrowser
//
//  Created by Frank Anderson on 5/18/25.
//

import SwiftUI

struct ColorWrappedContentView<Content: View>: View {
    // Stretchy header based on [video](https://www.youtube.com/watch?v=_H5xLoFJ2jM&list=LL&index=4)
    @State private var offset: CGFloat = 0
    @State private var textHeight: CGFloat = 0
    
    private var headerHeight: CGFloat = 160
    private var offsetUpLimit: CGFloat = 55
    
    private var header: some View {
        Rectangle()
            .fill(color.gradient)
    }
    
    var color: Color
    var content: Content
    var footer: Bool
    
    init(
        color: Color = .accentColor,
        footer: Bool = false,
        headerHeight: CGFloat = 160,
        headerOffsetLimit: CGFloat = 55,
        @ViewBuilder content: () -> Content
    ) {
        self.color = color
        self.content = content()
        self.footer = footer
        self.headerHeight = headerHeight
        self.offsetUpLimit = headerOffsetLimit
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                header
                    .allowsHitTesting(false)
                    .frame(height: headerHeight + max(0, -2 * offset))
                    .frame(maxHeight: .infinity, alignment: .top)
                    .clipped()
                    .transformEffect(
                        .init(translationX: 0, y: offset < 0 ? min(0, offset) : max(-offsetUpLimit, -offset)
                             )
                    )
                
                ScrollView {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: headerHeight)
                        
                        VStack(alignment: .leading) {
                            content
                        }
                        .readSize { newSize in
                            textHeight = newSize.height
                        }
                    }
                }
                .onScrollGeometryChange(for: CGFloat.self) { geo in
                    geo.contentOffset.y + geo.contentInsets.top
                } action: { oldValue, newValue in
                    offset = newValue
                }
                
                if footer {
                    if textHeight < geo.size.height - headerHeight + offsetUpLimit {
                        header
                            .rotationEffect(.init(degrees: 180))
                            .allowsHitTesting(false)
                            .frame(height:
                                    max(min(geo.size.height - headerHeight + offsetUpLimit,
                                            geo.size.height - headerHeight - textHeight /*- 20*/ + offset
                                           ), 0)
                            )
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .clipped()
                    }
                }
            }
        }
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .background(.regularMaterial)
    }
}

#Preview {
    NavigationView {
        ColorWrappedContentView {
            Text("Wine.exampleCabernet.description")
                .padding()
                .toolbar {
                    Button("Favorite", systemImage: "star") {}
                        .foregroundStyle(.white)
                }
                .background(Color.cyan)
                .offset(y: -25)
        }
        .tint(.white)
    }
    .applyEnvironment()
}
