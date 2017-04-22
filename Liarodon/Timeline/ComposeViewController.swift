//
//  ComposeViewController.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/23/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import UIKit
import KeyboardObserver

class ComposeViewController: UIViewController {

    let keyboard = KeyboardObserver()
    @IBOutlet var contentTextView: PlaceHolderTextView! {
        didSet {
            contentTextView.placeHolder = "What is on your mind?"
            contentTextView.delegate = self
        }
    }
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var notSafeForWorkButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    @IBOutlet var contentWarningButton: UIButton!
    @IBOutlet var textCountLabel: UILabel!
    @IBOutlet var contentWarningTextField: UITextField!

    @IBOutlet var topConstraint: NSLayoutConstraint!
    var restCount = 500
    var isContentWarningEnabled = false {
        didSet {
            if isContentWarningEnabled {
                contentWarningButton?.tintColor = .blue
                contentWarningTextField?.isHidden = false
                topConstraint?.constant = 16
            } else {
                contentWarningButton?.tintColor = .gray
                contentWarningTextField?.isHidden = true
                topConstraint?.constant = -28
            }

            UIView.animate(withDuration: 0.4, animations: { [weak self] _ in
                if let _ = self?.topConstraint {
                    self?.view.layoutIfNeeded()
                }
            })
            textDidChange(nil)
        }
    }
    var isNotSafeForWorkEnabled = false {
        didSet {
            if isNotSafeForWorkEnabled {
                notSafeForWorkButton?.tintColor = .blue
            } else {
                notSafeForWorkButton?.tintColor = .gray
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize views
        isContentWarningEnabled = false
        isNotSafeForWorkEnabled = false

        contentWarningTextField.addTarget(self, action: #selector(ComposeViewController.textDidChange(_:)), for: .editingChanged)

        keyboard.observe { [weak self] (event) -> Void in
            guard let s = self else { return }
            switch event.type {
            case .willShow, .willHide, .willChangeFrame:
                let distance = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
                let bottom = distance >= s.bottomLayoutGuide.length ? distance : s.bottomLayoutGuide.length

                self?.bottomConstraint.constant = bottom
                UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: { [weak self] () -> Void in
                    self?.view.layoutIfNeeded()
                } , completion: nil)
            default:
                break
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textDidChange(_ textField: UITextField?) {
        let contntWarningTextCount = (contentWarningTextField.text ?? "").characters.count
        if isContentWarningEnabled {
            restCount = 500 - (contntWarningTextCount + contentTextView.text.characters.count)
        } else {
            restCount = 500 - contentTextView.text.characters.count
        }
        textCountLabel.text = "\(restCount)"
    }
    
    @IBAction func photoButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let controller = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = .photoLibrary
                self?.present(controller, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let controller = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = .camera
                self?.present(controller, animated: true, completion: nil)
            }

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func privacyButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Privacy settings", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Public", style: .default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "Private", style: .default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "Unlisted", style: .default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "Direct", style: .default, handler: { _ in
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func contentWarningButtonTapped(_ sender: UIButton) {
        isContentWarningEnabled = !isContentWarningEnabled
    }
    @IBAction func notSafeForWorkButtonTapped(_ sender: UIButton) {
        isNotSafeForWorkEnabled = !isNotSafeForWorkEnabled
    }
    @IBAction func tootButtonTapped(_ sender: UIButton) {
        // TODO: TOOT!!
    }
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ComposeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            print(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textDidChange(nil)
    }
}

public class PlaceHolderTextView: UITextView {

    let placeHolderLabel = UILabel()
    var placeHolderColor = UIColor.lightGray
    var placeHolder = ""

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(self, selector: #selector(PlaceHolderTextView.textChanged(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }

    override public func draw(_ rect: CGRect) {
        if placeHolder.characters.count > 0 {
            placeHolderLabel.frame = CGRect(x: 8, y: 8, width: bounds.size.width - 16, height: 0)
            placeHolderLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            placeHolderLabel.numberOfLines = 0
            placeHolderLabel.font = self.font
            placeHolderLabel.backgroundColor = UIColor.clear
            placeHolderLabel.textColor = self.placeHolderColor
            placeHolderLabel.alpha = 0
            placeHolderLabel.tag = 999

            placeHolderLabel.text = self.placeHolder
            placeHolderLabel.sizeToFit()
            addSubview(placeHolderLabel)
        }

        sendSubview(toBack: placeHolderLabel)

        if text.utf16.count == 0 && placeHolder.characters.count > 0 {
            self.viewWithTag(999)?.alpha = 1
        }

        super.draw(rect)
    }

    func textChanged(notification: Notification) {
        if placeHolder.characters.count == 0 {
            return
        }

        if self.text.utf16.count == 0 {
            viewWithTag(999)?.alpha = 1
        } else {
            viewWithTag(999)?.alpha = 0
        }
    }

}
