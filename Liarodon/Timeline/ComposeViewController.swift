//
//  ComposeViewController.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/23/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import UIKit
import KeyboardObserver
import APIKit

class ComposeViewController: UIViewController {

    let keyboard = KeyboardObserver()
    @IBOutlet var contentTextView: PlaceHolderTextView! {
        didSet {
            contentTextView.placeHolder = NSLocalizedString("compose_toot_place_holder", comment: "")
            contentTextView.delegate = self
        }
    }
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var notSafeForWorkButton: UIButton!
    @IBOutlet var privacyButton: UIButton!
    @IBOutlet var contentWarningButton: UIButton!
    @IBOutlet var textCountLabel: UILabel!
    @IBOutlet var contentWarningTextField: UITextField!

    @IBOutlet var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.isHidden = true
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
        }
    }
    @IBOutlet var topConstraint: NSLayoutConstraint!
    var restCount = 500
    var images = [UIImage]()
    var visibility = Visibility.public
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

    func addBottomInsetForImage() {
        if images.isEmpty {
            contentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageCollectionView.isHidden = true
        } else {
            contentTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: imageCollectionView.frame.height, right: 0)
            imageCollectionView.isHidden = false
        }
    }
    
    @IBAction func photoButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("photo_source_title", comment: ""), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("photo_source_library", comment: ""), style: .default, handler: { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let controller = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = .photoLibrary
                self?.present(controller, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("photo_source_camera", comment: ""), style: .default, handler: { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let controller = UIImagePickerController()
                controller.delegate = self
                controller.sourceType = .camera
                self?.present(controller, animated: true, completion: nil)
            }

        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func privacyButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("privacy_settings_title", comment: ""), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("privacy_settings_public", comment: ""), style: .default, handler: { [weak self] _ in
            self?.visibility = .public
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("privacy_settings_private", comment: ""), style: .default, handler: { [weak self] _ in
            self?.visibility = .private
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("privacy_settings_unlisted", comment: ""), style: .default, handler: { [weak self] _ in
            self?.visibility = .unlisted
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("privacy_settings_direct", comment: ""), style: .default, handler: { [weak self] _ in
            self?.visibility = .direct
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func contentWarningButtonTapped(_ sender: UIButton) {
        isContentWarningEnabled = !isContentWarningEnabled
    }
    @IBAction func notSafeForWorkButtonTapped(_ sender: UIButton) {
        isNotSafeForWorkEnabled = !isNotSafeForWorkEnabled
    }
    @IBAction func tootButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false

        if images.count > 4 {
            let alert = UIAlertController(title: NSLocalizedString("photos_too_many_title", comment: ""), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        var attachments = [Attachment]()
        images.forEach {
            let data = UIImageJPEGRepresentation($0, 0.8)!
            let req = MastodonAPI.AddMedia(imageData: data)
            Session.send(req) { [weak self] (result) in
                switch result {
                case .success(let attachment):
                    attachments.append(attachment)
                    if attachments.count == self?.images.count {
                        self?.post(withAttachment: attachments)
                        sender.isEnabled = true
                    }
                case .failure(let error):
                    self?.fail(error: error)
                    sender.isEnabled = true
                }
            }
        }
        if images.isEmpty {
            post(withAttachment: [])
        }
    }

    func post(withAttachment attachments: [Attachment]) {
        let req = MastodonAPI.AddStatus(status: contentTextView.text,
                                        inReplyToId: nil,
                                        mediaIds: attachments.map { $0.id },
                                        sensitive: isNotSafeForWorkEnabled,
                                        spoilerText: isContentWarningEnabled ? contentWarningTextField.text : nil,
                                        visibility: visibility)
        Session.send(req) { [weak self] (result) in
            switch result {
            case .success(_):
                let alert = UIAlertController(title: NSLocalizedString("post_toot_success", comment: ""), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }))
                self?.present(alert, animated: true, completion: nil)
            case .failure(let error):
                self?.fail(error: error)
            }
        }
    }

    func fail(error: Error) {
        let alert = UIAlertController(title: NSLocalizedString("post_toot_failure", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ComposeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            images.append(image)
            imageCollectionView.reloadData()
            addBottomInsetForImage()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textDidChange(nil)
    }
}

extension ComposeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)

        let image = cell.viewWithTag(1) as! UIImageView
        image.image = images[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
}

extension ComposeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("remove_photo_title", comment: ""), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("remove_photo_ok", comment: ""), style: .default, handler: { [weak self] _ in
            self?.images.remove(at: indexPath.row)
            collectionView.reloadData()
            self?.addBottomInsetForImage()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension ComposeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 128, height: 128)
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
