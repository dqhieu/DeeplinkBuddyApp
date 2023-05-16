//
//  DeeplinkDetailView.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 14/09/2022.
//

import SwiftUI
import CoreData
import Foundation
import Mixpanel

struct DeeplinkDetailView: View {

  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) private var presentationMode
  @AppStorage("showConsoleLog") var showConsoleLog = false
  @AppStorage("didShowQRCodeTooltip") var didShowQRCodeTooltip = false

  @State var deeplinkValue = ""
  @State var deeplinkName = ""
  @State var showingDeleteAert = false
  @State var showingDeleteParamAert = false
  @State var output = ""
  @State var urlComponents: URLComponents? = nil
  @State var isDeleted = false
  @State var showQRCode = false
  @State var showQRCodeTooltip = false

  @State private var logHeight: CGFloat = 100

  @State var disabledQueryItems: [URLQueryItem] = []

  #if os(macOS)
  @AppStorage("targetDevice") var targetDevice: TargetDevice = .simulator(udid: nil)
  #endif

  var deeplinkID: NSManagedObjectID

  init(deeplinkID: NSManagedObjectID) {
    self.deeplinkID = deeplinkID
  }

  var body: some View {
    if isDeleted {
      Text("Select a deeplink")
    } else {
      VStack(alignment: .leading) {
        ScrollView {
          HStack {
            Text("Name")
            TextField("", text: $deeplinkName)
              .autocorrectionDisabled()
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .onChange(of: deeplinkName) { newValue in
                guard let deeplink = viewContext.object(with: deeplinkID) as? Deeplink else { return }
                deeplink.name = newValue
                try? viewContext.save()
              }
          }
          .padding([.horizontal, .top])
          ZStack {
            #if os(iOS)
            Text(deeplinkValue)
              .padding(.all, 8)
            #endif
            if #available(iOS 16.0, macOS 13.0, *) {
              TextEditor(text: $deeplinkValue)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                #if os(macOS)
                .background(Color(NSColor.textBackgroundColor))
                .scrollIndicators(.hidden)
                .scrollDisabled(true)
                #endif
                .font(.body)
                .cornerRadius(6)
                .overlay(
                  RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                )
                .onChange(of: deeplinkValue) { newValue in
                  guard let deeplink = viewContext.object(with: deeplinkID) as? Deeplink else { return }
                  deeplink.value = newValue.cleaned
                  urlComponents = URLComponents(string: newValue)
                  try? viewContext.save()
                }
            } else {
              TextEditor(text: $deeplinkValue)
                .autocorrectionDisabled()
                #if os(iOS)
                .textInputAutocapitalization(.never)
                #endif
                #if os(macOS)
                .background(Color(NSColor.textBackgroundColor))
                #endif
                .font(.body)
                .cornerRadius(6)
                .overlay(
                  RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                )
                .onChange(of: deeplinkValue) { newValue in
                  guard let deeplink = viewContext.object(with: deeplinkID) as? Deeplink else { return }
                  deeplink.value = newValue.cleaned
                  urlComponents = URLComponents(string: newValue)
                  try? viewContext.save()
                }
            }

            HStack {
              Text("Enter your deeplink here")
                .foregroundColor(.secondary)
                .padding(.leading, 4)
                .allowsHitTesting(false)
              Spacer()
            }
            .hidden(!deeplinkValue.isEmpty)
          }
          .padding(.horizontal)
          VStack {
            SchemeAndHostView(urlComponent: $urlComponents)
            QueryItemsView(
              queryItems: Binding(
                get: { urlComponents?.queryItems ?? [] },
                set: { urlComponents?.queryItems = $0 }
              ),
              disabledQueryItems: $disabledQueryItems
            )
            .onChange(of: urlComponents) { newValue in
              guard let deeplink = viewContext.object(with: deeplinkID) as? Deeplink else { return }
              deeplink.value = urlComponents?.url?.absoluteString ?? deeplink.value
              deeplinkValue = deeplink.value
              try? viewContext.save()
            }
            if let scheme = urlComponents?.scheme, !scheme.isEmpty  {
              HStack {
                Button {
                  let paramCount = (urlComponents?.queryItems?.count ?? 0) + 1
                  Tracker.addParam(count: paramCount)
                  if deeplinkValue.contains("?") {
                    if let component = urlComponents, component.queryItems?.isEmpty ?? true {
                      deeplinkValue.append("param\(paramCount)=value\(paramCount)")
                    } else {
                      deeplinkValue.append("&param\(paramCount)=value\(paramCount)")
                    }
                  } else {
                    deeplinkValue.append("?param\(paramCount)=value\(paramCount)")
                  }
                } label: {
                  Text("Add param")
                    .help("Add a new parameter to the deeplink")
                }
                Spacer()
                if let component = urlComponents, !(component.queryItems?.isEmpty ?? true) {
                  Button {
                    if areAllParamsDiabled {
                      Tracker.enableAllParams(count: component.queryItems?.count ?? 0)
                      disabledQueryItems.removeAll()
                    } else {
                      Tracker.disableAllParams(count: component.queryItems?.count ?? 0)
                      urlComponents?.queryItems?.forEach { item in
                        if !disabledQueryItems.contains(where: { $0 == item }) {
                          disabledQueryItems.append(item)
                        }
                      }
                    }
                  } label: {
                    Text(areAllParamsDiabled ? "Enable all params" : "Disable all params")
                      .help(areAllParamsDiabled ? "Enable all params" : "Disable all params")
                  }
                  Button {
                    DispatchQueue.main.async {
                      NSApp.keyWindow?.makeFirstResponder(nil)
                    }
                    showingDeleteParamAert.toggle()
                  } label: {
                    Text("Remove all params")
                      .foregroundColor(.red)
                      .help("Remove all parameters of the deeplink")
                  }
                  .alert(isPresented: $showingDeleteParamAert) {
                    Alert(
                      title: Text("Are you sure to delete all parameters?"),
                      message: Text("This action cannot be undone"),
                      primaryButton: .destructive(Text("Yes")) {
                        DispatchQueue.main.async {
                          NSApp.keyWindow?.makeFirstResponder(nil)
                          DispatchQueue.main.async {
                            Tracker.removeAllParams(count: urlComponents?.queryItems?.count ?? 0)
                            urlComponents?.queryItems?.removeAll()
                          }
                        }
                      },
                      secondaryButton: .cancel()
                    )
                  }
                }
              }
            }
          }
          .padding(.horizontal)
          Spacer(minLength: 16)
        }
        #if os(macOS)
        VStack(spacing: 0) {
          Divider()

          HStack {
            Button {
              showConsoleLog.toggle()
            } label: {
              Image(systemName: "square.bottomhalf.filled")
            }
            .buttonStyle(.borderless)
            .padding(.all, 4)
            .help(showConsoleLog ? "Hide console log" : "Show console log")
            Text("Console")
            Spacer()
          }
          if showConsoleLog {
            TextEditor(text: .constant(output))
              .frame(height: logHeight)
              .textFieldStyle(PlainTextFieldStyle())
              .background(Color(.labelColor).environment(\.colorScheme, .light))
              .foregroundColor(.white)
          }
        }
        #endif
      }
      .toolbar {
        ToolbarItem(placement: .navigation) {
#if os(iOS)
          Link(
            destination: URL(string: deeplinkValue.cleaned) ?? URL(string: "https://deeplinkbuddy.com")!,
            label: {
              Text("\(Image(systemName: "play.fill")) Run")
            }
          )
          .disabled(URL(string: deeplinkValue.cleaned) == nil)
#endif
#if os(macOS)
          Button {
            runDeeplink()
          } label: {
            Image(systemName: "play.fill")
          }
          .disabled(URL(string: deeplinkValue.cleaned) == nil)
          .help("Run the deeplink (⌘R)")
          .keyboardShortcut("R")
#endif
        }
#if os(macOS)
        ToolbarItem(placement: .primaryAction) {
          if #available(iOS 16.0, macOS 13.0, *) {
            ShareLink(item: deeplinkValue.cleaned)
          }
        }
        ToolbarItem(placement: .primaryAction) {
          Button {
            Tracker.showQRCode()
            showQRCode = true
          } label: {
            Image(systemName: "qrcode")
          }
          .help("Show QR code")
          .popover(isPresented: $showQRCode) {
            if let image = QRCodeGenerator().generateQR(
              codeString: deeplinkValue,
              backgroundColor: CIColor.white,
              foregroundColor: CIColor.black
            ) {
              Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .padding()
            } else {
              Text("Failed to generate QR code, please try again")
                .padding()
            }
          }
          .popover(isPresented: $showQRCodeTooltip, arrowEdge: .bottom) {
            Text("You can generate a QR code from the deeplink by tapping this button")
              .padding()
          }
        }
        ToolbarItem(placement: .primaryAction) {
          Button {
            showingDeleteAert.toggle()
          } label: {
            Image(systemName: "trash")
          }
          .help("Remove the deeplink")
          .alert(isPresented: $showingDeleteAert) {
            Alert(
              title: Text("Do you want to delete the deeplink?"),
              message: Text("This action cannot be undone"),
              primaryButton: .destructive(Text("Yes")) {
                let object = viewContext.object(with: deeplinkID)
                viewContext.delete(object)
                try? viewContext.save()
                isDeleted = true
                Tracker.removeDeeplink()
              },
              secondaryButton: .cancel()
            )
          }
        }
        ToolbarItem(placement: .navigation) {
          TargetDeviceView()
        }
#endif
      }
      .onAppear {
        guard let deeplink = viewContext.object(with: deeplinkID) as? Deeplink else { return }
        deeplinkValue = deeplink.value
        deeplinkName = deeplink.name
        urlComponents = URLComponents(string: deeplinkValue)
        #if os(macOS)
        if !didShowQRCodeTooltip {
          didShowQRCodeTooltip = true
          showQRCodeTooltip = true
        }
        #endif
      }
      .navigationTitle("")
    }
  }

  func runDeeplink() {
    #if os(macOS)
    let targetDeviceName: String = {
      if targetDevice.isSimulator {
        return SimulatorManager.shared.findTargetSimulatorName(targetDevice.rawValue)
      }
      return "My Mac"
    }()
    Tracker.runDeeplink(targetDevice: targetDeviceName)
    var _urlComponents = urlComponents
    disabledQueryItems.forEach { item in
      _urlComponents?.queryItems?.removeAll(where: { $0.name == item.name })
    }
    let deeplink = (_urlComponents?.url?.absoluteString ?? deeplinkValue).cleaned
    output = "Running \(deeplink) on \(targetDeviceName)...\n"
    switch targetDevice {
    case .mac:
      if let url = URL(string: deeplink) {
        NSWorkspace.shared.open(url)
      }
    case .simulator(let udid):
      DispatchQueue.global(qos: .background).async {
        let _output = SimulatorManager.shared.runDeeplink(deeplink, simulatorUDID: udid ?? "booted")
        DispatchQueue.main.async {
          self.output += _output
        }
      }
    }
    #endif
  }

  var areAllParamsDiabled: Bool {
    return disabledQueryItems.count == urlComponents?.queryItems?.count
  }
}

struct DeeplinkDetailView_Previews: PreviewProvider {
  static var previews: some View {
    DeeplinkDetailView(deeplinkID: NSManagedObjectID())
  }
}

extension String {
  var cleaned: String {
    return self.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
  }
}

#if os(macOS)
extension NSTextView {
  open override var frame: CGRect {
    didSet {
      backgroundColor = .clear //<<here clear
      drawsBackground = true
    }
  }
}
#endif

extension View {
  @ViewBuilder public func hidden(_ shouldHide: Bool) -> some View {
    switch shouldHide {
    case true: self.hidden()
    case false: self
    }
  }
}

extension View {
  /// Applies the given transform if the given condition evaluates to `true`.
  /// - Parameters:
  ///   - condition: The condition to evaluate.
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
