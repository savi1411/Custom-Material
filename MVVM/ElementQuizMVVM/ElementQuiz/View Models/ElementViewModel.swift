//
//  ElementViewModel.swift
//  ElementQuiz
//
//  Created by Carlos Alberto Savi on 26/03/21.
//  Copyright © 2021 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

public class ElementViewModel {
    
    // MARK: - Propriedades para bind com a View Controller
    let modeSelector = Box(UISegmentedControl())  //no option initially
    let imageView = Box(UIImage())  // no image initially
    let answerLabel = Box(UILabel())
    let textField = Box(UITextField())
    let showAnswerButton = Box(UIButton())
    let nextButton = Box(UIButton())
    
    // MARK: - Propriedades da lógica do App
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    var currentElementIndex = 0
    var mode: Mode = .flashCard {
        didSet {
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            updateUI()
        }
    }
    var state: State = .question
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    init() {
        mode = .flashCard
        setupFlashCards()
        updateUI()
    }
    
    // MARK: - Métodos da Lógica do App
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        
        elementList = fixedElementList
    }
    
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        
        elementList = fixedElementList.shuffled()
    }
    
    func updateFlashCardUI(elementName: String) {
        // Segmented control
        modeSelector.value.selectedSegmentIndex = 0
        
        // Text field and keyboard
        textField.value.isHidden = true
        textField.value.resignFirstResponder()

        // Answer label
        if state == .answer {
            answerLabel.value.text = elementName
        } else {
            answerLabel.value.text = "?"
        }
        
        // Buttons
        showAnswerButton.value.isHidden = false
        nextButton.value.isEnabled = true
        nextButton.value.setTitle("Next Element", for: .normal)
    }
    
    func updateQuizUI(elementName: String) {
        // Segmented control
        modeSelector.value.selectedSegmentIndex = 1

        // Text field and keyboard
        textField.value.isHidden = false
        switch state {
        case .question:
            textField.value.isEnabled = true
            textField.value.text = ""
            textField.value.becomeFirstResponder()
        case .answer:
            textField.value.isEnabled = false
            textField.value.resignFirstResponder()
        case .score:
            textField.value.isHidden = true
            textField.value.resignFirstResponder()
        }
        
        // Answer label
        switch state {
        case .question:
            answerLabel.value = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.value.text = "Correct!"
            } else {
                answerLabel.value.text = "❌\nCorrect Answer: " + elementName
            }
        case .score:
            answerLabel.value.text = ""
            print("Your score is \(correctAnswerCount) out of \(elementList.count).")
        }
        
        // Score display
//        if state == .score {
//            displayScoreAlert()
//        }
        
        // Buttons
        showAnswerButton.value.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.value.setTitle("Show Score", for: .normal)
        } else {
            nextButton.value.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question:
            nextButton.value.isEnabled = false
        case .answer:
            nextButton.value.isEnabled = true
        case .score:
            nextButton.value.isEnabled = false
        }
    }
    
    func updateUI() {
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.value = image!

        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    func switchModes(_ index: Int) {
        if index == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
}

