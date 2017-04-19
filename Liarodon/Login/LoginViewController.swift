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

final class LoginViewController: UIViewController {

    let keyboard = KeyboardObserver()

    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var instanceView: UIView!
    @IBOutlet weak var instanceViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var instanceTextField: UITextField!
    @IBOutlet weak var invalidInstanceLabel: UILabel! {
        didSet {
            invalidInstanceLabel.isHidden = true
        }
    }
    @IBOutlet weak var instanceSelectButton: UIButton!

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

    fileprivate var app: App!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

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
                    s.logoView.layoutIfNeeded()
                })

            case .willHide:

                s.logoViewTopConstraint.constant = 0
                UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
                    s.logoView.setNeedsLayout()
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
        }
    }

    private func postAppsSuccess(app: App) {

        self.app = app

        // Store instance URL
        let keychain = Keychain()
        keychain["instance_url"] = MastodonAPI.instanceURL.absoluteString

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

        // Store access token
        let keychain = Keychain()
        keychain["access_token"] = accessToken.accessToken

        // Setup MastodonAPI
        MastodonAPI.accessToken = accessToken.accessToken

        // Dismiss LoginViewController
        dismiss(animated: true, completion: nil)
    }

    private func postTokenFailure() {

        loginFailureLabel.isHidden = false
    }
}
