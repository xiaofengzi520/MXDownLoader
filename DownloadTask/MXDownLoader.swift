//
//  TaskManager.swift
//  DownloadTask
//
//  Created by 牟潇 on 16/1/12.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import UIKit


enum DownloadTaskNotification:String{
    case Progress = "downloadNotificationProgress"
    case Finish = "downloadNotificationFinish"
    case Identifier = "downloadTaskSession"
}

class MXDownLoader: NSObject,NSURLSessionDownloadDelegate {
    private var session:NSURLSession?
    var taskList:[DownLoadTask] = [DownLoadTask]()
    static var sharedInstance:MXDownLoader = MXDownLoader()
    override init() {
        super.init()
        let conig = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(DownloadTaskNotification.Identifier.rawValue);
        self.session = NSURLSession(configuration: conig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        self.taskList = [DownLoadTask]()
        self.loadTaskList()
    }
    func unFinishedTask()->[DownLoadTask]{
        return taskList.filter{ task in
            return task.finished == false
        }
    }
    func finishedTask()->[DownLoadTask]{
        return taskList.filter{ task in
            return task.finished == true
        }
    }
    func saveTaskList(){
        let jsonArray = NSMutableArray()
        for task in taskList{
            let jsdonItem = NSMutableDictionary()
            jsdonItem["url"] = task.url.absoluteString
            jsdonItem["taskIdentifier"] = NSNumber(long: task.taskIdentifier)
            jsdonItem["finished"] = NSNumber(bool: task.finished)
            jsonArray.addObject(jsdonItem)
        }
        do{
            let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonArray, options: NSJSONWritingOptions.PrettyPrinted);
            NSUserDefaults.standardUserDefaults().setObject(jsonData, forKey: "taskList4");
            NSUserDefaults.standardUserDefaults().synchronize();
        }catch{
            
        }
    }
    func loadTaskList(){
        if let jsonData:NSData = NSUserDefaults.standardUserDefaults().objectForKey("taskList4") as?NSData{
            do{
                guard let jsonArray:NSArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.AllowFragments) as?NSArray else{return}
                for jsonItem in jsonArray{
                    if let item:NSDictionary = jsonItem as?NSDictionary{
                        guard let urlString = item["url"] as?String else{return}
                        guard let taskIdentifier = item["taskIdentifier"]?.longValue else{return}
                        guard let finished = item["finished"]?.boolValue else{return}
                        var downloadTask = DownLoadTask(url: NSURL(string: urlString)!, taskIdentifier: taskIdentifier);
                        downloadTask.finished = finished
                        self.taskList.append(downloadTask)
                    }
                }
            }catch{
                
            }
        }
        
    }
    func newTask(url:String){
        if let url = NSURL(string: url){
            let downLoadTask = self.session?.downloadTaskWithURL(url);
            downLoadTask?.resume()
            let task = DownLoadTask(url: url, taskIdentifier: downLoadTask!.taskIdentifier)
            self.taskList.append(task)
            self.saveTaskList()
        }
    }
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        var fileName = ""
        for var i = 0; i < self.taskList.count; i++ {
            if self.taskList[i].taskIdentifier == downloadTask.taskIdentifier{
                self.taskList[i].finished = true
                fileName = self.taskList[i].url.lastPathComponent!;
            }
        }
        if let documentUrl = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first{
            let destUrl = documentUrl.URLByAppendingPathComponent(fileName)
            do{
               try NSFileManager.defaultManager().moveItemAtURL(location, toURL: destUrl)
            }catch{
                
            }
            self.saveTaskList()
            NSNotificationCenter.defaultCenter().postNotificationName(DownloadTaskNotification.Finish.rawValue, object: downloadTask.taskIdentifier);
        }
    }
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    }
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progressInfo = ["taskIdentifier": downloadTask.taskIdentifier,
            "totalBytesWritten": NSNumber(longLong: totalBytesWritten),
            "totalBytesExpectedToWrite": NSNumber(longLong: totalBytesExpectedToWrite)]
        NSNotificationCenter.defaultCenter().postNotificationName(DownloadTaskNotification.Progress.rawValue, object: progressInfo)


    }
}
