//
//  CustomStepper.swift
//  Next Candles
//
//  Created by Frank Anderson on 9/12/22.
//

import SwiftUI

struct CustomStepper: View {
        
    enum Field {
        case typing, none
    }
    
    @Binding var value: Double
    let lower: Double
    let upper: Double
    let increment: Double
    let tintColor: Color
    
    @State var valueBuffer: String = ""
    
    @FocusState private var focused: Field?
    
    var body: some View {
        ZStack {
            Rectangle()
#if os(iOS)
                .fill(Color(uiColor: UIColor.tertiarySystemFill))
            #endif
                .cornerRadius(10.0)
            
            HStack(alignment: .center, spacing: 0) {
                Button { // TODO: button size smaller than shape size
                    if value > lower {
                        value -= increment
                    }
                } label: {
                    Image(systemName: "minus")
                        .padding()
                }
                .buttonRepeatBehavior(.enabled)
                .tint(tintColor)
                
                Divider()
                    .padding(.vertical, 8)
                
                TextField("", text: $valueBuffer)
                    .focused($focused, equals: .typing)
                    .submitLabel(.done)
#if os(iOS)
                    .keyboardType(.numberPad)
                    .numbersOnly($valueBuffer, allowedRange: lower ..< upper)
                #endif
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .font(.system(.body, design: .monospaced, weight: .regular))
                    .tint(tintColor)
                    .foregroundColor(tintColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                    .padding(.vertical, 8)
                
                Button {
                    if value < upper {
                        value += increment
                    }
                } label: {
                    Image(systemName: "plus")
                        .padding()
                }
                .buttonRepeatBehavior(.enabled)
                .tint(tintColor)
            }
        }
        .frame(width: 180, height: 40)
        .task {
            valueBuffer = String("\(value.rounded())".split(separator: ".").first ?? "0")
        }
    }
}

struct CustomStepper_Previews: PreviewProvider {
    
    @State static var value = 200.0
    
    static var previews: some View {
        VStack {
            CustomStepper(value: $value, lower: 0, upper: 365, increment: 1.0, tintColor: Color.purple)
//            Stepper("Title", value: .constant(120), in: 0...365)
        }
    }
}
