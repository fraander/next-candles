//
//  ContactDetailView.swift
//  Next Candles
//
//  Created by Frank Anderson on 12/20/23.
//

import SwiftUI

struct ContactDetailView: View {
    
    let contact: Contact
    
    func action(systemName: String, text: String, bg: AnyGradient) -> some View {
        return Button { } label: {
            VStack {
                Image(systemName: systemName)
                    .foregroundStyle(.white)
                    .imageScale(.large)
                
                Text(text)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                    .offset(y: 2)
            }
            .frame(width: 80, height: 84)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(bg)
            }
        }
    }
    
    func wideAction(systemName: String, text: String, bg: AnyGradient) -> some View {
        return Button { } label: {
            HStack(spacing: 16) {
                VStack {
                    Image(systemName: systemName)
                        .foregroundStyle(.white)
                        .imageScale(.large)
                }
                .frame(width: 60, height: 60)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(bg)
                }
                
                Text(text)
                    .font(.system(.title3, design: .rounded, weight: .medium))
                    .foregroundStyle(.black.opacity(0.8))
                
                Spacer()
            }
            .padding(8)
            .background(.white)
            .cornerRadius(20)
        }
    }
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.pink.gradient)
                .ignoresSafeArea(.all, edges: .top)
                .frame(height: 180)
            
            Group {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white, .secondary)
                    .frame(width: 180, height: 180)
                    .background {
                        Circle().fill(.white)
                    }
                    .overlay {
                        Circle().stroke(.white, lineWidth: 12)
                    }
                
                
                Text(contact.name)
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                    .padding(.top, 12)
                
                Text((contact.birthdate ?? Date())
                    .formatted(
                        .dateTime
                            .day()
                            .month(
                                .wide
                            )
                    )
                )
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
                
                
                Divider()
                    .padding(.top, 12)
                
                HStack(spacing: 0) {
                    action(systemName: "phone.fill", text: "Call", bg: Color.green.gradient)
                    Spacer()
                    action(systemName: "message.fill", text: "Text", bg: Color.mint.gradient)
                    Spacer()
                    action(systemName: "bell.fill", text: "Notify", bg: Color.yellow.gradient)
                    Spacer()
                    action(systemName: "eye.slash.fill", text: "Hide", bg: Color.orange.gradient)
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                
                Divider()
                
                VStack(spacing: 12) {
                    wideAction(systemName: "person.text.rectangle.fill", text: "Show in Contacts", bg: Color.secondary.gradient)
                    
                    wideAction(systemName: "trash.fill", text: "Delete from Next Candles", bg: Color.pink.gradient)
                }
                .padding()
            }
            .offset(y: -120)
            
            Spacer()
        }
        .background {
            Rectangle()
                .fill(Color.white.gradient)
                .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

#Preview {
    ContactDetailView(contact: Contact())
}
