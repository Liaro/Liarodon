//
//  TimelineTableViewController.swift
//  Liarodon
//
//  Created by 131e55 on 2017/04/18.
//  Copyright © 2017年 Liaro Inc. All rights reserved.
//

import UIKit
import APIKit
import ImageViewer
import Kingfisher
import SafariServices

enum TimelineType {
    case home
    case local
    case federated
}

protocol AccountChangedRefreshable {
    func shouldRefresh()
}

final class TimelineTableViewController: UITableViewController {

    var type: TimelineType!
    var statuses = [Status]()
    let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
    var loading = true
    fileprivate var attachmentGallery: AttachmentGallery?

    override func viewDidLoad() {
        super.viewDidLoad()

        switch type! {
        case .home:
            title = "Home"
        case .local:
            title = "Local"
        case .federated:
            title = "Federated"
        }

        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension

        indicator.activityIndicatorViewStyle = .gray
        indicator.startAnimating()
        tableView.tableFooterView = indicator

        if MastodonAPI.instanceURL == nil {
            return
        }
        fetchInitialTimeline()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statuses.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Toot", for: indexPath) as! TootTableViewCell

        cell.configureCell(status: statuses[indexPath.row])
        cell.attachmentView.delegate = self
        cell.delegate = self

        return cell
    }

    func fetchInitialTimeline() {
        loading = true

        let request: MastodonAPI.GetPublicTimelineRequest
        switch type! {
        case .home:
            let request = MastodonAPI.GetHomeTimelineRequest()
            Session.send(request) { [weak self] (result) in
                guard let s = self else {
                    return
                }

                switch result {
                case .success(let statuses):
                    s.statuses = statuses
                    s.tableView.reloadData()

                case .failure(let error):
                    print(error)
                }
                s.loading = false
            }
            return
        case .local:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: true)
        case .federated:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: false)
        }
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {
            case .success(let statuses):
                s.statuses = statuses
                s.tableView.reloadData()

            case .failure(let error):
                print(error)
            }
            s.loading = false
        }
    }

    func loadOlder() {
        if loading {
            return
        }
        loading = true

        let request: MastodonAPI.GetPublicTimelineRequest
        switch type! {
        case .home:
            let request = MastodonAPI.GetHomeTimelineRequest(maxId: statuses.last?.id)
            Session.send(request) { [weak self] (result) in
                guard let s = self else {
                    return
                }

                switch result {
                case .success(let statuses):
                    s.statuses = s.statuses + statuses
                    s.tableView.reloadData()

                case .failure(let error):
                    print(error)
                }
                s.loading = false
            }
            return
        case .local:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: true, maxId: statuses.last!.id)
        case .federated:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: false, maxId: statuses.last!.id)
        }
        Session.send(request) { [weak self] (result) in
            guard let s = self else {
                return
            }

            switch result {
            case .success(let statuses):
                s.statuses = s.statuses + statuses
                s.tableView.reloadData()

            case .failure(let error):
                print(error)
            }
            s.loading = false
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - tableView.frame.size.height {
            loadOlder()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TimelineTableViewController: AccountChangedRefreshable {
    func shouldRefresh() {
        statuses = []
        fetchInitialTimeline()
    }
}

extension TimelineTableViewController: AttachmentViewDelegate {

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

extension TimelineTableViewController: TootTableViewCellDelegate {
    func tootTableViewCell(_ cell: TootTableViewCell, shouldMoveTo link: StatusLink) {
        switch link {
        case .tag(let tag):
            break // TODO
        case .mention(let mention):
            break // TODO
        case .attachment(_, let offset):
            attachmentView(cell.attachmentView, imageTapped: cell.attachmentView.images[offset], withImageViews: cell.attachmentView.images, withAttachments: cell.attachmentView.attachments, selectedIndex: offset)
        case .link(let url):
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
}

class AttachmentGallery {

    let attachments: [Attachment]
    let imageViews: [UIImageView]
    let galleryItems: [GalleryItem]
    init(attachments: [Attachment], imageViews: [UIImageView]) {
        self.attachments = attachments
        self.imageViews = imageViews

        galleryItems = attachments.map { attachment in
            switch attachment.type {
            case .image, .gifv:
                return GalleryItem.image(fetchImageBlock: { callback in
                    ImageDownloader.default.downloadImage(with: attachment.mainURL!, options: [], progressBlock: nil) {
                        (image, error, url, data) in
                        callback(image)
                    }
                })
            case .video:
                return GalleryItem.video(fetchPreviewImageBlock: { callback in
                    ImageDownloader.default.downloadImage(with: attachment.smallURL!, options: [], progressBlock: nil) {
                        (image, error, url, data) in
                        callback(image)
                    }
                }, videoURL: attachment.mainURL!)
            }
        }

    }
}

extension AttachmentGallery: GalleryDisplacedViewsDatasource {

    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        if index < imageViews.count {
            return imageViews[index]
        } else {
            return nil
        }
    }
}

extension AttachmentGallery: GalleryItemsDatasource {

    func itemCount() -> Int {
        return attachments.count
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return galleryItems[index]
    }
}

extension UIImageView: DisplaceableView {}
