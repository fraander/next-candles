//
//  CustomStepper.swift
//  Next Candles
//
//  Created by Frank Anderson on 9/12/22.
//

import SwiftUI
import Combine


struct ButtonPress: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

struct StepperButton<Content: View>: View {
    @State private var isPressed = false
    let action: () -> Void
    var label: () -> Content
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(isPressed ? Color(uiColor: UIColor.systemFill) : Color.clear)
                .cornerRadius(8.0)
            
            Button(action: action, label: label)
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .pressEvents {
                    // On press
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                } onRelease: {
                    withAnimation {
                        isPressed = false
                    }
                }
        }
    }
}

//  Written by SerialCoder.dev
extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(ButtonPress(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}

struct CustomStepper: View {
    
    // TODO: create accelerated increase in steps when held down
    
    enum Field {
        case typing, none
    }
    
    @Binding var value: Double
    let lower: Double
    let upper: Double
    let increment: Double
    let tintColor: Color
    
    @FocusState private var focused: Field?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(uiColor: UIColor.tertiarySystemFill))
                .cornerRadius(10.0)
            
            HStack(alignment: .center, spacing: 0) {
                StepperButton<Image> {
                    if value > lower {
                        value -= increment
                    }
                } label: {
                    Image(systemName: "minus")
                }

                Divider()
                    .padding(.vertical, 8)
                
                
                TextField("", value: $value, format: .number)
                    .submitLabel(.done)
                    .keyboardType(.numberPad)
//                    .onReceive(Just(value)) { newValue in
//                        if lower < newValue && newValue < upper {
//                            value = newValue
//                        }
//                    } // TODO: fix veritification for typed entries; values should be within range
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .font(.system(.body, design: .monospaced, weight: .regular))
                    .tint(tintColor)
                    .foregroundColor(tintColor)
                    .focused($focused, equals: .typing)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                    .padding(.vertical, 8)
                
                StepperButton<Image> {
                    if value < upper {
                        value += increment
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .frame(width: 160, height: 40)
    }
}

struct CustomStepper_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomStepper(value: .constant(200), lower: 0, upper: 365, increment: 1.0, tintColor: Color.purple)
//            Stepper("Title", value: .constant(120), in: 0...365)
        }
    }
}
