//
//  PopOverViewController
//

import Foundation

open class PopOverViewController: UITableViewController, UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    fileprivate var _cornerRadius: CGFloat = 16
    open var cornerRadius: CGFloat {
        set {
            _cornerRadius = newValue
            view.superview?.layer.cornerRadius = newValue
        }
        get {
            return _cornerRadius
        }
    }
    
    fileprivate var _width: CGFloat = 230
    open var width: CGFloat {
        set {
            _width = newValue
            view.frame.size.width = newValue
            preferredContentSize.width = newValue
        }
        get {
            return _width
        }
    }
    fileprivate var _heightPerItem: CGFloat = 44
    open var heightPerItem: CGFloat {
        set {
            _heightPerItem = newValue
            view.frame.size.height = CGFloat(titles.count) * newValue
            preferredContentSize.height = CGFloat(titles.count) * newValue
            tableView.reloadData()
        }
        get {
            return _heightPerItem
        }
    }
    
    fileprivate var titles:Array<String> = []
    fileprivate var imageNames:Array<String?> = []
    fileprivate var selectedImageNames:Array<String?> = []
    
    fileprivate var titleColor:UIColor = UIColor.black
    fileprivate var selectedTitleColor:UIColor = UIColor.black

    fileprivate var descriptions:Array<String>?
    @objc open var completionHandler: ((_ selectRow: Int) -> Void)?
    fileprivate var selectedRows:Set<Int> = Set<Int>()
    
    fileprivate var separ:Int?
    
    fileprivate var separatorStyle: UITableViewCellSeparatorStyle = UITableViewCellSeparatorStyle.none
    fileprivate var showsVerticalScrollIndicator:Bool = false
    
    @objc open static func instantiateFromStoryboard() -> PopOverViewController {
        let storyboardsBundle = getStoryboardsBundle()
        let storyboard:UIStoryboard = UIStoryboard(name: "PopOver", bundle: storyboardsBundle)
        let popOverViewController:PopOverViewController = storyboard.instantiateViewController(withIdentifier: "PopOverViewController") as! PopOverViewController
        
        popOverViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        popOverViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        
        // arrow color
        popOverViewController.popoverPresentationController?.backgroundColor = UIColor.white
        
        popOverViewController.popoverPresentationController?.delegate = popOverViewController

        return popOverViewController
    }
    
    open static func instantiate(withSourceView sourceView: UIView) -> PopOverViewController {
        let popOverViewController = PopOverViewController()
        
        popOverViewController.modalPresentationStyle = .popover
        popOverViewController.popoverPresentationController?.sourceView = sourceView
        popOverViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        popOverViewController.presentationController?.delegate = popOverViewController
        
        return popOverViewController
    }
    
    open static func instantiate(withBarButtonItem barButtonItem: UIBarButtonItem) -> PopOverViewController {
        let popOverViewController = PopOverViewController()
        
        popOverViewController.modalPresentationStyle = .popover
        popOverViewController.popoverPresentationController?.barButtonItem = barButtonItem
        popOverViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        popOverViewController.presentationController?.delegate = popOverViewController
        
        return popOverViewController
    }

    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame = CGRect(x: 0, y: 0, width: width, height: CGFloat(titles.count) * heightPerItem);
        self.preferredContentSize = CGSize(width: width, height: CGFloat(titles.count) * heightPerItem);

        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
        tableView.tableFooterView = UIView()
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        tableView.separatorStyle = separatorStyle
        tableView.accessibilityIdentifier = "PopUpTableView"

    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.superview?.layer.cornerRadius = _cornerRadius
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - table
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return _heightPerItem
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        let title:String? = titles[indexPath.row]
        
        // If explanation text is coming, display it in two lines
        if (descriptions == nil) {
            let reuseIdentifier = "SingleTitleCell"
            if let c = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
                cell = c
            } else {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
            }
            cell.textLabel?.text = title
        } else {
            let description:String? = descriptions?[indexPath.row]

            if (description?.count)! > 0 {
                let reuseIdentifier = "SubTitleCell"
                if let c = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
                    cell = c
                } else {
                    cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
                }

                cell.textLabel?.text = title
                cell.detailTextLabel?.text = description
            } else {
                let reuseIdentifier = "SingleTitleCell"
                if let c = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) {
                    cell = c
                } else {
                    cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
                }
                cell.textLabel?.text = title
            }
        }
        
        if !selectedRows.contains(indexPath.row) {
            cell.textLabel?.textColor = titleColor
            if indexPath.row < imageNames.count, let imageName = imageNames[indexPath.row] {
                cell.imageView?.image = UIImage(named: imageName)
            } else {
                cell.imageView?.image = nil
            }
            cell.accessoryType = .none
        } else {
            cell.textLabel?.textColor = selectedTitleColor
            if indexPath.row < selectedImageNames.count, let imageName = selectedImageNames[indexPath.row] {
                cell.imageView?.image = UIImage(named: imageName)
                cell.accessoryType = .none
            } else if indexPath.row < imageNames.count, let imageName = imageNames[indexPath.row] {
                cell.imageView?.image = UIImage(named: imageName)
                cell.accessoryType = .none
            } else {
                cell.imageView?.image = nil
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }

        return cell
    }
    
    @objc open func setTitles(_ titles:Array<String>) {
        self.titles = titles
        view.frame.size.height = CGFloat(titles.count) * _heightPerItem
        preferredContentSize.height = CGFloat(titles.count) * _heightPerItem
        tableView.reloadData()
    }
    
    @objc open func setImageNames(_ imageNames:Array<String>) {
        self.imageNames = imageNames
    }

    open func setImageNames(_ imageNames:Array<String?>) {
        self.imageNames = imageNames
    }
    
    @objc open func setSelectedImageNames(_ imageNames:Array<String>) {
        self.selectedImageNames = imageNames
    }
    
    open func setSelectedImageNames(_ imageNames:Array<String?>) {
        self.selectedImageNames = imageNames
    }
    
    @objc open func setDescriptions(_ descriptions:Array<String>) {
        self.descriptions = descriptions
    }
    
    @objc open func setTitleColor(_ color:UIColor) {
        self.titleColor = color
        tableView.reloadData()
    }
    
    @objc open func setSelectedTitleColor(_ color:UIColor) {
        self.selectedTitleColor = color
        let sr = selectedRows.map({ (row) -> IndexPath in
            return IndexPath(row: row, section: 0)
        })
        tableView.reloadRows(at: sr, with: .automatic)
    }
    
    @objc open func setSelectRow(_ selectRow:Int) {
        deselectRows(selectedRows)
        selectRows([selectRow])
    }
    
    @objc open func selectRows(_ rows: Set<Int>) {
        selectedRows.formUnion(rows)
        let sr = selectedRows.map({ (row) -> IndexPath in
            return IndexPath(row: row, section: 0)
        })
        tableView.reloadRows(at: sr, with: .automatic)
    }

    @objc open func deselectRows(_ rows: Set<Int>) {
        selectedRows.subtract(rows)
        let sr = selectedRows.map({ (row) -> IndexPath in
            return IndexPath(row: row, section: 0)
        })
        tableView.reloadRows(at: sr, with: .automatic)
    }

    @objc open func setSeparatorStyle(_ separatorStyle:UITableViewCellSeparatorStyle) {
        self.separatorStyle = separatorStyle
    }
    
    @objc open func setShowsVerticalScrollIndicator(_ showsVerticalScrollIndicator:Bool) {
        self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
    }
    
    @objc open func setCornerRadius(_ cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    /**
     * didSelectRowAtIndexPath
     */
    override open func tableView(_ tableview: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.dismiss(animated: true, completion: {
            if self.completionHandler != nil {
                let selectRow:Int = indexPath.row
                self.completionHandler!(selectRow)
            }
        })
    }
    
    static func getStoryboardsBundle() -> Bundle {
        let podBundle = Bundle(for: PopOverViewController.self)
        let bundleURL = podBundle.url(forResource: "Storyboards", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        
        return bundle
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

