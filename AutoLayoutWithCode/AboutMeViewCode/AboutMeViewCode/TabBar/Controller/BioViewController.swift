//
//  BioViewController.swift
//  AboutMeViewCode
//
//  Created by Carlos Alberto Savi on 23/03/21.
//

import UIKit

class BioViewController: UIViewController {
    
//    let imageView: UIImageView = {
//        let someImage = UIImageView(frame: UIScreen.main.bounds)
//        someImage.image = UIImage(named: "milky_way")
//        someImage.contentMode = .scaleAspectFill
//        return someImage
//    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let shareView = ShareImageView(frame: UIScreen.main.bounds)
        view.addSubview(shareView)
        
        let bio = "Carlos A Savi, Instrutor, São Paulo"
        let shareLabel = ShareLabel(fullName: bio)
        view.addSubview(shareLabel)
        shareLabel.setConstraints(view: view)
    }
    
}
