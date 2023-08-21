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
            #if os(iOS)
                .fill(isPressed ? Color(uiColor: UIColor.systemFill) : Color.clear)
            #endif
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
    
    @State var valueBuffer: Double = 0.0
    
    @FocusState private var focused: Field?
    
    var body: some View {
        ZStack {
            Rectangle()
#if os(iOS)
                .fill(Color(uiColor: UIColor.tertiarySystemFill))
            #endif
                .cornerRadius(10.0)
            
            HStack(alignment: .center, spacing: 0) {
                StepperButton<Image> { // TODO: button size smaller than shape size
                    if value > lower {
                        value -= increment
                    }
                } label: {
                    Image(systemName: "minus")
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                TextField("", value: $valueBuffer, format: .number)
                    .focused($focused, equals: .typing)
                    .submitLabel(.done)
#if os(iOS)
                    .keyboardType(.numberPad)
                #endif
                    .onSubmit {
                        if (lower..<upper).contains(valueBuffer) {
                            value = valueBuffer
                        } else {
                            valueBuffer = value
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .font(.system(.body, design: .monospaced, weight: .regular))
                    .tint(tintColor)
                    .foregroundColor(tintColor)
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
        .frame(width: 180, height: 40)
        .task {
            valueBuffer = value
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
