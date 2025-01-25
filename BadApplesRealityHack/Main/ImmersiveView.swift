//
//  ImmersiveView.swift
//  BadApplesRealityHack
//
//  Created by Hunter Harris on 1/24/25.
//

import _RealityKit_SwiftUI
import ARKit
import Foundation
import RealityKit
import simd
import Spatial
import SwiftUI

struct ImmersiveView: View {
    let slide1View = "slide1"
    let slide2View = "slide2"
    let slide3View = "slide3"
    let slide4View = "slide4"
    
    @State var showSlide1 = true
    @State var showSlide2 = false
    @State var showSlide3 = false
    
    
    var body: some View {
        RealityView { content, attachments in
            content.add(rootEntity)
            configureAttachments(attachments)
        } update: { content, attachments in
            // updateAttachmentVisibility(attachments)
        } attachments: {
            Attachment(id: slide1View) {
                  //2. Define the SwiftUI View
                  Text("Testestest")
                      .font(.extraLargeTitle)
                      .padding()
                      .glassBackgroundEffect()
              }
            
            Attachment(id: slide2View) {
                  //2. Define the SwiftUI View
                  Text("Horse horse horse")
                      .font(.extraLargeTitle)
                      .padding()
                      .glassBackgroundEffect()
              }
            
            Attachment(id: slide3View) {
                  //2. Define the SwiftUI View
                  Text("Cow cow cow cow")
                      .font(.extraLargeTitle)
                      .padding()
                      .glassBackgroundEffect()
              }
        }
    }
    
    func configureAttachments(_ attachments: RealityViewAttachments) {
        // Add the attachments to the wrist entity
        if let viewEntity = attachments.entity(for: "mainHeartView") {
            //brushSettingsAttachment.scale = [0.7, 0.7, 0.7]
            viewEntity.components.set(BillboardComponent())
            viewEntity.position = .init(x: 0.2, y: 1, z: -1)
            viewEntity.isEnabled = true
            rootEntity.addChild(viewEntity)
        }
    }
    
    /// Update the visibility of the attachment views
    fileprivate func updateAttachmentVisibility(_ attachments: RealityViewAttachments) {
        if let slide1 = attachments.entity(for: slide1View) {
            slide1.isEnabled = showSlide1
        }
        if let slide3 = attachments.entity(for: slide2View) {
            slide3.isEnabled = showSlide2
        }
        if let slide3 = attachments.entity(for: slide3View) {
            slide3.isEnabled = showSlide3
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}


@Observable
final class AttachmentsProvider {
    var attachments: [ObjectIdentifier: AnyView] = [:]
    var sortedTagViewPairs: [(tag: ObjectIdentifier, view: AnyView)] {
        attachments.map { key, value in
            (tag: key, view: value)
        }.sorted { $0.tag < $1.tag }
    }
}
