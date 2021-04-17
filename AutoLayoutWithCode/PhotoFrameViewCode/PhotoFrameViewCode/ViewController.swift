//
//  ViewController.swift
//  PhotoFrameViewCode
//
//  Created by Carlos Alberto Savi on 23/03/21.
//

import UIKit

class ViewController: UIViewController {
    
    let imageView: UIImageView = {
        let someImage = UIImageView()
        someImage.image = UIImage(named: "Boat.png")
        someImage.translatesAutoresizingMaskIntoConstraints = false
        return someImage
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageViewSetupConstraints()
    }

    // Constraints para a imagem
    func imageViewSetupConstraints() {
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
}

