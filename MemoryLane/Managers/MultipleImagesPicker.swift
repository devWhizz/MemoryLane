//
//  ImagePicker.swift
//  MemoryLane
//
//  Created by martin on 05.02.24.
//

import Foundation
import UIKit
import SwiftUI
import PhotosUI


// MultipleImagesPicker using PHPicker
struct MultipleImagesPicker: UIViewControllerRepresentable {
    
    @Binding var selectedImages: [UIImage]
    @Binding var isPickerShowing: Bool
    
    // Set color scheme
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIViewController(context: Context) -> some UIViewController {
        // Configure PHPicker
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        // Allow up to 5 images to be selected
        configuration.selectionLimit = 10
        
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
        var parent: MultipleImagesPicker
        
        init(_ parent: MultipleImagesPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for result in results {
                let itemProvider = result.itemProvider
                
                guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
                    // Handle the absence of itemProvider, perhaps log an error
                    continue
                }
                
                // Load the selected image
                itemProvider.loadObject(ofClass: UIImage.self) { loadedImage, error in
                    if let image = loadedImage as? UIImage {
                        // Update the selected images in the parent asynchronously on the main thread
                        DispatchQueue.main.async {
                            self.parent.selectedImages.append(image)
                        }
                    }
                }
            }
            
            // Close the image picker
            parent.isPickerShowing = false
        }
    }
}
