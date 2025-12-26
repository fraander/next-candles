//
//  Settings.swift
//  Next Candles
//
//  Created by Frank Anderson on 7/4/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(Router.self) var router
    @Environment(NotificationManager.self) var notifs
    @Environment(ContactImportManager.self) var importer
    @Environment(\.modelContext) var modelContext
    
    @State var showAddManuallySheet = false
    @Namespace var namespace
    
    @AppStorage(S.monthTopKey) var monthTop = S.monthTopDefault
    @AppStorage(S.highlightRangeKey) var highlightRange = S.highlightRangeDefault
    @AppStorage(S.monthIndexKey) var monthIndex = S.monthIndexDefault
    @AppStorage(S.emptyMonthSectionKey) var emptyMonthSection = S.emptyMonthSectionDefault
    
    @AppStorage(S.notificationIndicatorsKey) var notificationIndicators = S.notificationIndicatorsDefault
    
    @Query var contacts: [Contact]
    
    @State var showRemoveNotifsConfirmation = false
    @State var showHideConfirmation = false
    @State var showDeleteAllConfirmation = false
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink {
                        HiddenBirthdaysView()
                    } label: {
                        Label("Hidden birthdays", systemImage: "eye.slash.fill")
                            .labelStyle(.tintedIcon(.orange))
                            .symbolColorRenderingMode(.gradient)
                    }
                }
                
                //
                
                Section {
                    
                    Button("Import from Contacts", systemImage: "square.and.arrow.down") {
                        Task { await importer.importContacts(modelContext: modelContext, showAlert: true) }
                    }
                        .labelStyle(.tintedIcon(.cyan))
                        .symbolColorRenderingMode(.gradient)
                    
                    Button("Add Contact manually", systemImage: "person.crop.circle.badge.plus") {
                        showAddManuallySheet.toggle()
                    }
                        .labelStyle(.tintedIcon(.secondary))
                        .symbolColorRenderingMode(.gradient)
                        .matchedTransitionSource(id: "addmanuallysheet", in: namespace)
                        .sheet(isPresented: $showAddManuallySheet) { AddManuallySheet()
                                .navigationTransition(.zoom(sourceID: "addmanuallysheet", in: namespace))
                        }
                }
                
                //
                
                Section {
                    Toggle(isOn: $notificationIndicators) {
                        Label("Notification indicators", systemImage: "bell.badge")
                            .labelStyle(.tintedIcon(.orange))
                            .symbolColorRenderingMode(.gradient)
                    }
                    .tint(.orange)
                    
                    LabeledContent {
                        let highlightRangeBinding = Binding<String>(
                            get: { String(highlightRange) },
                            set: { highlightRange = Int($0) ?? 0 }
                        )
                        
                        HStack {
                            TextField("#", text: highlightRangeBinding)
                                .numbersOnly(
                                    highlightRangeBinding,
                                    includeDecimal: false
                                )
                                .frame(width: 32)
                            Text("days")
                        }
                    } label: {
                        Label("Highlight range", systemImage: "highlighter")
                            .labelStyle(.tintedIcon(.accentColor))
                            .symbolColorRenderingMode(.gradient)
                    }
                    
//                    Picker(selection: $monthTop) {
//                        Text("Current month").tag(S.MonthTopOption.current)
//                        Text("January").tag(S.MonthTopOption.january)
//                    } label: {
//                        Label("Month on top", systemImage: "inset.filled.tophalf.rectangle")
//                            .labelStyle(.tintedIcon(.indigo))
//                            .symbolColorRenderingMode(.gradient)
//                    }
                    
                    Picker(selection: $monthIndex) {
                        Text("Dash empty months").tag(S.MonthIndexOption.hashed)
                        Text("Show all").tag(S.MonthIndexOption.showAll)
                        Text("Hidden").tag(S.MonthIndexOption.hidden)
                    } label: {
                        Label("Month index", systemImage: "calendar.day.timeline.right")
                            .labelStyle(.tintedIcon(.brown))
                            .symbolColorRenderingMode(.gradient)
                    }
                    
                    Picker(selection: $emptyMonthSection) {
                        Text("Shown").tag(S.EmptyMonthSectionOption.shown)
                        Text("Hidden").tag(S.EmptyMonthSectionOption.hidden)
                    } label: {
                        Label("Empty month sections", systemImage: "text.line.magnify")
                            .labelStyle(.tintedIcon(.green.mix(with: .brown, by: 0.25)))
                            .symbolColorRenderingMode(.gradient)
                    }
                }
                
                //
                
                Section {
                    Button("Remove all notifications", systemImage: "bell.slash") {
                        showRemoveNotifsConfirmation = true
                    }
                    .labelStyle(.tintedIcon(.secondary))
                    .symbolColorRenderingMode(.gradient)
                    .confirmationDialog(
                        "Are you should you would like to remove all notifications?",
                        isPresented: $showRemoveNotifsConfirmation,
                        titleVisibility: .visible,
                        actions: { Button("Remove all", role: .destructive) {
                            Task {
                                await notifs.removePendingNotificationRequests(withIdentifiers: notifs.pendingRequests.map(\.identifier))
                            }
                        } },
                        message: { Text("This cannot be easily reversed.") }
                    )
                    
                    Button("Hide all contacts from Next Candles", systemImage: "eye.slash") {
                        showHideConfirmation = true
                        
                    }
                    .labelStyle(.tintedIcon(.orange))
                    .symbolColorRenderingMode(.gradient)
                    .confirmationDialog(
                        "Are you should you would like to mark all Contacts as Hidden?",
                        isPresented: $showHideConfirmation,
                        titleVisibility: .visible,
                        actions: { Button("Hide all", role: .confirm) {
                            contacts.forEach { $0.hidden = true }
                        } },
                        message: { Text("This cannot be easily reversed.") }
                    )
                    
                    Button("Delete all contacts from Next Candles", systemImage: "trash") {
                        showDeleteAllConfirmation = true
                    }
                    .labelStyle(.tintedIcon(.red))
                    .symbolColorRenderingMode(.gradient)
                    .confirmationDialog(
                        "Are you should you would like to delete all Contacts from Next Candles?",
                        isPresented: $showDeleteAllConfirmation,
                        titleVisibility: .visible,
                        actions: { Button("Delete all", role: .destructive) {
                            contacts.forEach { modelContext.delete($0) }
                        } },
                        message: { Text("Deleting from Next Candles does not delete this person from the Contacts app.") }
                    )
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

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            SettingsView()
        }
        .applyEnvironment(prePopulate: true)
}
