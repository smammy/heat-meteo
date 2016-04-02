//
//  LogUtils.swift
//  Meteorologist
//
//  Created by Ed Danley on 11/15/15.
//  Copyright © 2015 The Meteorologist Group, LLC. All rights reserved.
//
//  Code taken from: https://gist.github.com/vtardia/3f7d17efd7b258e82b62
//

import Foundation

var logFileHandle: NSFileHandle?
var original_stderr: Int32?;

#if DEBUG_1
    func DebugLog(message: String, file: String = __FILE__, line: Int = __LINE__) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Debug>: " + message + " [" + file + ":%i]", line) }()
        }
    }
    
    func InfoLog(message: String, file: String = __FILE__, line: Int = __LINE__) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Info>: " + message + " [" + file + ":%i]", line) }()
        }
    }
    
    func WarningLog(message: String, file: String = __FILE__, line: Int = __LINE__) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Warning>: " + message + " [" + file + ":%i]", line) }()
        }
    }
    
    func ErrorLog(message: String, file: String = __FILE__, line: Int = __LINE__) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Error>: " + message + " [" + file + ":%i]", line) }()
        }
    }
#else
    func DebugLog(message: String, file: String = __FILE__, line: Int = __LINE__) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            // Uncomment this statement for Debug level messages
            //return { NSLog("<Debug>: " + message) }()
        }
    }
    
    func InfoLog(message: String, file: String = __FILE__, line: Int = __LINE__) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Info>: " + message) }()
        }
    }
    
    func WarningLog(message: String, file: String = __FILE__, line: Int = __LINE__) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Warning>: " + message) }()
        }
    }
    
    func ErrorLog(message: String, file: String = __FILE__, line: Int = __LINE__) {
        //let defaults = NSUserDefaults.standardUserDefaults()
        //if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Error>: " + message) }()
        //}
    }
#endif


// Redirect log to /Library/Logs/<AppName>.log
func SetCustomLogFilename(name: String) {
    
    var logDirectory: NSURL
    // Search log directory path
    do {
        try logDirectory = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.LibraryDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: true).URLByAppendingPathComponent("Logs/")
    } catch {
        return
    }

    // Calculate full log file path
    if let logFilePath = logDirectory.URLByAppendingPathComponent(String(format:"%@.log", name)) as NSURL! {
        
        // Save STDERR
        let stderr = NSFileHandle.fileHandleWithStandardError()
        original_stderr = dup(stderr.fileDescriptor)
        
        // Create an empty log file at path, NSFileHandle doesn't do it!
        if !NSFileManager.defaultManager().isWritableFileAtPath(logFilePath.path!) {
            do {
                try "".writeToFile(logFilePath.path!, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                return
            }
        }
        
        if let logFileHandle = NSFileHandle(forWritingAtPath: logFilePath.path!) {
            
            // (Try to) Redirect STDERR to log file
            let err:Int32? = dup2(logFileHandle.fileDescriptor, stderr.fileDescriptor)
            
            // Something went wrong
            if (err == -1) {
                ErrorLog(String(format:"Could not redirect stderr, error %d", errno))
            }
        }
    }
} // SetCustomLogFilename
