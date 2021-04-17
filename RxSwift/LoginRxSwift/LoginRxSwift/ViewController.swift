//
//  ViewController.swift
//  LoginRxSwift
//
//  Created by Carlos Alberto Savi on 01/04/21.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    let loginViewModel = LoginViewModel()
    private let disposeBag = DisposeBag()

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func tappedLoginButton(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        usernameTextField.becomeFirstResponder()
        
        usernameTextField.rx.text.map { $0 ?? "" }.bind(to: loginViewModel.usernameTextPublishedObject).disposed(by: disposeBag)
        usernameTextField.rx.text.map { $0 ?? "" }.bind(to: loginViewModel.passwordTextPublishedObject).disposed(by: disposeBag)
        
        loginViewModel.isValid().bind(to: loginButton.rx.isEnabled).disposed(by: disposeBag)
        loginViewModel.isValid().map { $0 ? 1 : 0.1 }.bind(to: loginButton.rx.alpha).disposed(by: disposeBag)
    }

}

class LoginViewModel {
    let usernameTextPublishedObject = PublishSubject<String>()
    let passwordTextPublishedObject = PublishSubject<String>()
    
    func isValid() -> Observable<Bool> {
        return Observable.combineLatest(usernameTextPublishedObject.asObservable().startWith(""), passwordTextPublishedObject.asObservable().startWith("")).map { username, password in
            return username.count > 3 && password.count > 3
        }.startWith(false)
    }
}

