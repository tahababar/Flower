//
//  ViewController.swift
//  Flower?
//
//  Created by Taha Babar on 8/23/20.
//  Copyright © 2020 Taha Babar. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var labelText: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage { //do .editedImage if allowsediting is true
            cameraView.image = image       //assigning that image to our image view
            imagePicker.dismiss(animated: true, completion: nil)
            //to get rid of imagePicker/album/camera after u select/capture a photo

            guard let ciImage = CIImage(image: image) else {
               fatalError("couldn't convert uiimage to CIImage")
            }
            detect(image: ciImage)
        }
    }
    
    @IBAction func cameraClicked(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary //to allow camera functionality //do .camera if u want to access photos from photo library
               imagePicker.allowsEditing = false //to disable editing on pictures by users
               present(imagePicker, animated: true, completion: nil)  //to open camera
        
    }
    
    //created this function to detect the image using MLImage and CoreML
       func detect(image: CIImage) {
           
           // Load the ML model through its generated class //creating a new model for image analysis
           guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
               fatalError("can't load ML model")
           }
           //creating request of detector
           let request = VNCoreMLRequest(model: model) { request, error in
               guard let results = request.results as? [VNClassificationObservation],
                   let topResult = results.first
                   else {
                       fatalError("unexpected result type from VNCoreMLRequest")
               }
                   DispatchQueue.main.async {
                       print(topResult.identifier);
                    self.labelText.title = "Flower: \(topResult.identifier)".capitalized; //to capitalize our string
                   }
           }
           //to link image woith detector to get final results
           let handler = VNImageRequestHandler(ciImage: image)
           
           do {
               try handler.perform([request])
           }
           catch {
               print(error)
           }
       }
    
}

