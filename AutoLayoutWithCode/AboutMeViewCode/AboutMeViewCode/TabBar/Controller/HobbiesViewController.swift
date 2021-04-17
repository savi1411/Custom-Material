//
//  HobbiesViewController.swift
//  AboutMeViewCode
//
//  Created by Carlos Alberto Savi on 23/03/21.
//

import UIKit

class HobbiesViewController: UIViewController {

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
        
        let bio = "No fishing, Love Chess, Love Coding Very Much"
        let shareLabel = ShareLabel(fullName: bio)
        view.addSubview(shareLabel)
        shareLabel.setConstraints(view: view)

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
