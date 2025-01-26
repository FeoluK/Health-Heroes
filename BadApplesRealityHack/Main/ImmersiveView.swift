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
    let slideHeartCount = "slideHeart"
    
    @State var showSlide1 = true
    @State var showSlide2 = false
    @State var showSlide3 = false
    
    
    var body: some View {
        RealityView { content, attachments in
            content.add(rootEntity)
            rootEntity.addChild(heartRateAnchor)
            GameModeManager.shared.loadGame()
            configureAttachments(attachments)
        } update: { content, attachments in
            updateAttachmentVisibility(attachments)
            childAnchor.transform = Transform(matrix: WorldTrackingSessionManager.shared.getOriginFromDeviceTransform())
            
        } attachments: {
            Attachment(id: slideHeartCount) {
                ZStack {
                    Image("HeartFrame")
                        .resizable()
                        .frame(width: 200, height: 210)
                    Text("121")
                        .font(.extraLargeTitle)
                        .padding()
                }.frame(width: 200, height: 210).background(.clear)
              }
            
            Attachment(id: slide1View) {
                  Text("Every year, 5.5 million people worldwide die from strokes, making it one of the leading causes of death globally. Recognizing symptoms and acting quickly can save countless lives.")
                      .font(.extraLargeTitle)
                      .padding()
                      .glassBackgroundEffect()
              }
            
            Attachment(id: slide2View) {
                  Text("Many stroke-related deaths could be prevented if more people knew CPR (Cardiopulmonary Resuscitation).")
                      .font(.extraLargeTitle)
                      .padding()
                      .glassBackgroundEffect()
              }
            
            Attachment(id: slide3View) {
                  Text("As around 30-40% of cardiac arrests are fatal due to bystanders not acting. Learning CPR can double or triple survival chances in emergencies—every second counts!")
                      .font(.extraLargeTitle)
                      .padding()
                      .glassBackgroundEffect()
              }
        }
        .onAppear {
            configureSlideVisibility()
        }
    }
    
    func configureSlideVisibility() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showSlide1 = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                showSlide1 = false
                showSlide2 = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 16) {
                    showSlide2 = false
                    showSlide3 = true
                }
                
            }
        }
    }
    
    func configureAttachments(_ attachments: RealityViewAttachments) {
        if let viewEntity = attachments.entity(for: slideHeartCount) {            viewEntity.components.set(BillboardComponent())
            viewEntity.position = .init(x: 0.2, y: 1.1, z: -1)
            viewEntity.isEnabled = true
            heartRateAnchor.addChild(viewEntity)
        }
        if let viewEntity = attachments.entity(for: slide1View) {            viewEntity.components.set(BillboardComponent())
            viewEntity.position = .init(x: 0.2, y: 1, z: -1)
            viewEntity.isEnabled = true
            rootEntity.addChild(viewEntity)
        }
        if let viewEntity = attachments.entity(for: slide2View) {            viewEntity.components.set(BillboardComponent())
            viewEntity.position = .init(x: 0.2, y: 1, z: -1)
            viewEntity.isEnabled = true
            rootEntity.addChild(viewEntity)
        }
        if let viewEntity = attachments.entity(for: slide3View) {            viewEntity.components.set(BillboardComponent())
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
