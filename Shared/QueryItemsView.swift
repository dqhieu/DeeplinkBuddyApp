//
//  QueryItemsView.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 21/09/2022.
//

import SwiftUI

struct QueryItemsView: View {

  @Binding var queryItems: [URLQueryItem]
  @Binding var disabledQueryItems: [URLQueryItem]

  var body: some View {
    VStack(spacing: 8) {
      LazyVGrid(
        columns: [GridItem(.flexible(minimum: 100, maximum: 150)), GridItem(.flexible(minimum: 100)), GridItem(.fixed(30)), GridItem(.fixed(30))],
        alignment: .leading,
        spacing: 8
      ) {
        ForEach(0..<queryItems.count, id: \.self) { index in
          QueryItemView(
            queryItem: $queryItems[index],
            isDisabled: disabledQueryItems.contains(where: { $0.name == queryItems[index].name }),
            onDisable: {
              if disabledQueryItems.contains(where: { $0.name == queryItems[index].name }) {
                Tracker.enableParam(count: queryItems.count)
                disabledQueryItems.removeAll(where: { $0.name == queryItems[index].name })
              } else {
                Tracker.disableParam(count: queryItems.count)
                disabledQueryItems.append(queryItems[index])
              }
            },
            onDelete: {
              Tracker.removeParam(count: queryItems.count - 1)
              queryItems.remove(at: index)
            })
        }
      }

    }
  }
}

struct QueryItemView: View {

  @Binding var queryItem: URLQueryItem
  var isDisabled: Bool

  var onDisable: () -> Void
  var onDelete: () -> Void

  var body: some View {
    TextField("", text: $queryItem.name)
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .autocorrectionDisabled()
      .foregroundColor(isDisabled ? .secondary : .primary)
#if os(iOS)
      .textInputAutocapitalization(.never)
#endif
    TextField("", text: Binding(
      get: { queryItem.value ?? "" },
      set: { queryItem.value = $0 }
    ))
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .autocorrectionDisabled()
      .foregroundColor(isDisabled ? .secondary : .primary)
#if os(iOS)
      .textInputAutocapitalization(.never)
#endif
    Button {
      onDisable()
    } label: {
      Image(systemName: isDisabled ? "eye.slash" : "eye")
    }
    .help(isDisabled ? "Enable param" : "Disable param")
    Button {
      // If the param is deleted while its textfield focused, the app will crash
      // so we have to call NSApp.keyWindow?.makeFirstResponder(nil) to resign as first responder
      DispatchQueue.main.async {
        NSApp.keyWindow?.makeFirstResponder(nil)
        DispatchQueue.main.async {
          onDelete()
        }
      }
    } label: {
      Image(systemName: "trash")
    }
    .help("Remove param")

  }
}
