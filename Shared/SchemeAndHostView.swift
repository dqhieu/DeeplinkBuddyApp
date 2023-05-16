//
//  SchemeAndHostView.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 21/09/2022.
//

import SwiftUI

struct SchemeAndHostView: View {

  @Binding var urlComponent: URLComponents?

  var body: some View {
    LazyVGrid(
      columns: [GridItem(.flexible(minimum: 100, maximum: 150)), GridItem(.flexible(minimum: 100))],
      alignment: .leading,
      spacing: 8
    ) {
      Text("Scheme")
      TextField("", text: Binding(
        get: { urlComponent?.scheme ?? "" },
        set: {
          if $0.isEmpty {
            urlComponent?.scheme = "scheme"
          } else {
            urlComponent?.scheme = String($0.unicodeScalars.filter(CharacterSet.letters.contains))
          }
        }
      ))
      .autocorrectionDisabled()
      #if os(iOS)
      .textInputAutocapitalization(.never)
      #endif
      .textFieldStyle(RoundedBorderTextFieldStyle())
      Text("Host")
      TextField("", text: Binding(
        get: { urlComponent?.host ?? "" },
        set: { urlComponent?.host = $0.replacingOccurrences(of: " ", with: "") }
      ))
      .autocorrectionDisabled()
#if os(iOS)
      .textInputAutocapitalization(.never)
#endif
      .textFieldStyle(RoundedBorderTextFieldStyle())
    }
  }
}
