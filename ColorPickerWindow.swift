//
//  ColorPickerWindow.swift
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
//  https://www.youtube.com/watch?v=npFZ3YvSGNo
//

import Cocoa

class ColorPickerWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var closeButton: NSButton!
    
    @IBOutlet weak var systemFontButton: NSButton!
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
        
        initPrefs()
        initDisplay()
        
    } // windowDidLoad
    
    //method called to display the modal window
    func beginSheet(_ mainWindow: NSWindow){
        //self.mainW = mainWindow
        //NSApp.beginSheet(self.window!, modalForWindow: mainWindow, modalDelegate: self, didEndSelector:nil, contextInfo: nil)
        
    }
    
    func setFont(_ font: String)
    {
        whichFont = font
    } // setFont
    
    func windowWillClose(_ notification: Notification) {
        saveDefaults()
    } // windowWillClose
    
    func saveDefaults() {
        
        let defaults = UserDefaults.standard
        
        let selectedFont = fontName.selectedItem
        if (selectedFont != nil)
        {
            defaults.setValue(fontName.selectedItem!.title, forKey: whichFont)
        }
        defaults.setValue(fontSize.selectedItem!.title, forKey: whichFont+"size")
        defaults.setValue(systemFontButton.state, forKey: whichFont+"Default")
        
        defaults.setValue(String(format: "%.0f", redTextSlider.doubleValue), forKey: whichFont+"RedText")
        defaults.setValue(String(format: "%.0f", greenTextSlider.doubleValue), forKey: whichFont+"GreenText")
        defaults.setValue(String(format: "%.0f", blueTextSlider.doubleValue), forKey: whichFont+"BlueText")
        
        defaults.setValue(String(format: "%.0f", redBackgroundSlider.doubleValue), forKey: whichFont+"RedBackground")
        defaults.setValue(String(format: "%.0f", greenBackgroundSlider.doubleValue), forKey: whichFont+"GreenBackground")
        defaults.setValue(String(format: "%.0f", blueBackgroundSlider.doubleValue), forKey: whichFont+"BlueBackground")
        
        defaults.setValue(transparentButton.state, forKey: whichFont+"Transparency")
        
    } // saveDefaults
    
    func ResetButton() {
        
        systemFontButton.state = NSControl.StateValue(rawValue: 1)
        
        fontName.selectItem(withTitle: "Tahoma")
        fontSize.selectItem(withTitle: "15")
        
        redTextSlider.doubleValue = 0
        greenTextSlider.doubleValue = 0
        blueTextSlider.doubleValue = 0
        
        redBackgroundSlider.doubleValue = 255
        greenBackgroundSlider.doubleValue = 255
        blueBackgroundSlider.doubleValue = 255
        
        redBackgroundSlider.isEnabled = false
        greenBackgroundSlider.isEnabled = false
        blueBackgroundSlider.isEnabled = false
        
        transparentButton.state = NSControl.StateValue(rawValue: 1)
        
        systemFontAction()
        
    } // ResetButton
    
    func ChangeText() {
        var m = (15 as NSNumber)
        m = NumberFormatter().number(from: fontSize.selectedItem!.title)!

        if (systemFontButton.state.rawValue == 1) {
            let font = NSFont.systemFont(ofSize: CGFloat(truncating: m))
            meteorologistLabel.font = font

            meteorologistLabel.textColor = NSColor(red: 0, green: 0, blue: 0, alpha: 1.0)
            meteorologistLabel.drawsBackground = false
            
        } else {
            // Incase the selected font is no longer available...
            let selectedFont = fontName.selectedItem
            if (selectedFont != nil)
            {
                let font = NSFont(name: fontName.selectedItem!.title, size: CGFloat(truncating: m))
                meteorologistLabel.font = font
            }
            
            meteorologistLabel.textColor = NSColor(red: CGFloat(redTextSlider.floatValue)/255,
                green: CGFloat(greenTextSlider.floatValue)/255,
                blue: CGFloat(blueTextSlider.floatValue)/255, alpha: 1.0)
            
            if (transparentButton.state.rawValue == 1) {
                meteorologistLabel.drawsBackground = false
            } else {
                meteorologistLabel.drawsBackground = true
                meteorologistLabel.backgroundColor = NSColor(red: CGFloat(redBackgroundSlider.floatValue)/255,
                    green: CGFloat(greenBackgroundSlider.floatValue)/255,
                    blue: CGFloat(blueBackgroundSlider.floatValue)/255, alpha: 1.0)
            }
        }
    } // ChangeText
    
    func initPrefs() {
        let defaults = UserDefaults.standard
        
        if (defaults.string(forKey: whichFont+"Default") == nil) {
            if ((defaults.string(forKey: whichFont) == nil) &&
                (defaults.string(forKey: whichFont+"size") == nil)) {
                    defaults.setValue("1", forKey: whichFont+"Default")
            } else {
                defaults.setValue("0", forKey: whichFont+"Default")
            }
        }
        if (defaults.string(forKey: whichFont) == nil) {
            defaults.setValue("Tahoma", forKey: whichFont)
        }
        if (defaults.string(forKey: whichFont+"size") == nil) {
            defaults.setValue("15", forKey: whichFont+"size")
        }
        
        if (defaults.string(forKey: whichFont+"RedText") == nil) {
            defaults.setValue("0", forKey: whichFont+"RedText")
        }
        if (defaults.string(forKey: whichFont+"GreenText") == nil) {
            defaults.setValue("0", forKey: whichFont+"GreenText")
        }
        if (defaults.string(forKey: whichFont+"BlueText") == nil) {
            defaults.setValue("0", forKey: whichFont+"BlueText")
        }
        
        if (defaults.string(forKey: whichFont+"RedBackground") == nil) {
            defaults.setValue("255", forKey: whichFont+"RedBackground")
        }
        if (defaults.string(forKey: whichFont+"GreenBackground") == nil) {
            defaults.setValue("255", forKey: whichFont+"GreenBackground")
        }
        if (defaults.string(forKey: whichFont+"BlueBackground") == nil) {
            defaults.setValue("255", forKey: whichFont+"BlueBackground")
        }
        
        if (defaults.string(forKey: whichFont+"Transparency") == nil) {
            defaults.setValue("1", forKey: whichFont+"Transparency")
        }
        
    } // initPrefs
    
    func initDisplay() {
        let defaults = UserDefaults.standard
        
        systemFontButton.title = localizedString(forKey: "SystemFont_")
        textLabel.stringValue = localizedString(forKey: "Text_")
        backgroundLabel.stringValue = localizedString(forKey: "Background_")
        meteorologistLabel.stringValue = localizedString(forKey: "Meteorologist_")
        
        redTextLabel.stringValue = localizedString(forKey: "Red_")
        redBackgroundLabel.stringValue = localizedString(forKey: "Red_")
        greenTextLabel.stringValue = localizedString(forKey: "Green_")
        greenBackgroundLabel.stringValue = localizedString(forKey: "Green_")
        blueTextLabel.stringValue = localizedString(forKey: "Blue_")
        blueBackgroundLabel.stringValue = localizedString(forKey: "Blue_")
        
        resetButton.title = localizedString(forKey: "Reset_")
        
        closeButton.title = localizedString(forKey: "Close_")
        
        transparentButton.title = localizedString(forKey: "Transparent_")
        
        fontName.addItems(withTitles: NSFontManager.shared.availableFontFamilies)
        
        systemFontButton.state = NSControl.StateValue(rawValue: Int(defaults.string(forKey: whichFont+"Default")!)!)
        
        if (systemFontButton.state.rawValue == 1) {
            fontName.isEnabled = false
        } else {
            fontName.isEnabled = true
        }
        
        fontName.selectItem(withTitle: defaults.string(forKey: whichFont)!)
        fontSize.selectItem(withTitle: defaults.string(forKey: whichFont+"size")!)
        
        redTextSlider.doubleValue = Double(defaults.string(forKey: whichFont+"RedText")!)!
        greenTextSlider.doubleValue = Double(defaults.string(forKey: whichFont+"GreenText")!)!
        blueTextSlider.doubleValue = Double(defaults.string(forKey: whichFont+"BlueText")!)!
        
        redBackgroundSlider.doubleValue = Double(defaults.string(forKey: whichFont+"RedBackground")!)!
        greenBackgroundSlider.doubleValue = Double(defaults.string(forKey: whichFont+"GreenBackground")!)!
        blueBackgroundSlider.doubleValue = Double(defaults.string(forKey: whichFont+"BlueBackground")!)!
        
        transparentButton.state = NSControl.StateValue(rawValue: Int(defaults.string(forKey: whichFont+"Transparency")!)!)
        
        if (transparentButton.state.rawValue == 1) {
            redBackgroundSlider.isEnabled = false
            greenBackgroundSlider.isEnabled = false
            blueBackgroundSlider.isEnabled = false
        } else {
            redBackgroundSlider.isEnabled = true
            greenBackgroundSlider.isEnabled = true
            blueBackgroundSlider.isEnabled = true
        }

        systemFontAction()
        
    } // initDisplay
    
    func systemFontAction() {
        if (systemFontButton.state.rawValue == 1) {
            fontName.isEnabled = false
            
            redBackgroundSlider.isEnabled = false
            greenBackgroundSlider.isEnabled = false
            blueBackgroundSlider.isEnabled = false
            
            redTextSlider.isEnabled = false
            greenTextSlider.isEnabled = false
            blueTextSlider.isEnabled = false
            
            transparentButton.isEnabled = false
        } else {
            fontName.isEnabled = true
            
            if (transparentButton.state.rawValue == 0) {
                redBackgroundSlider.isEnabled = true
                greenBackgroundSlider.isEnabled = true
                blueBackgroundSlider.isEnabled = true
            }
            
            redTextSlider.isEnabled = true
            greenTextSlider.isEnabled = true
            blueTextSlider.isEnabled = true
            
            transparentButton.isEnabled = true
        }
        
        ChangeText()
    }
    
    @IBAction func SystemFontButtonPressed(_ sender: NSButton) {
        systemFontAction()
    }
    
    @IBAction func TransparentButtonPressed(_ sender: NSButton) {
        if (transparentButton.state.rawValue == 1) {
            redBackgroundSlider.isEnabled = false
            greenBackgroundSlider.isEnabled = false
            blueBackgroundSlider.isEnabled = false
            redBackgroundSlider.doubleValue = 255
            greenBackgroundSlider.doubleValue = 255
            blueBackgroundSlider.doubleValue = 255
        } else {
            redBackgroundSlider.isEnabled = true
            greenBackgroundSlider.isEnabled = true
            blueBackgroundSlider.isEnabled = true
        }
        
        ChangeText()
    }
    
    @IBAction func ResetButtonPressed(_ sender: NSButton) {
        ResetButton()
    } // ResetButtonPressed
    
    @IBAction func SetFontName(_ sender: NSPopUpButton) {
        ChangeText()
    }
    @IBAction func SetFontSize(_ sender: NSPopUpButton) {
        ChangeText()
    }
    
    @IBAction func RedTextSliderAction(_ sender: NSSlider) {
        ChangeText()
    }
    @IBAction func GreenTextSliderAction(_ sender: NSSlider) {
        ChangeText()
    }
    @IBAction func BlueTextSliderAction(_ sender: NSSlider) {
        ChangeText()
    }
    
    @IBAction func RedBackgroundSliderAction(_ sender: NSSlider) {
        ChangeText()
    }
    @IBAction func GreenBackgroundSliderAction(_ sender: NSSlider) {
        ChangeText()
    }
    @IBAction func BlueBackgroundSliderAction(_ sender: NSSlider) {
        ChangeText()
    }
    
    //method called, when "Close" - Button clicked
    @IBAction func btnClicked(_ sender: AnyObject) {
        saveDefaults()
//        let appDelegate = NSApplication.shared().delegate as! AppDelegate
//        appDelegate.updateWeather()
        self.window!.orderOut(mainW)
    }
    
} // class ColorPickerWindow
