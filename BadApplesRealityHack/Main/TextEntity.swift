//
//  TextEntity.swift
//  BadApplesRealityHack
//
//  Created by Hunter Harris on 1/24/25.
//

import Foundation
import RealityKit
import SwiftUI

final class TextEntity: Entity, HasModel, HasCollision {
    
    /// Text properties
    @Published var currentText: String
    @Published var currentPosition: SIMD3<Float>
    @Published var selectedFontName: String
    @Published var fontWeight: UIFont.Weight
    private var fontSize: Float
    private var color: UIColor

    /// Initializer for the TextEntity
    init(text: String = "Sample Text",
         position: SIMD3<Float> = SIMD3<Float>(0, 0, 0),
         fontName: String = "Helvetica",
         fontWeight: UIFont.Weight = .regular,
         fontSize: Float = 8.0,
         color: UIColor = .white) {
        
        self.currentText = text
        self.currentPosition = position
        self.selectedFontName = fontName
        self.fontWeight = fontWeight
        self.fontSize = fontSize
        self.color = color
        
        super.init()
        
        Task {
            if let textEntity = await createTextEntity() {
                self.addChild(textEntity)
            }
        }
    }
    
    @MainActor @preconcurrency required init() {
        fatalError("init() has not been implemented")
    }
    
    /// Configures the text entity settings.
    func configureText(text: String, position: SIMD3<Float>, fontSize: Float = 8.0, color: UIColor = .white) {
        self.currentText = text
        self.currentPosition = position
        self.fontSize = fontSize
        self.color = color
        updateTextEntity()
    }

    /// Generates attributed text with the selected font and weight.
    private func createAttributedText() -> AttributedString {
        var attributedString = AttributedString(currentText)
        attributedString.font = .systemFont(ofSize: CGFloat(fontSize), weight: fontWeight)

        // Center-align the text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let alignmentAttributes = AttributeContainer([.paragraphStyle: paragraphStyle])
        attributedString.mergeAttributes(alignmentAttributes)

        return attributedString
    }

    /// Generates a text entity with the current settings.
    func createTextEntity() async -> ModelEntity? {
        let attributedText = createAttributedText()

        if #available(iOS 18.0, *) {
            var extrusionOptions = MeshResource.ShapeExtrusionOptions()
            extrusionOptions.extrusionMethod = .linear(depth: 2)
            extrusionOptions.chamferRadius = 0.1
            
            do {
                // Create the 3D text mesh
                let textMesh = try await MeshResource(extruding: attributedText, extrusionOptions: extrusionOptions)
                let material = SimpleMaterial(color: color, isMetallic: false)

                let textEntity = ModelEntity(mesh: textMesh, materials: [material])
                textEntity.generateCollisionShapes(recursive: true)
                textEntity.position = currentPosition

                return textEntity
            } catch {
                print("Failed to create 3D text mesh: \(error)")
                return nil
            }
        } else {
           return nil
        }
    }

    /// Updates the text entity with the current text and settings.
    private func updateTextEntity() {
        Task {
            // Remove existing child entities
            self.children.forEach { $0.removeFromParent() }
            
            // Create a new text entity
            if let updatedTextEntity = await createTextEntity() {
                self.addChild(updatedTextEntity)
            }
        }
    }
    
    /// Updates the text of the entity.
      func updateText(_ newText: String) {
          currentText = newText
          children.forEach { $0.removeFromParent() }
          Task {
              if let updatedTextEntity = await createTextEntity() {
                  self.addChild(updatedTextEntity)
              }
          }
      }
}
