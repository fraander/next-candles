//
//  AddManuallyView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI

enum Field {
    case given, family, nickname
}

struct AddManuallyView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @FocusState var focus: Field?
    
    @State var givenName = ""
    @State var familyName = ""
    @State var nickname = ""
    
    @State var month: Int = 1
    @State var day: Int = 1
    @State var year: Int = -1
    
    var body: some View {
        NavigationView {
            VStack {
                
                Form {
                    Section("Name") {
                        TextField("Given name", text: $givenName)
                            .focused($focus, equals: .given)
                            .submitLabel(.next)
                            .onSubmit {
                                if (!givenName.isEmpty) {
                                    focus = .family
                                }
                            }
                        TextField("Family name", text: $familyName)
                            .onSubmit {
                                focus = nil
                            }
                            .submitLabel(.done)
                            .focused($focus, equals: .family)
                        
                        TextField("Nickname", text: $nickname)
                            .onSubmit {
                                focus = nil
                            }
                            .submitLabel(.done)
                            .focused($focus, equals: .nickname)
                    }
                    
                    Section("Birthday") {
                        Picker("Month", selection: $month) {
                            ForEach(1...12, id: \.self) { i in
                                Text("\(Calendar.current.monthSymbols[i - 1])").tag(i)
                                    .onTapGesture {
                                        month = i
                                    }
                            }
                        }
                        Picker("Day", selection: $day) {
                            ForEach(1...daysInMonth(m: month), id: \.self) { i in
                                Text("\(i)").tag(i)
                                    .onTapGesture {
                                        day = i
                                    }
                            }
                        }
                        Picker("Year", selection: $year) {
                            Text("Unsure")
                                .tag(-1)
                            ForEach(1900...currentYear(), id: \.self) { i in
                                Text(verbatim: "\(i)").tag(i)
                                    .onTapGesture {
                                        year = i
                                    }
                            }
                        }
                    }
                    
                    
                }
                .overlay {
                    VStack {
                        Spacer()
                        Button("Add Birthday", systemImage: "person.fill.badge.plus") {
                            
                            if (givenName.isEmpty) {
                                focus = .given
                            } else {
                                let new = Contact(givenName: givenName, familyName: familyName.isEmpty ? nil : familyName, nickname: nickname.isEmpty ? nil : nickname, month: month, day: day, year: year == -1 ? nil : year)
                                modelContext.insert(new)
                                dismiss()
                            }
                            
                        }
                        .disabled(givenName.isEmpty)
                        .bold()
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
                
                
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                #else
                ToolbarItem {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                #endif
            }
            .navigationTitle("Add Birthday")
        }
    }
    
    func daysInMonth(m: Int? = -1) -> Int {
        switch m {
        case 4, 6, 9, 11: return 30
        case 2: return 29
        default: return 31
        }
    }
    
    func currentYear() -> Int {
        return Calendar.current.component(.year, from: Date())
    }
}

#Preview {
    AddManuallyView()
}
