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

var logFileHandle: FileHandle?
var original_stderr: Int32?;

#if DEBUG_1
    func DebugLog(message: String, file: String = #file, line: Int = #line) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Debug>: " + message + " [" + file + ":%i]", line) }()
        }
    }
    
    func InfoLog(message: String, file: String = #file, line: Int = #line) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Info>: " + message + " [" + file + ":%i]", line) }()
        }
    }
    
    func WarningLog(message: String, file: String = #file, line: Int = #line) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Warning>: " + message + " [" + file + ":%i]", line) }()
        }
    }
    
    func ErrorLog(message: String, file: String = #file, line: Int = #line) {
        //let defaults = NSUserDefaults.standardUserDefaults()
        //if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Error>: " + message + " [" + file + ":%i]", line) }()
        //}
    }
#else
    func DebugLog(_ message: String, file: String = #file, line: Int = #line) {
        let defaults = UserDefaults.standard
        if (defaults.string(forKey: "logMessages")! == "1") {
            // Uncomment this statement for Debug level messages
            //return { NSLog("<Debug>: " + message) }()
        }
    }
    
    func InfoLog(_ message: String, file: String = #file, line: Int = #line) {
        let defaults = UserDefaults.standard
        if (defaults.string(forKey: "logMessages")! == "1") {
            return { NSLog("<Info>: " + message) }()
        }
    }
    
    func WarningLog(_ message: String, file: String = #file, line: Int = #line) {
        let defaults = UserDefaults.standard
        if (defaults.string(forKey: "logMessages")! == "1") {
            return { NSLog("<Warning>: " + message) }()
        }
    }
    
    func ErrorLog(_ message: String, file: String = #file, line: Int = #line) {
        //let defaults = NSUserDefaults.standardUserDefaults()
        //if (defaults.stringForKey("logMessages")! == "1") {
            return { NSLog("<Error>: " + message) }()
        //}
    }
#endif


// Redirect log to /Library/Logs/<AppName>.log
func SetCustomLogFilename(_ name: String) {
    
    var logDirectory: URL
    // Search log directory path
    do {
        try logDirectory = FileManager.default.url(for: FileManager.SearchPathDirectory.libraryDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Logs/")
    } catch {
        return
    }

    // Calculate full log file path
    if let logFilePath = logDirectory.appendingPathComponent(String(format:"%@.log", name)) as URL? {
        
        // Save STDERR
        let stderr = FileHandle.standardError
        original_stderr = dup(stderr.fileDescriptor);
        
        // Create an empty log file at path, NSFileHandle doesn't do it!
        if !FileManager.default.isWritableFile(atPath: logFilePath.path) {
            do {
                try "".write(toFile: logFilePath.path, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                return
            }
        }
        
        if let logFileHandle = FileHandle(forWritingAtPath: logFilePath.path) {
            
            // (Try to) Redirect STDERR to log file
            let err:Int32? = dup2(logFileHandle.fileDescriptor, stderr.fileDescriptor)
            
            // Something went wrong
            if (err == -1) {
                ErrorLog(String(format:"Could not redirect stderr, error %d", errno))
            }
        }
    }
} // SetCustomLogFilename
