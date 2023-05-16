//
//  ContentView.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 14/09/2022.
//

import SwiftUI
import CoreData
#if canImport(AppKit)
import AppKit
#endif

struct AllDeeplinksView: View {
  @Environment(\.managedObjectContext) private var viewContext

  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \Deeplink.createdDate, ascending: true)],
    animation: .default)
  private var items: FetchedResults<Deeplink>

  var body: some View {
    NavigationView {
      List {
        ForEach(items) { item in
          NavigationLink {
            DeeplinkDetailView(deeplinkID: item.objectID)
          } label: {
#if os(macOS)
            Text(item.name)
              .contextMenu {
                Button {
                  duplicate(from: item)
                } label: {
                  Text("Duplicate")
                }
                Button {
                  if let index = items.firstIndex(of: item) {
                    deleteItems(offsets: IndexSet(integer: index))
                  }
                } label: {
                  Text("Delete")
                }
              }
#endif
#if os(iOS)
            VStack(alignment: .leading) {
              Text(item.name)
              if !item.value.isEmpty {
                Text(item.value)
                  .font(.caption)
                  .foregroundColor(.secondary)
                  .lineLimit(1)
              }
            }
#endif
          }
        }
        .onDelete(perform: deleteItems)
      }
#if os(macOS)
      .frame(minWidth: 200)
#endif
      .toolbar {
#if os(iOS)
        ToolbarItem(placement: .navigationBarLeading) {
          EditButton()
        }
#endif
#if os(macOS)
        ToolbarItem(placement: .primaryAction) {
          Button(action: toggleSidebar) {
            Label("Toggle sidebar", systemImage: "sidebar.leading")
          }
          .help("Toggle sidebar")
        }
#endif
        ToolbarItem(placement: .automatic) {
          Button(action: addItem) {
            Label("Add deeplink", systemImage: "plus")
          }
          .help("Add new deeplink (⌘N)")
          .keyboardShortcut("N")
        }
      }
      if items.isEmpty {
        Text("Add a deeplink")
      } else {
        Text("Select a deeplink")
      }
    }
    .onAppear {
      #if os(macOS)
      NSWindow.allowsAutomaticWindowTabbing = false
      SimulatorManager.shared.refresh()
      #endif
    }
  }

  private func duplicate(from deeplink: Deeplink) {
    Tracker.duplicateDeeplink()
    let newItem = Deeplink(context: viewContext)
    newItem.createdDate = Date()
    newItem.name = deeplink.name
    newItem.value = deeplink.value
    try? viewContext.save()
  }

  private func addItem() {
    Tracker.createDeeplink()
    let newItem = Deeplink(context: viewContext)
    newItem.createdDate = Date()
    newItem.name = "New deeplink"

    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }

  private func deleteItems(offsets: IndexSet) {
    Tracker.removeDeeplink()
    offsets.map { items[$0] }.forEach(viewContext.delete)
    
    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }

  private func toggleSidebar() { // 2
#if os(macOS)
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
  }
}
