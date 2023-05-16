//
//  QRCodeGenerator.swift
//  DeeplinkBuddy
//
//  Created by Dinh Quang Hieu on 30/11/2022.
//

import Foundation
#if os(macOS)
import AppKit
#endif

class QRCodeGenerator {

#if os(macOS)
  func generateQR(codeString: String, backgroundColor: CIColor, foregroundColor: CIColor) -> NSImage {
    var nsImage:NSImage!

    // Convert String to Data
    let codeData = codeString.data(using: String.Encoding.isoLatin1)

    // Create CIFilter object for CIQRCodeGenerator
    guard let qrFilter: CIFilter = CIFilter(name: "CIQRCodeGenerator") else { return nsImage }

    // Set the inputMessage for the codeData
    qrFilter.setValue(codeData, forKey: "inputMessage")

    // Create another CIFilter for setting foreground and background color
    guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nsImage }
    colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
    colorFilter.setValue(backgroundColor, forKey: "inputColor1") // Background color
    colorFilter.setValue(foregroundColor, forKey: "inputColor0") // Foreground color

    // Create an affine transformation for scaling the generated image
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    if let output = colorFilter.outputImage?.transformed(by: transform) {
      let rep = NSCIImageRep.init(ciImage: output)
      nsImage = NSImage(size: output.extent.size)
      nsImage.addRepresentation(rep)
    }

    // Return the created image
    return nsImage
  }

#endif

}
