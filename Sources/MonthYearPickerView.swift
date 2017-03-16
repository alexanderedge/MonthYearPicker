//
//  MonthYearPickerView.swift
//  MonthYearPicker
//
//  Copyright (c) 2016 Alexander Edge <alex@alexedge.co.uk>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

open class MonthYearPickerView: UIPickerView {
    
    open var date: Date = Date() {
        didSet {
            
            var dateComponents = (calendar as NSCalendar).components([.year, .month], from: date)
            dateComponents.hour = 12
            
            guard let date = calendar.date(from: dateComponents) else {
                return
            }
            
            setDate(date, animated: true)
            dateSelectionHandler?(date)
        }
    }
    
    open var calendar: Calendar = Calendar.current {
        didSet {
            monthDateFormatter.calendar = calendar
            yearDateFormatter.calendar = calendar
        }
    }
    
    open var locale: Locale? {
        didSet {
            calendar.locale = locale
            monthDateFormatter.locale = locale
            yearDateFormatter.locale = locale
        }
    }
    
    open var dateSelectionHandler: ((Date) -> Void)?
    
    lazy fileprivate var monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    lazy fileprivate var yearDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y"
        return formatter
    }()
    
    fileprivate enum Component: Int {
        case month
        case year
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        dataSource = self
        delegate = self
        setDate(date, animated: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
        setDate(date, animated: false)
    }
    
    open func setDate(_ date: Date, animated: Bool) {
        let month = (calendar as NSCalendar).component(.month, from: date) - (calendar as NSCalendar).maximumRange(of: .month).location
        selectRow(month, inComponent: Component.month.rawValue, animated: animated)
        let year = (calendar as NSCalendar).component(.year, from: date) - (calendar as NSCalendar).maximumRange(of: .year).location
        selectRow(year, inComponent: Component.year.rawValue, animated: animated)
    }
    
}

extension MonthYearPickerView: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var dateComponents = DateComponents()
        dateComponents.year = (calendar as NSCalendar).maximumRange(of: .year).location + pickerView.selectedRow(inComponent: Component.year.rawValue)
        dateComponents.month = (calendar as NSCalendar).maximumRange(of: .month).location + pickerView.selectedRow(inComponent: Component.month.rawValue)
        dateComponents.hour = 12
        guard let date = calendar.date(from: dateComponents) else {
            return
        }
        self.date = date
    }
    
}

extension MonthYearPickerView: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        guard let component = Component(rawValue: component) else { return 0 }
        switch component {
        case .month:
            return (calendar as NSCalendar).maximumRange(of: .month).length
        case .year:
            return (calendar as NSCalendar).maximumRange(of: .year).length
        }
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let component = Component(rawValue: component) else { return nil }
        
        switch component {
        case .month:
            let month = (calendar as NSCalendar).maximumRange(of: .month).location + row
            var dateComponents = DateComponents()
            dateComponents.month = month
            dateComponents.hour = 12
            guard let date = calendar.date(from: dateComponents) else {
                return nil
            }
            return monthDateFormatter.string(from: date)
        case .year:
            let year = (calendar as NSCalendar).maximumRange(of: .year).location + row
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.hour = 12
            guard let date = calendar.date(from: dateComponents) else {
                return nil
            }
            return yearDateFormatter.string(from: date)
        }
        
    }
    
}
