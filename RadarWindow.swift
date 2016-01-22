//
//  RadarWindow.swift
//  Meteorologist
//
//  Swift code written by Ed Danley on 9/19/15.
//  Copyright © 2015 The Meteorologist Group, LLC. All rights reserved.
//
//  Original source by Joe Crobak and Meteorologist Group
//  Some new graphics by Matthew Fahrenbacher
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify,
//  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
//  OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Cocoa
import WebKit

class RadarWindow: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var radarDisplayWebView: WebView!
    @IBOutlet weak var radarWind: NSWindow!

    var radarURL = "http://www.weather.com/weather/radar/interactive/l/"

    var weatherComTag = "USIL0828"

    // Allow Command-W to close the window
    override func keyDown(theEvent: (NSEvent!))
    {
        if theEvent.modifierFlags.contains(.CommandKeyMask) {
            switch theEvent.charactersIgnoringModifiers! {
            case "w":
                self.window?.close()
            default:
                break
            }
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.center()
        self.window?.makeKeyAndOrderFront(self)
        NSApp.activateIgnoringOtherApps(true)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var ourURL = radarURL
        if (defaults.stringForKey("weatherSource")! == YAHOO_WEATHER) {
            ourURL.appendContentsOf(weatherComTag)
        }
        else if (defaults.stringForKey("weatherSource")! == "1") {
            ourURL = weatherComTag
        }
        
        radarWind.title = NSLocalizedString("Radar_", // Unique key of your choice
            value:"Radar", // Default (English) text
            comment:"Radar")
        radarDisplayWebView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: ourURL)!))
        
    }
    
    override var windowNibName : String! {
        return "RadarWindow"
    }

    override func windowWillLoad() {
    }
    
    func windowWillClose(notification: NSNotification) {
    }

    func radarDisplay(weatherTag: String) {
        
        weatherComTag = weatherTag
        
    } // radarDisplay

} // class RadarWindow
