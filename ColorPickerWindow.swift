//
//  ColorPickerWindow.swift
//  Meteo2
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
//  https://www.youtube.com/watch?v=npFZ3YvSGNo
//

import Cocoa

class ColorPickerWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var closeButton: NSButton!
    
    @IBOutlet weak var fontName: NSPopUpButton!
    @IBOutlet weak var fontSize: NSPopUpButton!
    
    @IBOutlet weak var textLabel: NSTextField!
    @IBOutlet weak var backgroundLabel: NSTextField!
    @IBOutlet weak var meteorologistLabel: NSTextField!
    
    @IBOutlet weak var redTextLabel: NSTextField!
    @IBOutlet weak var greenTextLabel: NSTextField!
    @IBOutlet weak var blueTextLabel: NSTextField!
    @IBOutlet weak var redTextSlider: NSSlider!
    @IBOutlet weak var greenTextSlider: NSSlider!
    @IBOutlet weak var blueTextSlider: NSSlider!
    
    @IBOutlet weak var redBackgroundLabel: NSTextField!
    @IBOutlet weak var greenBackgroundLabel: NSTextField!
    @IBOutlet weak var blueBackgroundLabel: NSTextField!
    @IBOutlet weak var redBackgroundSlider: NSSlider!
    @IBOutlet weak var greenBackgroundSlider: NSSlider!
    @IBOutlet weak var blueBackgroundSlider: NSSlider!
    
    @IBOutlet weak var resetButton: NSButton!
    @IBOutlet weak var transparentButton: NSButton!
    
    
    var whichFont = "menuBarFont"

    var mainW: NSWindow = NSWindow()
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window!.delegate = self
        let defaults = NSUserDefaults.standardUserDefaults()
        
        initPrefs()
        initDisplay()
        
        fontName.addItemsWithTitles(NSFontManager.sharedFontManager().availableFontFamilies)
        
        fontName.selectItemWithTitle(defaults.stringForKey(whichFont)!)
        fontSize.selectItemWithTitle(defaults.stringForKey(whichFont+"size")!)
        
        redTextSlider.doubleValue = Double(defaults.stringForKey(whichFont+"RedText")!)!
        greenTextSlider.doubleValue = Double(defaults.stringForKey(whichFont+"GreenText")!)!
        blueTextSlider.doubleValue = Double(defaults.stringForKey(whichFont+"BlueText")!)!
        
        redBackgroundSlider.doubleValue = Double(defaults.stringForKey(whichFont+"RedBackground")!)!
        greenBackgroundSlider.doubleValue = Double(defaults.stringForKey(whichFont+"GreenBackground")!)!
        blueBackgroundSlider.doubleValue = Double(defaults.stringForKey(whichFont+"BlueBackground")!)!
        
        transparentButton.state = Int(defaults.stringForKey(whichFont+"Transparency")!)!
        
        if (transparentButton.state == 1) {
            redBackgroundSlider.enabled = false
            greenBackgroundSlider.enabled = false
            blueBackgroundSlider.enabled = false
        } else {
            redBackgroundSlider.enabled = true
            greenBackgroundSlider.enabled = true
            blueBackgroundSlider.enabled = true
        }
        
        ChangeText()
        
    } // windowDidLoad
    
    //method called to display the modal window
    func beginSheet(mainWindow: NSWindow){
        //self.mainW = mainWindow
        //NSApp.beginSheet(self.window!, modalForWindow: mainWindow, modalDelegate: self, didEndSelector:nil, contextInfo: nil)
        
    }
    
    func setFont(font: String)
    {
        whichFont = font
    } // setFont
    
    func windowWillClose(notification: NSNotification) {
        saveDefaults()
    } // windowWillClose
    
    func saveDefaults() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setValue(fontName.selectedItem!.title, forKey: whichFont)
        defaults.setValue(fontSize.selectedItem!.title, forKey: whichFont+"size")
        
        defaults.setValue(redTextSlider.doubleValue, forKey: whichFont+"RedText")
        defaults.setValue(greenTextSlider.doubleValue, forKey: whichFont+"GreenText")
        defaults.setValue(blueTextSlider.doubleValue, forKey: whichFont+"BlueText")
        
        defaults.setValue(redBackgroundSlider.doubleValue, forKey: whichFont+"RedBackground")
        defaults.setValue(greenBackgroundSlider.doubleValue, forKey: whichFont+"GreenBackground")
        defaults.setValue(blueBackgroundSlider.doubleValue, forKey: whichFont+"BlueBackground")
        
        defaults.setValue(transparentButton.state, forKey: whichFont+"Transparency")
        
    } // saveDefaults
    
    func ResetButton() {
        
        fontName.selectItemWithTitle("Tahoma")
        fontSize.selectItemWithTitle("14")
        
        redTextSlider.doubleValue = 0
        greenTextSlider.doubleValue = 0
        blueTextSlider.doubleValue = 0
        
        redBackgroundSlider.doubleValue = 255
        greenBackgroundSlider.doubleValue = 255
        blueBackgroundSlider.doubleValue = 255
        
        redBackgroundSlider.enabled = false
        greenBackgroundSlider.enabled = false
        blueBackgroundSlider.enabled = false
        
        transparentButton.state = 1
        
        ChangeText()
        
    } // ResetButton
    
    func ChangeText() {
        var m = (14 as NSNumber)
        m = NSNumberFormatter().numberFromString(fontSize.selectedItem!.title)!
        let font = NSFont(name: fontName.selectedItem!.title, size: CGFloat(m))
        
        meteorologistLabel.font = font
        
        meteorologistLabel.textColor = NSColor(red: CGFloat(redTextSlider.floatValue),
            green: CGFloat(greenTextSlider.floatValue),
            blue: CGFloat(blueTextSlider.floatValue), alpha: 1.0)
        
        if (transparentButton.state == 1) {
            meteorologistLabel.drawsBackground = false
        } else {
            meteorologistLabel.drawsBackground = true
            meteorologistLabel.backgroundColor = NSColor(red: CGFloat(redBackgroundSlider.floatValue),
                green: CGFloat(greenBackgroundSlider.floatValue),
                blue: CGFloat(blueBackgroundSlider.floatValue), alpha: 1.0)
        }
    } // ChangeText
    
    func initPrefs() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.stringForKey(whichFont) == nil) {
            defaults.setValue("Tahoma", forKey: whichFont)
        }
        if (defaults.stringForKey(whichFont+"size") == nil) {
            defaults.setValue("14", forKey: whichFont+"size")
        }
        
        if (defaults.stringForKey(whichFont+"RedText") == nil) {
            defaults.setValue("0", forKey: whichFont+"RedText")
        }
        if (defaults.stringForKey(whichFont+"GreenText") == nil) {
            defaults.setValue("0", forKey: whichFont+"GreenText")
        }
        if (defaults.stringForKey(whichFont+"BlueText") == nil) {
            defaults.setValue("0", forKey: whichFont+"BlueText")
        }
        
        if (defaults.stringForKey(whichFont+"RedBackground") == nil) {
            defaults.setValue("255", forKey: whichFont+"RedBackground")
        }
        if (defaults.stringForKey(whichFont+"GreenBackground") == nil) {
            defaults.setValue("255", forKey: whichFont+"GreenBackground")
        }
        if (defaults.stringForKey(whichFont+"BlueBackground") == nil) {
            defaults.setValue("255", forKey: whichFont+"BlueBackground")
        }
        
        if (defaults.stringForKey(whichFont+"Transparency") == nil) {
            defaults.setValue("1", forKey: whichFont+"Transparency")
        }
        
    } // initPrefs
    
    func initDisplay() {
        textLabel.stringValue = NSLocalizedString("Text_", // Unique key of your choice
            value:"Text", // Default (English) text
            comment:"Text")
        backgroundLabel.stringValue = NSLocalizedString("Background_", // Unique key of your choice
            value:"Background", // Default (English) text
            comment:"Background")
        meteorologistLabel.stringValue = NSLocalizedString("Meteorologist_", // Unique key of your choice
            value:"Meteorologist", // Default (English) text
            comment:"Meteorologist")
        
        redTextLabel.stringValue = NSLocalizedString("Red_", // Unique key of your choice
            value:"Red", // Default (English) text
            comment:"Red")
        redBackgroundLabel.stringValue = NSLocalizedString("Red_", // Unique key of your choice
            value:"Red", // Default (English) text
            comment:"Red")
        greenTextLabel.stringValue = NSLocalizedString("Green_", // Unique key of your choice
            value:"Green", // Default (English) text
            comment:"Green")
        greenBackgroundLabel.stringValue = NSLocalizedString("Green_", // Unique key of your choice
            value:"Green", // Default (English) text
            comment:"Green")
        blueTextLabel.stringValue = NSLocalizedString("Blue_", // Unique key of your choice
            value:"Blue", // Default (English) text
            comment:"Blue")
        blueBackgroundLabel.stringValue = NSLocalizedString("Blue_", // Unique key of your choice
            value:"Blue", // Default (English) text
            comment:"Blue")
        
        resetButton.title = NSLocalizedString("Reset_", // Unique key of your choice
            value:"Reset", // Default (English) text
            comment:"Reset")
        
        closeButton.title = NSLocalizedString("Close_", // Unique key of your choice
            value:"Close", // Default (English) text
            comment:"Close")
        
        transparentButton.title = NSLocalizedString("Transparent_", // Unique key of your choice
            value:"Transparent", // Default (English) text
            comment:"Transparent")
        
    } // initDisplay
    
    @IBAction func TransparentButtonPressed(sender: NSButton) {
        if (transparentButton.state == 1) {
            redBackgroundSlider.enabled = false
            greenBackgroundSlider.enabled = false
            blueBackgroundSlider.enabled = false
            redBackgroundSlider.doubleValue = 255
            greenBackgroundSlider.doubleValue = 255
            blueBackgroundSlider.doubleValue = 255
        } else {
            redBackgroundSlider.enabled = true
            greenBackgroundSlider.enabled = true
            blueBackgroundSlider.enabled = true
        }
        
        ChangeText()
    }
    
    @IBAction func ResetButtonPressed(sender: NSButton) {
        ResetButton()
    } // ResetButtonPressed
    
    @IBAction func SetFontName(sender: NSPopUpButton) {
        ChangeText()
    }
    @IBAction func SetFontSize(sender: NSPopUpButton) {
        ChangeText()
    }
    
    @IBAction func RedTextSliderAction(sender: NSSlider) {
        ChangeText()
    }
    @IBAction func GreenTextSliderAction(sender: NSSlider) {
        ChangeText()
    }
    @IBAction func BlueTextSliderAction(sender: NSSlider) {
        ChangeText()
    }
    
    @IBAction func RedBackgroundSliderAction(sender: NSSlider) {
        ChangeText()
    }
    @IBAction func GreenBackgroundSliderAction(sender: NSSlider) {
        ChangeText()
    }
    @IBAction func BlueBackgroundSliderAction(sender: NSSlider) {
        ChangeText()
    }
    
    //method called, when "Close" - Button clicked
    @IBAction func btnClicked(sender: AnyObject) {
        saveDefaults()
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.updateWeather()
        self.window!.orderOut(mainW)
    }
    
} // class ColorPickerWindow
