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

    var body: some View {
        RealityView { content, attachments in
            content.add(rootEntity)
            configureAttachments(attachments)
        } update: { content, attachments in
            updateAttachmentVisibility(attachments)
        } attachments: {
            Attachment(id: "mainHeartView") {
                  //2. Define the SwiftUI View
                  Text("Testestest")
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
            
            rootEntity.addChild(viewEntity)
        }
    }
    
    /// Update the visibility of the attachment views
    fileprivate func updateAttachmentVisibility(_ attachments: RealityViewAttachments) {
        if let heartAttachment = attachments.entity(for: "mainHeartView") {
            heartAttachment.isEnabled = true
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
