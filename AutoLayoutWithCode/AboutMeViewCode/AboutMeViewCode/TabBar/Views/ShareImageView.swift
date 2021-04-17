//
//  MilkWayImageView.swift
//  AboutMeViewCode
//
//  Created by Carlos Alberto Savi on 23/03/21.
//
//
import UIKit

class ShareImageView: UIImageView {
       
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSubviews()
    }
        
    func createSubviews() {
        // all the layout code from above
        self.contentMode = .scaleAspectFill
        self.image = UIImage(named: "milky_way")
    }
}


