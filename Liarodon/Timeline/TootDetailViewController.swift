//
//  TootDetailViewController.swift
//  Liarodon
//
//  Created by Kouki Saito on 4/23/17.
//  Copyright © 2017 Liaro Inc. All rights reserved.
//

import UIKit
import ImageViewer
import SafariServices
import KeyboardObserver
import APIKit

class TootDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet var tableView: UITableView!
    var targetStatus: Status!
    var statuses = [Status]()
    fileprivate var attachmentGallery: AttachmentGallery?

    @IBOutlet var bottomConstraint: NSLayoutConstraint!

    @IBOutlet var replyTextField: UITextField!

    let keyboard = KeyboardObserver()

    override func viewDidLoad() {
        super.viewDidLoad()
        statuses = [targetStatus]
        targetStatus = targetStatus.reblog ?? targetStatus

        replyTextField.placeholder = "In reply to @\(targetStatus.account.username)"
        
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailToot" {
            if let selectedRow = tableView.indexPathForSelectedRow?.row {
                let status = statuses[selectedRow]
                (segue.destination as! TootDetailViewController).targetStatus = status
            }
        } else if segue.identifier == "ShowTimeline" {
            let timelineViewController = segue.destination as! TimelineTableViewController
            let tag = (sender as? NSDictionary)?["withTag"] as! Tag
            timelineViewController.type = .tag(tag.name)
        } else if segue.identifier == "ShowProfile" {
            let profileViewController = segue.destination as! ProfileViewController
            let mention = (sender as? NSDictionary)?["withMention"] as! Mention
            profileViewController.accountID = mention.id
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func replyTextEditingDidBegin(_ sender: UITextField) {
        if replyTextField.text?.isEmpty == true {
            replyTextField.text = "@\(targetStatus.account.acct) "
        }
    }
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = replyTextField.text else { return }
        sender.isEnabled = false
        let req = MastodonAPI.AddStatus(status: text,
                                        inReplyToId: targetStatus.id,
                                        mediaIds: [],
                                        sensitive: false,
                                        spoilerText: nil,
                                        visibility: .public)
        Session.send(req) { [weak self] (result) in
            sender.isEnabled = true
            switch result {
            case .success(let status):
                let alert = UIAlertController(title: "Posted", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }))
                self?.statuses.append(status)
                self?.tableView.reloadData()
                self?.replyTextField.resignFirstResponder()
                self?.replyTextField.text = ""
                self?.present(alert, animated: true, completion: nil)
            case .failure(_):
                let alert = UIAlertController(title: "Toot failed", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Toot", for: indexPath) as! TootTableViewCell

        cell.configureCell(status: statuses[indexPath.row])
        cell.attachmentView.delegate = self
        cell.delegate = self

        return cell
    }
}

extension TootDetailViewController: AttachmentViewDelegate {
    // FIXME: copy and paste from TinelineTableViewController
    func attachmentView(_ attachmentView: AttachmentView, imageTapped imageView: UIImageView, withImageViews imageViews: [UIImageView], withAttachments attachments: [Attachment], selectedIndex index: Int) {

        attachmentGallery = AttachmentGallery(attachments: attachments, imageViews: imageViews)
        let closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        closeButton.setTitle("❌", for: .normal)
        let galleryViewController = GalleryViewController(startIndex: index, itemsDatasource: attachmentGallery!, displacedViewsDatasource: attachmentGallery, configuration: [
            GalleryConfigurationItem.closeButtonMode(.custom(closeButton)),
            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
            GalleryConfigurationItem.thumbnailsButtonMode(.none),
        ])

        presentImageGallery(galleryViewController)
    }
}

extension TootDetailViewController: TootTableViewCellDelegate {
    func tootTableViewCellMoreButtonTapped(_ cell: TootTableViewCell) {
        // FIXME: copy from TimelineTableViewController
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Open in Safari", style: .default, handler: { _ in
            if let url = cell.status.url.url {
                UIApplication.shared.openURL(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { [weak self] _ in
            let shareText = cell.contentTextView.text
            let shareWebsite = cell.status.url.url
            let shareImage: UIImage?
            if cell.attachmentView.images?.isEmpty == false {
                shareImage = cell.attachmentView.images[0].image
            } else {
                shareImage = nil
            }

            let activityItems = ([shareText, shareWebsite, shareImage] as [Any?]).flatMap { $0 }
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

            self?.present(activityVC, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Copy text", style: .default, handler: { _ in
            UIPasteboard.general.setValue(cell.contentTextView.text, forPasteboardType: "public.text")
        }))
        /* // TODO: Implement them
         alert.addAction(UIAlertAction(title: "Mute", style: .default, handler: { _ in
         }))
         alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { _ in
         }))
         */
        alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { _ in
            let req = MastodonAPI.AddReport(
                accountId: cell.status.account.id,
                statusIds: [cell.status.id],
                comment: ""
            )
            Session.send(req) { [weak self] (result) in
                switch result {
                case .success(_):
                    let alert = UIAlertController(title: "Reported", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                case .failure(_):
                    let alert = UIAlertController(title: "Report failed", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))
        present(alert, animated: true, completion: nil)
    }

    // FIXME: copy and paste from TinelineTableViewController
    func tootTableViewCell(_ cell: TootTableViewCell, shouldMoveTo link: StatusLink) {
        switch link {
        case .tag(let tag):
            performSegue(withIdentifier: "ShowTimeline", sender: ["withTag" :tag])
        case .mention(let mention):
            performSegue(withIdentifier: "ShowProfile", sender: ["withMention": mention])
        case .attachment(_, let offset):
            attachmentView(cell.attachmentView, imageTapped: cell.attachmentView.images[offset], withImageViews: cell.attachmentView.images, withAttachments: cell.attachmentView.attachments, selectedIndex: offset)
        case .link(let url):
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
}
