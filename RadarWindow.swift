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

    let radarURL = "http://www.weather.com/weather/radar/interactive/l/"
    
    // THIS NEEDS LOTS OF WORK - RIGHT NOW IS HARD CODED TO WEATHER.COM
    // THIS NEEDS LOTS OF WORK - RIGHT NOW IS HARD CODED TO WEATHER.COM
    // THIS NEEDS LOTS OF WORK - RIGHT NOW IS HARD CODED TO WEATHER.COM
    // THIS NEEDS LOTS OF WORK - RIGHT NOW IS HARD CODED TO WEATHER.COM
    // THIS NEEDS LOTS OF WORK - RIGHT NOW IS HARD CODED TO WEATHER.COM

    var weatherComTag = "60565"

    // Allow Command-W to close the window
    override func keyDown(with theEvent: (NSEvent!))
    {
        if theEvent.modifierFlags.contains(.command) {
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
        NSApp.activate(ignoringOtherApps: true)
        
        let defaults = UserDefaults.standard
        var ourURL = radarURL
        
        let weatherDataSource = defaults.string(forKey: "weatherSource_1")!

        if (weatherDataSource == YAHOO_WEATHER) {
            ourURL.append(weatherComTag)
        }
        else if (weatherDataSource == OPENWEATHERMAP) {
            ourURL.append(weatherComTag)
        }
        else if (weatherDataSource == WEATHERUNDERGROUND) {
            ourURL.append(weatherComTag)
        }
        else{
            let i = Int(defaults.string(forKey: "weatherSource")!)! + 1
            // Something bad should happen to let the developer know this option hasn't been implemented ...
            let ErrorMsg = String(format:"Radar option %d hasn't been implemented", i)
            ErrorLog(ErrorMsg)
            let alert:NSAlert = NSAlert()
            alert.messageText = ErrorMsg
            alert.informativeText = "Contact the developer and choose another weather source"
            alert.runModal()
            //self.window!.makeKeyAndOrderFront(self.window!)
        }
        
        radarWind.title = NSLocalizedString("Radar_", // Unique key of your choice
            value:"Radar", // Default (English) text
            comment:"Radar")
        radarDisplayWebView.mainFrame.load(URLRequest(url: URL(string: ourURL)!))
        
    }
    
    override var windowNibName : String! {
        return "RadarWindow"
    }

    override func windowWillLoad() {
    }
    
    func windowWillClose(_ notification: Notification) {
    }

    func radarDisplay(_ weatherTag: String) {
        
        weatherComTag = weatherTag
        
    } // radarDisplay

} // class RadarWindow
