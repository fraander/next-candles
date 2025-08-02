//
//  Settings.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(Router.self) var router
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink {
                        Text("Hidden birthdays")
                    } label: {
                        Label("Hidden birthdays", systemImage: "eye.slash.fill")
                            .labelStyle(.tintedIcon(.orange))
                            .symbolColorRenderingMode(.gradient)
                    }
                }
                
                //
                
                Section {
                    
                    Button("Import from Contacts", systemImage: "square.and.arrow.down") {}
                        .labelStyle(.tintedIcon(.cyan))
                        .symbolColorRenderingMode(.gradient)
                    
                    Button("Add Manually", systemImage: "person.crop.circle.badge.plus") {}
                        .labelStyle(.tintedIcon(.secondary))
                        .symbolColorRenderingMode(.gradient)
                }
                
                //
                
                Section {
                    Picker(selection: .constant("Current month")) {
                        Text("Current month").tag("Current month")
                        Text("January").tag("January")
                    } label: {
                        Label("Month on top", systemImage: "inset.filled.tophalf.rectangle")
                            .labelStyle(.tintedIcon(.indigo))
                            .symbolColorRenderingMode(.gradient)
                    }
                    
                    LabeledContent {
                        TextField("days", text: .constant("20"))
                            .frame(width: 32)
                    } label: {
                        Label("Highlight range", systemImage: "highlighter")
                            .labelStyle(.tintedIcon(.accentColor))
                            .symbolColorRenderingMode(.gradient)
                    }

                    Toggle("Confirm changes", systemImage: "circle.lefthalf.striped.horizontal", isOn: .constant(true))
                        .labelStyle(.tintedIcon(.teal))
                        .symbolColorRenderingMode(.gradient)
                        .tint(.accentColor)
                    
                    Picker(selection: .constant("Hash empty months")) {
                        Text("Hash empty months").tag("Hash empty months")
                        Text("Show all").tag("Show all")
                        Text("Hidden").tag("Hidden")
                    } label: {
                        Label("Month index", systemImage: "calendar.day.timeline.right")
                            .labelStyle(.tintedIcon(.brown))
                            .symbolColorRenderingMode(.gradient)
                    }
                }
                
                //
                
                Section {
                    Button("Remove all notifications", systemImage: "bell.slash") {}
                        .labelStyle(.tintedIcon(.secondary))
                        .symbolColorRenderingMode(.gradient)
                    
                    Button("Hide all contacts from Next Candles", systemImage: "eye.slash") {}
                        .labelStyle(.tintedIcon(.orange))
                        .symbolColorRenderingMode(.gradient)
                    
                    Button("Delete all contacts from Next Candles", systemImage: "trash") {}
                        .labelStyle(.tintedIcon(.red))
                        .symbolColorRenderingMode(.gradient)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Close", systemImage: "chevron.down", role: .close) { router.popToHome() }
                }
            }
        }
    }
}
