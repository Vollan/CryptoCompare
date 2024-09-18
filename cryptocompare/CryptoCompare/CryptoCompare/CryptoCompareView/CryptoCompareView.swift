//
//  CryptoCompareView.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import SwiftUI
import Charts
import GridPoint

struct CryptoComparisonView: View {
    
    @ObservedObject var viewAdapter: CryptoComparisonViewAdapter
    
    var body: some View {
        VStack(spacing: GridPoint.x3) {
            Text(viewAdapter.cryptoDataViewModel?.title ?? "")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, GridPoint.x3)
            if let information = viewAdapter.cryptoDataViewModel?.information {
                chartView(information: information)
                listView(information: information)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    func chartView(information: [CryptoCurrencyModel.Information]) -> some View {
        Chart(information) { currency in
            BarMark(
                x: .value("name", currency.name),
                y: .value("change", currency.priceChangePercentage24h)
            )
            .foregroundStyle(currency.priceChangePercentage24h >= 0 ? Color.green : Color.red)
            .cornerRadius(5)
        }
        .frame(height: 300)
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func listView(information: [CryptoCurrencyModel.Information]) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: GridPoint.x1) {
                ForEach(information) { currency in
                    HStack {
                        Text(currency.name)
                            .font(.headline)
                        Spacer()
                        Text(currency.formattedChange)
                            .foregroundColor(currency.priceChangePercentage24h >= 0 ? .green : .red)
                            .font(.subheadline)
                            .bold()
                    }
                    Divider()
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(GridPoint.x1)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
