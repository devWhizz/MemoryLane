//
//  ImagePicker.swift
//  MemoryLane
//
//  Created by martin on 01.02.24.
//

import Foundation
import UIKit
import SwiftUI
import PhotosUI


// SingleImagePicker using PHPicker
struct SingleImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Binding var isPickerShowing: Bool
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIViewController(context: Context) -> some UIViewController {
        // Configure PHPicker
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        // Allow only one image to be selected
        configuration.selectionLimit = 1
        
        // Create PHPickerViewController
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        
        // Set the accent color based on the color scheme
        picker.view.tintColor = colorScheme == .dark ? .orange : .systemBlue
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Necessary function, but not needed in this case
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    // Coordinator class to handle events from PHPickerViewController
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: SingleImagePicker
        
        init(_ parent: SingleImagePicker) {
            self.parent = parent
        }
        
        // Called when the user picks an image
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let itemProvider = results.first?.itemProvider,
               itemProvider.canLoadObject(ofClass: UIImage.self) {
                // Load the selected image
                itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        // Update the selected image in the parent asynchronously on the main thread
                        DispatchQueue.main.async {
                            self.parent.selectedImage = image
                        }
                    }
                }
            }
            
            // Close the image picker
            parent.isPickerShowing = false
        }
    }
}

