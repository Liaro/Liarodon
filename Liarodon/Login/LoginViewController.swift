//
//  LoginViewController.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit
import KeychainAccess
import KeyboardObserver
import APIKit
import NVActivityIndicatorView
import OnePasswordExtension

final class LoginViewController: UIViewController {

    let keyboard = KeyboardObserver()

    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var onePasswordButton: UIButton!
    @IBOutlet weak var instanceView: UIView!
    @IBOutlet weak var instanceViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var instanceTextField: UITextField!
    @IBOutlet weak var invalidInstanceLabel: UILabel! {
        didSet {
            invalidInstanceLabel.isHidden = true
        }
    }
    @IBOutlet weak var instanceSelectButton: UIButton!

    @IBOutlet var leftTopButton: UIButton!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginViewLeadingConstraint: NSLayoutConstraint! {
        didSet {
            // Hide to right side
            loginView.isHidden = true
            loginViewLeadingConstraint.constant = UIScreen.main.bounds.width
        }
    }
    @IBOutlet weak var instanceNameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginFailureLabel: UILabel! {
        didSet {
            loginFailureLabel.isHidden = true
        }
    }

    @IBOutlet weak var indicatorView: NVActivityIndicatorView! {
        didSet {
            indicatorView.color = .darkGray
        }
    }

    var showCloseButton = false
    fileprivate var app: App!

    override func viewDidLoad() {
        super.viewDidLoad()
        onePasswordButton.isHidden = !OnePasswordExtension.shared().isAppExtensionAvailable()

        // Do any additional setup after loading the view.
        if showCloseButton {
            leftTopButton.setTitle("❌", for: .normal)
            leftTopButton.isHidden = false
        } else {
            leftTopButton.setTitle("Back", for: .normal)
            leftTopButton.isHidden = true
        }

        keyboard.observe { [weak self] (event) -> Void in
            guard let s = self else { return }
            switch event.type {
            case .willShow:

                let space: CGFloat = 20
                let buttonFrame = s.instanceSelectButton.convert(s.instanceSelectButton.bounds, to: s.view)
                let diff = event.keyboardFrameEnd.minY - buttonFrame.maxY

                if diff < space {
                    s.logoViewTopConstraint.constant = diff - space
                }
                UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
                    s.view.layoutIfNeeded()
                })

            case .willHide:

                s.logoViewTopConstraint.constant = 0
                UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
                    s.view.layoutIfNeeded()
                })

            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

        return .portrait
    }

    @IBAction func onePasswordButtonTapped(_ sender: UIButton) {
        OnePasswordExtension.shared().findLogin(forURLString: MastodonAPI.instanceURL.absoluteString, for: self, sender: sender) { [weak self] login, error in
            if login?.count == 0 || error != nil {
                return
            }

            self?.usernameTextField.text = login?[AppExtensionUsernameKey] as? String
            self?.passwordTextField.text = login?[AppExtensionPasswordKey] as? String
        }
    }

    @IBAction func leftTopButtonTapped(_ sender: UIButton) {
        if leftTopButton.titleLabel?.text?.contains("❌") == true {
            dismiss(animated: true, completion: nil)
        } else {
            backToSelectingInstance()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

/// Insctance
extension LoginViewController {

    @IBAction func instanceSelectButtonDidTap(_ sender: Any) {

        var urlString = instanceTextField.placeholder!
        if let text = instanceTextField.text, text != "" {
            urlString = text
        }
        urlString = "https://\(urlString)"

        guard let url = urlString.url else {
            postAppsFailure()
            return
        }

        instanceTextField.endEditing(true)
        invalidInstanceLabel.isHidden = true
        indicatorView.startAnimating()

        MastodonAPI.instanceURL = url
        let request = MastodonAPI.PostAppsRequest(clientName: "liarodon")
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }
            s.indicatorView.stopAnimating()

            switch result {
            case .success(let app):
                s.postAppsSuccess(app: app)

            case .failure(let error):
                print(error)
                s.postAppsFailure()
            }

            s.leftTopButton.setTitle("Back", for: .normal)
            s.leftTopButton.isHidden = false
        }
    }

    private func postAppsSuccess(app: App) {

        self.app = app

        // Store instance URL
        AccountService.shared.setInstanceUrl(MastodonAPI.instanceURL.absoluteString)

        // Switch instanceView to loginView
        instanceViewLeadingConstraint.constant = -view.bounds.width
        loginViewLeadingConstraint.constant = 0
        loginView.isHidden = false
        UIView.animate(withDuration: 1/3, animations: {
            [weak self] in
            self?.view.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.instanceView.isHidden = true
        })
    }

    fileprivate func backToSelectingInstance() {
        instanceViewLeadingConstraint.constant = 0
        loginViewLeadingConstraint.constant = view.bounds.width
        loginView.isHidden = false
        instanceView.isHidden = false
        UIView.animate(withDuration: 1/3, animations: {
            [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            if self?.showCloseButton == true {
                self?.leftTopButton.setTitle("❌", for: .normal)
                self?.leftTopButton.isHidden = false
            } else {
                self?.leftTopButton.isHidden = true
            }
        })
    }

    private func postAppsFailure() {

        invalidInstanceLabel.isHidden = false
    }
}


/// Login
extension LoginViewController {

    @IBAction func loginButtonDidTap(_ sender: UIButton) {

        guard let username = usernameTextField.text, username != "" else {
            postTokenFailure()
            return
        }
        guard let password = passwordTextField.text, password != "" else {
            postTokenFailure()
            return
        }

        usernameTextField.endEditing(true)
        passwordTextField.endEditing(true)
        loginFailureLabel.isHidden = true
        indicatorView.startAnimating()

        let request = MastodonAPI.PostAccessTokenRequest(
            clientID: app.clientID,
            clientSecret: app.clientSecret,
            username: username,
            password: password)
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }
            s.indicatorView.stopAnimating()

            switch result {
            case .success(let accessToken):
                s.postTokenSuccess(accessToken: accessToken)

            case .failure(let error):
                print(error)
                s.postTokenFailure()
            }
        }
    }

    private func postTokenSuccess(accessToken: AccessToken) {
        AccountService.shared.setAccessToken(accessToken.accessToken)

        let request = MastodonAPI.GetAuthenticatedAccountRequest()
        Session.send(request) { [weak self] result in
            switch result {
            case .success(let account):
                if let loginAccount = AccountService.shared.addAccount(accessToken: accessToken.accessToken,
                            username: account.username,
                            displayName: account.displayName,
                            avaterUrl: account.avatar,
                            host: MastodonAPI.instanceURL.absoluteString,
                            accountId: account.id) {
                    _ = AccountService.shared.selectAccount(loginAccount)
                    let notification = Notification(
                        name: accountChangedNotification,
                        object: self,
                        userInfo: nil)
                    NotificationCenter.default.post(notification)
                    self?.dismiss(animated: true, completion: nil)
                } else {
                    self?.postTokenFailure()
                }
            case .failure(_):
                self?.postTokenFailure()
            }
        }

        // Dismiss LoginViewController
    }

    private func postTokenFailure() {

        loginFailureLabel.isHidden = false
    }
}
