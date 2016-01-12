//
//  FirstViewController.swift
//  DownloadTask
//
//  Created by 牟潇 on 16/1/12.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {

    private var mainTableView:UITableView?
    private var taskList:[DownLoadTask]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title="正在下载"
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action:Selector("addTask"));
        self.mainTableView = UITableView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.mainTableView?.delegate = self
        self.mainTableView?.dataSource = self
        self.view.addSubview(self.mainTableView!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadData"), name: DownloadTaskNotification.Finish.rawValue, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    func addTask(){
        MXDownLoader.sharedInstance.newTask("https://nodejs.org/dist/v4.2.3/node-v4.2.3.pkg")
        self.reloadData()
        
    }
    func reloadData() {
        taskList = MXDownLoader.sharedInstance.unFinishedTask()
        self.mainTableView?.reloadData()
    
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskList == nil ? 0 : self.taskList!.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("DownLoadCell") as?DownLoadCell
        if cell == nil{
            cell = DownLoadCell(style: UITableViewCellStyle.Default, reuseIdentifier:"DownLoadCell");
        }
        cell?.updateData((self.taskList?[indexPath.row])!)
        return cell!
   }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadData();
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class DownLoadCell:UITableViewCell {
    var labelName:UILabel = UILabel()
    var labelSize:UILabel = UILabel()
    var labelProgress:UILabel = UILabel()
    var downLoadTask:DownLoadTask?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(labelName);
        self.addSubview(labelSize);
        self.addSubview(labelProgress);
        self.labelName.font = UIFont.systemFontOfSize(14)
        self.labelSize.font = UIFont.systemFontOfSize(14)
        self.labelProgress.font = UIFont.systemFontOfSize(14)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateProgress:"), name: DownloadTaskNotification.Progress.rawValue, object: nil);

    
    }
    func updateProgress(notification:NSNotification) {
        guard let info = notification.object as? NSDictionary else {return}
        if let taskidentifier = info["taskIdentifier"] as? NSNumber{
            if taskidentifier.integerValue == self.downLoadTask?.taskIdentifier{
                guard let written = info["totalBytesWritten"] as? NSNumber else{return}
                guard let total = info["totalBytesExpectedToWrite"] as? NSNumber else{return}
                let formattedWrittenSize = NSByteCountFormatter.stringFromByteCount(written.longLongValue, countStyle: NSByteCountFormatterCountStyle.File)
                let formattedTotalSize = NSByteCountFormatter.stringFromByteCount(total.longLongValue, countStyle: NSByteCountFormatterCountStyle.File)
                self.labelSize.text = "\(formattedWrittenSize) / \(formattedTotalSize)"
                self.labelSize.text = "\(formattedWrittenSize) / \(formattedTotalSize)"
                let percentage = Int((written.doubleValue / total.doubleValue) * 100.0)
                self.labelProgress.text = "\(percentage)%"

            }
        }
    }
    func updateData(task : DownLoadTask) {
        
        self.downLoadTask = task
        labelName.text = self.downLoadTask?.url.lastPathComponent
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.labelName.frame = CGRectMake(20, 10, self.contentView.frame.size.width - 50, 20)
        self.labelSize.frame = CGRectMake(20, 40, self.contentView.frame.size.width - 50, 20)
        self.labelProgress.frame = CGRectMake(self.contentView.frame.size.width - 45, 20, 40, 30)
        
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
