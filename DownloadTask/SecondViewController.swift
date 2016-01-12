//
//  SecondViewController.swift
//  DownloadTask
//
//  Created by 牟潇 on 16/1/12.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import UIKit
struct DownLoadTask {
    var url:NSURL;
    var localURL:NSURL?;
    var taskIdentifier:Int;
    var finished:Bool = false;
    init(url:NSURL, taskIdentifier:Int){
        self.url = url;
        self.taskIdentifier = taskIdentifier;
    }
}

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

