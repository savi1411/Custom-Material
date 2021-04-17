//
//  ShareLabel.swift
//  AboutMeViewCode
//
//  Created by Carlos Alberto Savi on 24/03/21.
//

import UIKit

class ShareLabel: UILabel {
    
    // 1
    override var text: String? {
        didSet {
            guard let words = text?
                    .components(separatedBy: ", ")
            else { return }
            let joinedWords = words.joined(separator: "\n")
            guard text != joinedWords else { return }
            DispatchQueue.main.async { [weak self] in
                self?.text = joinedWords
            }
        }
    }
    
    // 2
    init(fullName: String? = "Label Text") {
        super.init(frame: .zero)
        setTextAttributes()
        text = fullName
    }
    
    // 3
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // 4
    private func setTextAttributes() {
        numberOfLines = 0
        textAlignment = .center
        textColor = UIColor.yellow
        font = UIFont.boldSystemFont(ofSize: 24)
    }
    
    func setConstraints(view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
          self.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
      }
    
}
