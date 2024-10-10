//
//  XYPlot.swift
//  MenoWallet
//
//  Created by Jose A Mena on 10/4/24.
//

import Foundation
import SwiftUI
import Charts

struct AssetPriceDataHistoryPoint: Identifiable {
    
    let date: Date
    let price: Decimal
    
    static func mockData() -> [AssetPriceDataHistoryPoint] {
        
        return [
            .init(date: Date(timeIntervalSince1970: 1728009900000), price: 61001),
            .init(date: Date(timeIntervalSince1970: 1728010800000), price: 62002),
            .init(date: Date(timeIntervalSince1970: 1728011700000), price: 63003),
            .init(date: Date(timeIntervalSince1970: 1728012600000), price: 61004),
            .init(date: Date(timeIntervalSince1970: 1728013500000), price: 62005),
        ]
    }
    
    var id: String {
        date.ISO8601Format()
    }
}

struct XYPlot: View {

    let dataPoints: [AssetPriceDataHistoryPoint]
    
    private var minMaxY: (Decimal, Decimal) {
        var min = Decimal.greatestFiniteMagnitude
        var max = Decimal.zero
        
        for dataPoint in dataPoints {
            min = dataPoint.price < min ? dataPoint.price : min
            max = dataPoint.price > max ? dataPoint.price : max
        }
        return ((min * 0.99), (max * 1.01))
    }
    
    var body: some View {
        Chart(dataPoints) {
            LineMark(
                x: .value("Date", $0.date),
                y: .value("Amount", $0.price)
            )
//            .symbol(.circle)
            .interpolationMethod(.catmullRom)
            
            AreaMark(
                x: .value("Date", $0.date),
                yStart: .value("Amount", minMaxY.0),
                yEnd: .value("Amound End", $0.price)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(areaBackground)
        }
//        .chartXAxis {
//            AxisMarks(values: .stride(by: .month, count: 1)) { _ in
//                AxisValueLabel(format: .dateTime.day(), centered: true)
//            }
//            AxisMarks()
//        }
        .chartYScale(domain: [minMaxY.0, minMaxY.1])
    }
    
    private var areaBackground: LinearGradient {
        LinearGradient(
            colors: [Color.Theme.primary, Color.Theme.darkTeal.opacity(0.2)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    XYPlot(
        dataPoints: AssetPriceDataHistoryPoint.mockData()
    )
    .frame(height: 300)
}


