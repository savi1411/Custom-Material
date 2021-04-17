//
//  ViewController.swift
//  SystemViewControllers
//
//  Created by Carlos Alberto Savi on 17/03/21.
//

import UIKit
import SafariServices
import MessageUI
import RxSwift
import RxCocoa

class ViewController: UIViewController, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    
//    let imagePicker = UIImagePickerController()
    var disposeBag = DisposeBag()
       
    var actionss: [UIAlertController.Action<UIImagePickerController.SourceType>] = [
        .action(title: "Galeria", style: .default, value: .photoLibrary),
    ]
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        
        guard let image = imageView.image else { return }
        
        let activityController =
            UIActivityViewController(activityItems: [image],
                                     applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView =
            sender
        present(activityController, animated: true, completion: nil)
        
    }
    
    @IBAction func safariButtonTapped(_ sender: UIButton) {
        
        if let url = URL(string: "http://www.apple.com") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true,
                    completion: nil)
        }
    }
    
    //    @IBAction func cameraButtonTapped(_ sender: UIButton) {
    //
    //        let imagePicker = UIImagePickerController()
    //        imagePicker.delegate = self
    //
    //        let alertController = UIAlertController(title:
    //                                                    "Choose Image Source", message: nil,
    //                                                preferredStyle: .actionSheet)
    //
    //        let cancelAction = UIAlertAction(title: "Cancel",
    //                                         style: .cancel, handler: nil)
    //        alertController.addAction(cancelAction)
    //
    //        // Inclui ação de Câmera apenas se o device tiver esse recurso
    //        if UIImagePickerController.isSourceTypeAvailable(.camera) {
    //            let cameraAction = UIAlertAction(title: "Camera",
    //                                             style: .default, handler: { action in
    //                                                imagePicker.sourceType = .camera
    //                                                self.present(imagePicker, animated: true, completion: nil)
    //                                             })
    //            alertController.addAction(cameraAction)
    //        }
    //
    //        // Inclui ação de Biblioteca de Fotos apenas se o device tiver esse recurso
    //        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
    //            let photoLibraryAction = UIAlertAction(title: "Photo Library",
    //                                                   style: .default, handler: { action in
    //                                                    imagePicker.sourceType = .photoLibrary
    //                                                    self.present(imagePicker, animated: true, completion: nil)
    //                                                   })
    //            alertController.addAction(photoLibraryAction)
    //        }
    //
    //
    //        alertController.popoverPresentationController?.sourceView =
    //            sender
    //
    //        present(alertController, animated: true, completion: nil)
    //
    //
    //    }
    
    @IBAction func emailButtonTapped(_ sender: UIButton) {
        guard MFMailComposeViewController.canSendMail() else {
            print("Can not send mail")
            return
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        mailComposer.setToRecipients(["example@example.com"])
        mailComposer.setSubject("Look at this")
        mailComposer.setMessageBody("Hello, this is an email from the app I made.", isHTML: false)
        
        if let image = imageView.image, let jpegData =
            image.jpegData(compressionQuality: 0.9) {
            mailComposer.addAttachmentData(jpegData, mimeType:
                                            "image/jpeg", fileName: "photo.jpg")
        }
        
        present(mailComposer, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        verifyAndAppendCamera()
        
        cameraButton.rx.tap.bind {
              UIAlertController
                .present(in: self, title: "Selecione uma opção", message: nil , style: .actionSheet, actions: self.actionss)
                .bind { pickerType in
                  return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = pickerType
                    picker.allowsEditing = false
                  }
                  .flatMap {
                    $0.rx.didFinishPickingMediaWithInfo
                  }
                  .take(1)
                  .map { info in
                    return info[.originalImage] as? UIImage
                  }
                  .bind(to: self.imageView.rx.image)
                  .disposed(by: self.disposeBag)
                }.disposed(by: self.disposeBag)
            }.disposed(by: disposeBag)
    }
    
    func verifyAndAppendCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
          actionss.append(.action(title: "Camera", style: .default, value: .camera))
        }
      }
    
    // MARK: - Delegates
    
    // Delegate para a ImagePickerController informar (delegar) a ação do usuário
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        imageView.image = selectedImage
        dismiss(animated: true, completion: nil)
        
    }
    
    // Para dispensar a system controller de email
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension UIAlertController {
  struct Action<T> {
    var title: String?
    var style: UIAlertAction.Style
    var value: T

    static func action(title: String?, style: UIAlertAction.Style = .default, value: T) -> Action {
      return Action(title: title, style: style, value: value)
    }
  }

  static func present<T>(in viewController: UIViewController,
                      title: String? = nil,
                      message: String? = nil,
                      style: UIAlertController.Style,
                      actions: [Action<T>]) -> Observable<T> {
    return Observable.create { observer in
      let alertController = UIAlertController(title: title, message: message, preferredStyle: style)

      actions.enumerated().forEach { index, action in
        let action = UIAlertAction(title: action.title, style: action.style) { _ in
          observer.onNext(action.value)
          observer.onCompleted()
        }
        alertController.addAction(action)
      }

      viewController.present(alertController, animated: true, completion: nil)
      return Disposables.create { alertController.dismiss(animated: true, completion: nil) }
    }
  }
}
