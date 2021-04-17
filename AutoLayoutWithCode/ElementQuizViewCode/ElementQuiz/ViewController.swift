import UIKit

enum Mode {
    case flashCard
    case quiz
}

enum State {
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Cria elementos visuais programaticamente
    // 1 - Cria o segmented control via código
    let modeSelector: UISegmentedControl = {
        let theSegmentedControl = UISegmentedControl()
        theSegmentedControl.insertSegment(withTitle: "Flash Cards", at: 0, animated: true)
        theSegmentedControl.insertSegment(withTitle: "Quiz", at: 1, animated: true)
        return theSegmentedControl
    }()
    
    // 2 - Cria a image view via código
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    // 3 - Cria um label via código
    let answerLabel: UILabel = {
        let labelAnswer = UILabel()
        labelAnswer.text = "Answer Label"
        labelAnswer.numberOfLines = 0
        labelAnswer.textAlignment = .center
        return labelAnswer
    }()
    
    // 4 - Cria um text field via código
    let textField: UITextField = {
        let textAnswer = UITextField()
        textAnswer.text = "?"
        textAnswer.placeholder = "Enter text here"
        textAnswer.font = UIFont.systemFont(ofSize: 15)
        textAnswer.borderStyle = UITextField.BorderStyle.roundedRect
        textAnswer.autocorrectionType = UITextAutocorrectionType.no
        textAnswer.keyboardType = UIKeyboardType.default
        textAnswer.returnKeyType = UIReturnKeyType.done
        textAnswer.clearButtonMode = UITextField.ViewMode.whileEditing
        textAnswer.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textAnswer
    }()
    
    // 5 - Cria os 2 botões via código (usando extensão)
    private let showAnswerButton =
        UIButton.createSystemButton(withTitle: "Show Answer")
    private let nextButton =
        UIButton.createSystemButton(withTitle: "Next Element")


    // 6 - Adiciona os 2 botões em uma Stack View horizontal
    private lazy var smallerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews:
                                        [showAnswerButton, nextButton])
        stackView.distribution = .fill
        stackView.spacing = 57
        return stackView
    }()
    
    // 7 - Adiciona a Stack View com os botões em uma Stack View maior, que irá englobar todos os outros elementos visuais
    private lazy var biggerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [modeSelector, imageView, answerLabel, textField, smallerStack])
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.alignment = .center
        return stackView
    }()
       
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
           
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Habilita delegate para receber os eventos do teclado
        textField.delegate = self
        
        // MARK: - Cria Actions dinamicamente
        showAnswerButton.addTarget(self, action: #selector(showAnswer), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextAnswer), for: .touchUpInside)
        modeSelector.addTarget(self, action: #selector(switchModes), for: .valueChanged)
        
        // Adciona constraints programaticamente
        setupStackViews()
        
        mode = .flashCard
    }
    
    func setupStackViews() {
        // 1
        view.addSubview(biggerStack)
        biggerStack.translatesAutoresizingMaskIntoConstraints = false
        biggerStack.backgroundColor = .white
        
        // 2
        NSLayoutConstraint.activate(
            [biggerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             biggerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             biggerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: +14),
             biggerStack.heightAnchor.constraint(equalToConstant: 432)
            ])
    }
    
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
        modeSelector.selectedSegmentIndex = 0
        
        // Text field and keyboard
        textField.isHidden = true
        textField.resignFirstResponder()

        // Answer label
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
        
        // Buttons
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
    }
    
    func updateQuizUI(elementName: String) {
        // Segmented control
        modeSelector.selectedSegmentIndex = 1

        // Text field and keyboard
        textField.isHidden = false
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        // Answer label
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect Answer: " + elementName
            }
        case .score:
            answerLabel.text = ""
            print("Your score is \(correctAnswerCount) out of \(elementList.count).")
        }
        
        // Score display
        if state == .score {
            displayScoreAlert()
        }
        
        // Buttons
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
    }
    
    func updateUI() {
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image

        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
   

    @objc func showAnswer(_ sender: UIButton) {
        state = .answer
        
        updateUI()
    }
    
    @objc func nextAnswer(_ sender: UIButton) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        
        state = .question
        
        updateUI()
    }
    
    // MARK: - Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFieldContents = textField.text!
        
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        
        state = .answer
        
        updateUI()
                
        return true
    }
    
    @objc func switchModes(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count).", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
}

private extension UIButton {
  static func createSystemButton(withTitle title: String)
  -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    return button
  }
}

