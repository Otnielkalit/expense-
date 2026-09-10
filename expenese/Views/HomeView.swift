//
//  HomeView.swift
//  expenese
//
//  Created by otnielkalit on 02/09/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    
    var body: some View {
        ZStack(alignment: .top) {
            Theme.bgTop
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                topHeaderSection
                
                bottomContentSection
            }
        }
    }
}

extension HomeView {

    private var topHeaderSection: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                
                Spacer()
                HStack {
                    Text("06 November 2026")
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.3))
                .clipShape(Capsule())
                
                Spacer()
                
                Image(systemName: "gearshape.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
            VStack(spacing: 4) {
                Text("Total Expense")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("-Rp 100.000")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your Balance Rp 120.000")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, 40)
        }
    }
    
    private var bottomContentSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
            
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Money")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 16) {
                        moneyCard(title: "Income", amount: "Rp 300.000", icon: "dollarsign.circle")
                        moneyCard(title: "Expenses", amount: "Rp 100.000", icon: "wallet.pass")
                    }
                }
            
                VStack(alignment: .leading, spacing: 16) {
                    Text("Last Transaction")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Sunday, 06 Nov 2026")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Total Rp 200.000")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                
                    VStack(spacing: 12) {
                        if expenses.isEmpty {
                            transactionRow(name: "Joyi Coffe", amount: "-Rp 57.000")
                            transactionRow(name: "Joyi Coffe", amount: "-Rp 57.000")
                            transactionRow(name: "Joyi Coffe", amount: "-Rp 57.000")
                        } else {
                            ForEach(expenses.prefix(5)) { expense in
                                transactionRow(name: expense.category, amount: "-Rp \(Int(expense.amount))")
                            }
                        }
                    }
                }
                Spacer().frame(height: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 30)
        }
        .background(Theme.bgBottom)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func moneyCard(title: String, amount: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(amount)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBg)
        .cornerRadius(20)
    }
    private func transactionRow(name: String, amount: String) -> some View {
        HStack {
            Image(systemName: "cup.and.saucer.fill")
                .frame(width: 40, height: 40)
                .background(Color.white)
                .cornerRadius(10)
                .foregroundColor(.black)
            
            Text(name)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Text(amount)
                .font(.system(size: 16, weight: .bold))
        }
        .padding(12)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(16)
    }
}

