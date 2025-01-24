//
//  ContentView.swift
//  Mobile
//
//  Created by Feolu Kolawole on 1/24/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showCamera = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Image(systemName: "stethoscope.circle.fill")
                    .imageScale(.large)
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("Medical Mystery")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Main menu buttons
                VStack(spacing: 20) {
                    NavigationLink(destination: CameraView()) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Start Diagnosis")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    // Additional buttons can go here
                    Button(action: {
                        // Add settings or other actions
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.gray.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
