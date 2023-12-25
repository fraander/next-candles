//
//  UIContactEditorRepresentabl.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/25/23.
//

import SwiftUI
import ContactsUI

struct UIContactEditorRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        CNContactViewController(for: CNContact())
    }
}

#Preview {
    NavigationView {
        Text("")
            .sheet(isPresented: .constant(true)) {
                UIContactEditorRepresentable()
            }
    }
}
