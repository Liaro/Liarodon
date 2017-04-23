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
import Result

enum TimelineType {
    case home
    case local
    case federated
    case account(Int)
    case tag(String)
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
        case .account:
            title = "Account"
        case .tag(let tag):
            title = "\(tag)"
        }

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        indicator.activityIndicatorViewStyle = .gray
        indicator.startAnimating()
        tableView.tableFooterView = indicator

        if MastodonAPI.instanceURL == nil {
            return
        }
        fetchInitialTimeline()


        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TimelineTableViewController.pullToRefresh), for: .valueChanged)
        self.refreshControl = refreshControl
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pullToRefresh() {
        loadNewer()
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
                self?.fetchInitialTimelineCompleted(result: result)
            }
            return
        case .account(let id):
            let request = MastodonAPI.GetAccountTimelineRequest(accountId: id)
            Session.send(request) { [weak self] (result) in
                self?.fetchInitialTimelineCompleted(result: result)
            }
            return
        case .tag(let tag):
            let request = MastodonAPI.GetTagTimelineRequest(tag: tag, isLocal: false)
            Session.send(request) { [weak self] (result) in
                self?.fetchInitialTimelineCompleted(result: result)
            }
            return
        case .local:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: true)
        case .federated:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: false)
        }
        Session.send(request) { [weak self] (result) in
            self?.fetchInitialTimelineCompleted(result: result)
        }
    }

    private func fetchInitialTimelineCompleted(result: Result<[Status], SessionTaskError>) {
        switch result {
        case .success(let statuses):
            self.statuses = statuses
            tableView.reloadData()

        case .failure(let error):
            print(error)
        }
        loading = false
    }

    func loadNewer() {
        if loading {
            refreshControl?.endRefreshing()
            return
        }
        loading = true

        let request: MastodonAPI.GetPublicTimelineRequest
        switch type! {
        case .home:
            let request = MastodonAPI.GetHomeTimelineRequest(sinceId: statuses.first?.id)
            Session.send(request) { [weak self] (result) in
                self?.loadNewerCompleted(result: result)
            }
            return
        case .account(let id):
            let request = MastodonAPI.GetAccountTimelineRequest(accountId: id, sinceId: statuses.first?.id)
            Session.send(request) { [weak self] (result) in
                self?.loadNewerCompleted(result: result)
            }
            return
        case .tag(let tag):
            let request = MastodonAPI.GetTagTimelineRequest(tag: tag, isLocal: false, sinceId: statuses.first?.id)
            Session.send(request) { [weak self] (result) in
                self?.loadNewerCompleted(result: result)
            }
            return
        case .local:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: true, sinceId: statuses.first?.id)
        case .federated:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: false, sinceId: statuses.first?.id)
        }
        Session.send(request) { [weak self] (result) in
            self?.loadNewerCompleted(result: result)
        }
    }
    private func loadNewerCompleted(result: Result<[Status], SessionTaskError>) {
        refreshControl?.endRefreshing()
        switch result {
        case .success(let statuses):
            self.statuses =  statuses + self.statuses
            let offset = tableView.estimatedRowHeight * CGFloat(statuses.count)
            tableView.reloadData()
            tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + offset)
        case .failure(let error):
            print(error)
        }
        loading = false
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
                self?.loadOlderCompleted(result: result)
            }
            return
        case .account(let id):
            let request = MastodonAPI.GetAccountTimelineRequest(accountId: id, maxId: statuses.last?.id)
            Session.send(request) { [weak self] (result) in
                self?.loadOlderCompleted(result: result)
            }
            return
        case .tag(let tag):
            let request = MastodonAPI.GetTagTimelineRequest(tag: tag, isLocal: false, maxId: statuses.last?.id)
            Session.send(request) { [weak self] (result) in
                self?.loadOlderCompleted(result: result)
            }
            return
        case .local:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: true, maxId: statuses.last!.id)
        case .federated:
            request = MastodonAPI.GetPublicTimelineRequest(isLocal: false, maxId: statuses.last!.id)
        }
        Session.send(request) { [weak self] (result) in
            self?.loadOlderCompleted(result: result)
        }
    }

    private func loadOlderCompleted(result: Result<[Status], SessionTaskError>) {
        switch result {
        case .success(let statuses):
            self.statuses = self.statuses + statuses
            tableView.reloadData()
        case .failure(let error):
            print(error)
        }
        loading = false
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailToot" {
            let tootDetailViewController = segue.destination as! TootDetailViewController
            if let row = tableView.indexPathForSelectedRow?.row {
                tootDetailViewController.targetStatus = statuses[row]
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

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

    func tootTableViewCellMoreButtonTapped(_ cell: TootTableViewCell) {
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
