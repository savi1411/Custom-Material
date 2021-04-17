import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // 1. Instância para a View Model
    private let viewModel = ElementViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. Criar binds para a View Model
        viewModel.modeSelector.bind { [weak self] modeSelector in
            self?.modeSelector.selectedSegmentIndex = modeSelector.selectedSegmentIndex
        }
        
        viewModel.imageView.bind { [weak self] imageView in
            self?.imageView.image = imageView
        }
        
        viewModel.answerLabel.bind { [weak self] answerLabel in
            self?.answerLabel.text = answerLabel.text
        }
        
        viewModel.textField.bind { [weak self] textField in
            self?.textField.isHidden = textField.isHidden
            self?.textField.isEnabled = textField.isEnabled
        }
        
        viewModel.showAnswerButton.bind { [weak self] showAnswerButton in
            self?.showAnswerButton.isHidden = showAnswerButton.isHidden
        }
        
        viewModel.nextButton.bind { [weak self] nextButton in
            self?.nextButton.isEnabled = nextButton.isEnabled
            self?.nextButton.setTitle(nextButton.titleLabel?.text, for: .normal)
        }
        
        viewModel.mode = .flashCard
        
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        viewModel.state = .answer
        
        viewModel.updateUI()
    }
    
    @IBAction func next(_ sender: Any) {
        viewModel.currentElementIndex += 1
        if viewModel.currentElementIndex >= viewModel.elementList.count {
            viewModel.currentElementIndex = 0
            if viewModel.mode == .quiz {
                viewModel.state = .score
                viewModel.updateUI()
                return
            }
        }
        
        viewModel.state = .question
        
        viewModel.updateUI()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFieldContents = textField.text!
        
        if textFieldContents.lowercased() == viewModel.elementList[viewModel.currentElementIndex].lowercased() {
            viewModel.answerIsCorrect = true
            viewModel.correctAnswerCount += 1
        } else {
            viewModel.answerIsCorrect = false
        }
        
        viewModel.state = .answer
        
        viewModel.updateUI()
                
        return true
    }
    
    @IBAction func switchModes(_ sender: UISegmentedControl) {
        viewModel.switchModes(sender.selectedSegmentIndex)
    }
    
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(viewModel.correctAnswerCount) out of \(viewModel.elementList.count).", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        viewModel.mode = .flashCard
    }
}

