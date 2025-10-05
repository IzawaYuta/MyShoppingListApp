//
//  RegularView.swift
//  MyShoppingListApp
//
//  Created by Engineer MacBook Air on 2025/03/31.
//

import RealmSwift
import SwiftUI
import FirebaseAnalytics

class RegularItem: Object, Identifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID() // プライマリキーを明示
    @Persisted var name: String = ""
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: RegularCategoryListView
struct RegularCategoryListView: View {
    
    @ObservedResults(CategoryListModel.self, sortDescriptor: SortDescriptor(keyPath: "sortIndex", ascending: true))
    var categoryListModel
    @State private var showFavoritesOnly = false
    @State private var selectedItems = Set<String>()
//    @Environment(\.editMode) private var editMode
    @State private var editMode: EditMode = .inactive

    var filteredCategories: [CategoryListModel] {
        if showFavoritesOnly {
            return categoryListModel.filter { $0.favorite }
        } else {
            return Array(categoryListModel)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // categoryListModelが空の場合
                if categoryListModel.isEmpty {
                    Text("カテゴリーを追加しましょう")
                        .foregroundColor(.gray)
                } else if showFavoritesOnly && filteredCategories.isEmpty {
                    // 「お気に入りだけ表示」のときに空だった場合
                    Text("カテゴリー画面でお気に入り登録をしてください")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // categoryListModelにデータがある場合
                    List(filteredCategories, id: \.id, selection: $selectedItems) { category in
                        if editMode == .active {
                            Text(category.name)
                        } else {
                            NavigationLink(destination: RegularListView(categoryListModel: category)) {
                                HStack {
                                    Text(category.name)
                                    Spacer()
                                    if category.favorite {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                        }
                    }
                    .environment(\.editMode, $editMode)
                    .scrollContentBackground(.hidden)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.brown.opacity(0.7), .clear, .brown.opacity(0.6)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .ignoresSafeArea()
                    )
                }
            }
            .navigationTitle("定期品")
            .toolbarTitleDisplayMode(.automatic)
            .toolbar(.visible, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if editMode == .active {
                            // 🔸 編集モード終了時の任意処理
                            handleFinishEditing()
                            editMode = .inactive
                        } else {
                            // 🔸 編集モード開始時の任意処理
                            editMode = .active
                        }
                    }) {
                        Text(editMode == .active ? "完了" : "編集")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showFavoritesOnly.toggle()
                    }) {
//                        ZStack {
//                            Circle()
//                                .fill(Color.gray)
//                                .frame(width: 33, height: 33)
                            Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                                .foregroundColor(.yellow)
//                        }
                    }
                }
            }
        }
    }
    
    private func toggleSelection(for item: RegularItem) {
        if selectedItems.contains(item.id.uuidString) {
            selectedItems.remove(item.id.uuidString)
        } else {
            selectedItems.insert(item.id.uuidString)
        }
    }
    
    private func handleFinishEditing() {
        let realm = try! Realm()
        
        try! realm.write {
            for frozenCategory in categoryListModel {
                // thaw() で「解凍」したオブジェクトを取得
                if let category = frozenCategory.thaw() {
                    category.isDisplay = selectedItems.contains(category.id)
                }
            }
        }
        
//        selectedItems.removeAll()
    }
}

// MARK: RegularListView
struct RegularListView: View {
    @ObservedRealmObject var categoryListModel: CategoryListModel
    @State private var isAddingItem = false
    @State private var newRegularItemName = ""
    @State private var selectedItems = Set<String>()
    @State private var selectedAllItems = false
    @State private var isDone = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        
        let regularItemsArray = Array(categoryListModel.regularItems)
        
