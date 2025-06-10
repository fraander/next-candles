//
//  ContactMonthsListView.swift
//  Next Candles
//
//  Created by Frank Anderson on 11/25/23.
//

import SwiftUI
import SwiftData

struct AlertItem: Identifiable {
    typealias AlertAction = (title: String, action: () -> Void)
    
    let id: UUID = .init()
    let title: String
    let actions: [AlertAction]
    
    init(title: String, actions: [AlertAction] = []) {
        self.title = title
        self.actions = actions
    }
}

struct ContactsMonthListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var contacts: [Contact]
    @EnvironmentObject var settings: Settings
    
    @Binding var sheet: SheetType?
    
    init(month: Int, sheet: Binding<SheetType?>) {
        _contacts = Query(filter: #Predicate<Contact> { contact in
            return (contact.month == month) && (contact.day != nil) && (contact.hidden == false)
        }, sort: [SortDescriptor(\Contact.month), SortDescriptor(\Contact.day), SortDescriptor(\Contact.year)])
        _sheet = sheet
    }
    
    
    
    var body: some View {
        ForEach(contacts) { contact in
            Button {
                sheet = .contact(contact)
            } label: {
                ContactView(contact: contact)
                    .padding(.vertical, 5)
            }
            .id(contact.id)
        }
    }
}


#Preview {
    
    @Previewable @StateObject var settings: Settings = Settings.load()
    @Previewable @StateObject var alertRouter: AlertRouter = AlertRouter()
    @Previewable @StateObject var progressRouter: ProgressViewRouter = ProgressViewRouter()
    @Previewable @StateObject var notifsHelper: NotificationsHelper = .init()
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Contact.self, configurations: config)
    
    ContactListView()
        .modelContainer(container)
        .environmentObject(settings)
        .environmentObject(alertRouter)
        .environmentObject(progressRouter)
        .environmentObject(notifsHelper)
        .task {
            container.mainContext.insert(
                Contact(
                    identifier: "ID1234",
                    givenName: "John",
                    familyName: "Doe",
                    month: 2,
                    day: 4,
                    year: 2010,
                    phones: [],
                    emails: [],
                )
            )
        }
}
