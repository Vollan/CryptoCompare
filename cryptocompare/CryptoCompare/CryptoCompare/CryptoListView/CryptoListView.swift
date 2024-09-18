
//
//  ContentView.swift
//  CryptoCompare
//
//  Created by Emil Sandstrom on 2024-09-17.
//

import SwiftUI
import SwiftData
import GridPoint

struct CryptoListView: View {
    
    @ObservedObject var viewAdapter: CryptoListViewAdapter

    var body: some View {
        ZStack {
            contentView
            if viewAdapter.isMultipleSelectionVisible {
                compareButtonView
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("crypto_currencies".localized())
    }
    
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: GridPoint.x1) {
                ForEach($viewAdapter.viewModels) { $viewModel in
                    cryptoItemView(viewModel: $viewModel)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(GridPoint.x1)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, GridPoint.x2)
                }
            }
            .padding(.bottom, GridPoint.x6)
            .padding(.top, GridPoint.x2)
        }
    }
    
    private func cryptoItemView(viewModel: Binding<CurrencyViewModel>) -> some View {
        VStack(spacing: GridPoint.x2) {
            HStack(spacing: GridPoint.x1) {
                cryptoImageView(urlString: viewModel.wrappedValue.image)
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.wrappedValue.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("\("price_label".localized()) \(viewModel.wrappedValue.currency)\(viewModel.wrappedValue.value)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.leading, GridPoint.x1)
                Spacer()
                Image(systemName: viewModel.wrappedValue.positiveRise ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                    .foregroundColor(viewModel.wrappedValue.positiveRise ? .green : .red)
                    .imageScale(.large)
                checkBoxView(value: viewModel)
            }
            .contentShape(Rectangle())
            .padding(.all, GridPoint.x2)
            .onTapGesture {
                viewAdapter.showDetail(for: viewModel.id)
            }
        }
    }
    
    private func cryptoImageView(urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: GridPoint.x5, height: GridPoint.x5)
                .clipShape(Circle())
                .shadow(radius: 4)
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: GridPoint.x5, height: GridPoint.x5)
                .overlay(ProgressView())
        }
    }
    
    private var compareButtonView: some View {
        VStack {
            Spacer()
            Button(action: {
                viewAdapter.compareSelections()
            }) {
                Text("compare_button".localized())
                    .font(.headline)
                    .frame(height: GridPoint.x6)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal, GridPoint.x2)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    private func checkBoxView(value: Binding<CurrencyViewModel>) -> some View {
        Button(action: {
            value.isChecked.wrappedValue.toggle()
        }) {
            Image(systemName: value.isChecked.wrappedValue ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: GridPoint.x3, height: GridPoint.x3)
                .foregroundColor(value.isChecked.wrappedValue ? .green : .blue)
        }
        .padding(.trailing, GridPoint.x1)
    }
}
