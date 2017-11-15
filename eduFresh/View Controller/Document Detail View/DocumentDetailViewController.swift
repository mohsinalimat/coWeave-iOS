//
//  DocumentDetailViewController.swift
//  eduFresh
//
//  Created by Benoît Frisch on 15/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit
import Fusuma
import iOSPhotoEditor


class DocumentDetailViewController: UIViewController, FusumaDelegate, PhotoEditorDelegate {
    var image : UIImage!
    /**
     *  Center Buttons, to add new data.
     */
    @IBOutlet var photoButton: UIButton!
    @IBOutlet var videoButton: UIButton!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var drawButton: UIButton!
    @IBOutlet var textButton: UIButton!
    /**
     *  Toolbar Buttons
     */
    @IBOutlet var previousPageButton: UIBarButtonItem!
    @IBOutlet var nextPageButton: UIBarButtonItem!
    @IBOutlet var pageNameButton: UIBarButtonItem!
    @IBOutlet var pagesListButton: UIBarButtonItem!
    /**
     *  Navigation Bar Buttons
     */
    @IBOutlet var previewButton: UIBarButtonItem!
    @IBOutlet var settingsButton: UIBarButtonItem!
    /**
     *
     */
    @IBOutlet var backgroundImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func photoAction(_ sender: Any) {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        fusuma.cropHeightRatio = 0.6 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        self.present(fusuma, animated: true, completion: nil)
    }
    
    @IBAction func videoAction(_ sender: Any) {
    }
    
    @IBAction func audioAction(_ sender: Any) {
    }
    
    @IBAction func drawAction(_ sender: Any) {
        if (self.image == nil) {
            self.image = UIImage(color: .white, size: CGSize(width: 1536, height: 2048))
        }
        let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
        
        //PhotoEditorDelegate
        photoEditor.photoEditorDelegate = self
        
        //The image to be edited
        photoEditor.image = self.image
        
        //Optional: To hide controls - array of enum control
        photoEditor.hiddenControls = [.crop, .share, .save, .sticker]
        
        //Optional: Colors for drawing and Text, If not set default values will be used
        //photoEditor.colors = [.red,.blue,.green]
        
        //Present the View Controller
        present(photoEditor, animated: true, completion: nil)
    }
    
    @IBAction func textAction(_ sender: Any) {
    }
    
    
    // Return the image which is selected from camera roll or is taken via the camera.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        self.backgroundImageView.image = image;
        self.image = image;
        videoButton.isEnabled = false;
        print("Image selected")
    }
    
    // Return the image but called after is dismissed.
    func fusumaDismissedWithImage(image: UIImage, source: FusumaMode) {
        
        print("Called just after FusumaViewController is dismissed.")
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    func fusumaCameraRollUnauthorized() {
        print("Camera roll unauthorized")
    }
    
    // Return an image and the detailed information.
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode, metaData: ImageMetadata) {
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }
    
    func doneEditing(image: UIImage) {
        self.image = image;
        self.backgroundImageView.image = image;
    }
    
    func canceledEditing() {
        print("Canceled")
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
