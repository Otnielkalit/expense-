//
//  AddCategoryView.swift
//  expenese
//
//  Created by otnielkalit on 12/09/26.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var categoryName: String = ""
    @State private var selectedIcon: String = "cart.fill"
    @State private var selectedColor: Color = .blue
    
    let icons = ["cart.fill", "fork.knife", "car.fill", "house.fill", "bag.fill", "cup.and.saucer.fill", "cross.case.fill", "airplane", "gamecontroller.fill", "gift.fill"]
    let colors: [Color] = [.blue, .red, .green, .orange, .purple, .yellow, .pink, .cyan]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.bgApp.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    
                    // Preview
                    VStack(spacing: 16) {
                        Image(systemName: selectedIcon)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(selectedColor)
                            .clipShape(Circle())
                            .shadow(color: selectedColor.opacity(0.3), radius: 10, y: 5)
                        
                        Text(categoryName.isEmpty ? "Category Name" : categoryName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Theme.textDark)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Name Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.textDark)
                            
                            TextField("Enter category name", text: $categoryName)
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        // Icons
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Icon")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.textDark)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(icons, id: \.self) { icon in
                                        Button(action: { selectedIcon = icon }) {
                                            Image(systemName: icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(selectedIcon == icon ? .white : .gray)
                                                .frame(width: 50, height: 50)
                                                .background(selectedIcon == icon ? selectedColor : Color.white)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        
                        // Colors
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.textDark)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(colors, id: \.self) { color in
                                        Button(action: { selectedColor = color }) {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Circle().stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                                )
                                                .shadow(color: color.opacity(0.3), radius: 5, y: 2)
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(24)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    Button(action: {
                        // Action to save category
                        dismiss()
                    }) {
                        Text("Save Category")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(categoryName.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(16)
                    }
                    .disabled(categoryName.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
