//
//  ViewController.swift
//  SeeFood
//
//  Created by Ming jie Huang on 1/10/18.
//  Copyright © 2018 Ming jie Huang. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var resultsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage into CIImage.")
            }
            
            detect(image: ciimage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(image : CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            
            var dictionary = [String:String]()
            
            let result = results.prefix(4)
            
            for x in result {
                
                dictionary.updateValue(String("\(x.confidence * 100)%"), forKey: x.identifier)
                
            }
            
            var resultX = ""
            
            for d in dictionary{
                resultX += "\(d.key), with \(d.value)\n"
            }
            
            self.resultsLabel.text = resultX
            print(resultX)
//            if let firstResult = results.first{
//                if firstResult.identifier.contains("hotdog"){
//                    self.navigationItem.title = "Hotdog!"
//                }else{
//                    self.navigationItem.title = "Not Hotdog!"
//                }
//            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch{
            print(error)
        }
        
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    

}