        ZStack(alignment: .bottom) {
            List {
                VStack {
                    HStack {
                        TextField("アイテム", text: $newRegularItemName)
//                            .padding()
//                            .foregroundColor(Color.black)
                        Button(action: {
                            addItem()
                        }) {
                            if colorScheme == .dark {
                                Text("追加")
                                    .padding()
                                    .foregroundColor(newRegularItemName.isEmpty ? Color.white : Color.black.opacity(0.5))
                                    .cornerRadius(8)
                            } else {
                                Text("追加")
                                    .padding()
                                    .foregroundColor(newRegularItemName.isEmpty ? Color.gray : Color.black)
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(newRegularItemName.isEmpty)
                    }
                    .padding(.horizontal)
                    .background(.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .cornerRadius(8)
                    Spacer()
                    ForEach(regularItemsArray, id: \.id) { list in
                        HStack {
                            Image(systemName: selectedItems.contains(list.id.uuidString) ? "circle.inset.filled" : "circle")
                                .scaleEffect(selectedItems.contains(list.id.uuidString) ? 1.3 : 0.8)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.2), value: selectedItems)
                            Text(list.name)
                                .font(.system(size: selectedItems.contains(list.id.uuidString) ? 20 : 17))
                            Spacer()
                        }
                        .onTapGesture {
                            toggleSelection(for: list)
                        }
                    }
                    .onDelete(perform: deleteItem)
                    .frame(height: 40)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(
                Color.gray.opacity(0.3)
                    .ignoresSafeArea()
            )
//            HStack {
//                TextField("入力してください", text: $newRegularItemName)
//                    .padding()
//                    .foregroundColor(Color.black)
//                Button(action: {
//                    addItem()
//                }) {
//                    if colorScheme == .dark {
//                        Text("追加")
//                            .padding()
//                            .foregroundColor(newRegularItemName.isEmpty ? Color.white : Color.pink.opacity(0.5))
//                            .cornerRadius(8)
//                    } else {
//                        Text("追加")
//                            .padding()
//                            .foregroundColor(newRegularItemName.isEmpty ? Color.gray : Color.pink)
//                            .cornerRadius(8)
//                    }
//                }
//                .disabled(newRegularItemName.isEmpty)
//            }
//            .background(colorScheme == .dark ? Color.gray : Color.white)
//            .cornerRadius(10)
//            .frame(height: 165)
//            .shadow(radius: 3)
//            .padding()
        }
//        .listStyle(PlainListStyle())
        .onAppear {
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: "RegularListView",
                AnalyticsParameterScreenClass: "RegularListView"
            ])
        }
//        .navigationBarBackButtonHidden(true) // デフォルトの戻るボタンを非表示
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
//                    if selectedItems == [] {
//                    } else {
                        Button(action: {
                            saveSelectedItems()
                            isDone = true
                            selectedItems = []
                        }) {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.black)
                        }
                        .disabled(selectedItems.isEmpty)
                        .sheet(isPresented: $isDone) {
                            SuccessAlertView()
                                .presentationDetents([.fraction(0.3)])
                                .presentationBackground(.clear)
                                .transition(.move(edge: .bottom))
                        }
                        .onChange(of: isDone) { newValue in
                            if newValue {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation {
                                        isDone = false
                                    }
                                }
                            }
                        }
//                    }
                    Button(action: {
                        selectedAllItems.toggle()
                        selectAllItems()
                    }) {
                        Text(selectedItems.count == (categoryListModel.regularItems.count) ? "解除" : "全て")
                            .foregroundColor(.black)
                    }
                } // HStack
            } // topBarTrailing
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "chevron.left")
//                }
//            }
        }
        .navigationTitle("\(categoryListModel.name) の定期品")
    }
    
    // 定期品追加メソッド
    private func addItem() {
        guard !newRegularItemName.isEmpty else { return }
        let newItem = RegularItem(name: newRegularItemName) // データを渡して初期化
        let realm = try! Realm()
        try! realm.write {
            $categoryListModel.regularItems.append(newItem) // トランザクション内で追加
        }
        newRegularItemName = ""
        print("追加後のRegularItem: \(RegularItem())") // 正しいアイテムを表示
        print("追加後のcategory: \($categoryListModel.regularItems)") // 正しいリストを表示
    }
    
    // 定期品削除メソッド
    private func deleteItem(at offsets: IndexSet) {
        let realm = try! Realm()
        try! realm.write {
            $categoryListModel.regularItems.remove(atOffsets: offsets) // 同様に自動トランザクション
        }
        print("削除後のRegularItem♥️♥️\(RegularItem())")
        print("削除後のcategory♥️\($categoryListModel.regularItems)")
    }
    
    // チェック切り替え
    private func toggleSelection(for item: RegularItem) {
        if selectedItems.contains(item.id.uuidString) {
            selectedItems.remove(item.id.uuidString)
        } else {
            selectedItems.insert(item.id.uuidString)
        }
    }
    
    // リストの全選択
    private func selectAllItems() {
        //        guard let regularItems = categoryListModel else { return }
        let regularItems = categoryListModel
        if selectedItems.count == regularItems.regularItems.count {
            // 全選択されている場合、選択解除
            selectedItems.removeAll()
        } else {
            // 全選択されていない場合、全て選択
            selectedItems = Set(regularItems.regularItems.map { $0.id.uuidString })
        }
    }
    
    private func saveSelectedItems() {
        let realm = try! Realm()
        try! realm.write {
            let selectedRegularItems = categoryListModel.regularItems.filter { selectedItems.contains($0.id.uuidString) }
            
            for regularItem in selectedRegularItems {
                let item = Item()
                item.name = regularItem.name
                
                $categoryListModel.items.append(item) // Listに追加 (realm.writeブロック内で行う)
                realm.add(item) // Realmに明示的に保存
            }
        }
    }
    
    private func buttonAnalytics() {
        Analytics.logEvent("button_tapped", parameters: [
            "regular_arrow.up": "regular_arrow.up"
        ])
    }
}

#Preview {
    RegularCategoryListView()
}
