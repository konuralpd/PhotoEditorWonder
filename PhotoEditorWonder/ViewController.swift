//
//  ViewController.swift
//  PhotoEditorWonder
//
//  Created by Mac on 30.07.2022.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filtreSlider: UISlider!
    @IBOutlet weak var kaydetButton: UIButton!
    @IBOutlet weak var addFilterButton: UIButton!
    
    var filteredImg: UIImage!
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Fotoğraf Editle"
        chooseImageButton.addTarget(self, action: #selector(uploadImage), for: .touchUpInside)
        addFilterButton.addTarget(self, action: #selector(filterSheetOpen), for: .touchUpInside)
        context = CIContext()
        currentFilter = CIFilter(name: "CIVignette")
        filtreSlider.isHidden = true
        filtreSlider.addTarget(self, action: #selector(sliderValueChanged), for: UIControl.Event.allEvents)
        
       
    }
    
    @objc func filterSheetOpen() {
        let ac = UIAlertController(title: "Filtre Seçiniz", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIBumpDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc func uploadImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
       
    }
    
    func setFilter(action: UIAlertAction) {
        guard  currentImage != nil else { return }
        guard let filterTitle = action.title else { return }
        currentFilter = CIFilter(name: filterTitle)
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        addFilterButton.setTitle(filterTitle, for: .normal)
        applyProcessing()
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return}
        dismiss(animated: true,completion: nil)
        currentImage = image
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        filtreSlider.isHidden = false
        applyProcessing()
    }
    func applyProcessing() {
        guard let image = currentFilter.outputImage else { return }
        currentFilter.setValue(filtreSlider.value, forKey: kCIInputIntensityKey)
        if let cgImg = context.createCGImage(image, from: image.extent) {
            let filteredImg = UIImage(cgImage: cgImg)
            imageView.image = filteredImg
        }
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filtreSlider.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filtreSlider.value * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filtreSlider.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey){currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)}
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent){
            let processedImage = UIImage(cgImage: cgimg)
            self.imageView.image = processedImage
        }
        
       
    }
    @objc func sliderValueChanged() {
        applyProcessing()
    }


}

