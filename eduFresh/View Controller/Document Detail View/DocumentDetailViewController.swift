//
//  DocumentDetailViewController.swift
//  eduFresh
//
//  Created by Benoît Frisch on 15/11/2017.
//  Copyright © 2017 Benoît Frisch. All rights reserved.
//

import UIKit

class DocumentDetailViewController: UIViewController {
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
        
    }
    
    @IBAction func videoAction(_ sender: Any) {
    }
    
    @IBAction func audioAction(_ sender: Any) {
    }
    
    @IBAction func drawAction(_ sender: Any) {
    }
    
    @IBAction func textAction(_ sender: Any) {
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
