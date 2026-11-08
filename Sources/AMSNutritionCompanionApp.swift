import SwiftUI
import PhotosUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

private struct PackagePhoto: View {
    let data: Data
    var body: some View {
        #if os(macOS)
        if let image = NSImage(data: data) { Image(nsImage: image).resizable().scaledToFit() }
        #else
        if let image = UIImage(data: data) { Image(uiImage: image).resizable().scaledToFit() }
        #endif
    }
}

private enum PantryStyle {
    static let green = Color(red: 0.25, green: 0.39, blue: 0.29)
    #if os(macOS)
    static let paper = Color(nsColor: .windowBackgroundColor)
    #else
    static let paper = Color(uiColor: .systemGroupedBackground)
    #endif
}

private struct CheckMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

private struct PantryCheck: View {
    let checked: Bool
    var body: some View {
        ZStack {
            Circle().stroke(checked ? PantryStyle.green : Color.secondary, lineWidth: 1.6)
            if checked { CheckMarkShape().stroke(PantryStyle.green, style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round)).padding(5) }
        }.frame(width: 20, height: 20)
    }
}

private struct EmptyStateView: View {
    let title: String
    let detail: String
    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(.title2.weight(.semibold))
            Text(detail).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(16)
    }
}

struct PantryProduct: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var category: String
    var suggestedProduct: String?
    var packageSize: String?
    var ingredientsCriteria: String
    var selectionGuide: String
    var countries: [String]
    var approved: Bool
    var martinApproved: Bool
    var annaApproved: Bool
    var stores: [String]
    var minimumPrice: Double?
    var maximumPrice: Double?
    var priceCurrency: String?
    var listQuantity: String?
    var checked = false
    var imageData: Data?

    enum CodingKeys: String, CodingKey { case id, name, category, suggestedProduct, packageSize, ingredientsCriteria, selectionGuide, countries, approved, martinApproved, annaApproved, stores, minimumPrice, maximumPrice, priceCurrency, listQuantity, checked, imageData }
    init(id: String, name: String, category: String, suggestedProduct: String?, packageSize: String?, ingredientsCriteria: String, selectionGuide: String, countries: [String], approved: Bool, martinApproved: Bool = false, annaApproved: Bool = false, stores: [String], minimumPrice: Double?, maximumPrice: Double?, priceCurrency: String? = nil, listQuantity: String?, checked: Bool = false, imageData: Data? = nil) {
        self.id = id; self.name = name; self.category = category; self.suggestedProduct = suggestedProduct; self.packageSize = packageSize
        self.ingredientsCriteria = ingredientsCriteria; self.selectionGuide = selectionGuide; self.countries = countries; self.approved = approved; self.martinApproved = martinApproved; self.annaApproved = annaApproved
        self.stores = stores; self.minimumPrice = minimumPrice; self.maximumPrice = maximumPrice; self.priceCurrency = priceCurrency; self.listQuantity = listQuantity; self.checked = checked; self.imageData = imageData
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        category = try values.decode(String.self, forKey: .category)
        suggestedProduct = try values.decodeIfPresent(String.self, forKey: .suggestedProduct)
        packageSize = try values.decodeIfPresent(String.self, forKey: .packageSize)
        ingredientsCriteria = try values.decode(String.self, forKey: .ingredientsCriteria)
        selectionGuide = try values.decode(String.self, forKey: .selectionGuide)
        countries = try values.decodeIfPresent([String].self, forKey: .countries) ?? ["SE"]
        approved = try values.decodeIfPresent(Bool.self, forKey: .approved) ?? false
        martinApproved = try values.decodeIfPresent(Bool.self, forKey: .martinApproved) ?? false
        annaApproved = try values.decodeIfPresent(Bool.self, forKey: .annaApproved) ?? false
        stores = try values.decodeIfPresent([String].self, forKey: .stores) ?? []
        minimumPrice = try values.decodeIfPresent(Double.self, forKey: .minimumPrice)
        maximumPrice = try values.decodeIfPresent(Double.self, forKey: .maximumPrice)
        priceCurrency = try values.decodeIfPresent(String.self, forKey: .priceCurrency)
        listQuantity = try values.decodeIfPresent(String.self, forKey: .listQuantity)
        checked = try values.decodeIfPresent(Bool.self, forKey: .checked) ?? false
        imageData = try values.decodeIfPresent(Data.self, forKey: .imageData)
    }
}

@MainActor
final class PantryStore: ObservableObject {
    @Published var products: [PantryProduct] { didSet { save() } }
    @Published var selectedMarket = "Sweden · SEK"
    @Published var selectedStore = "All stores"
    @Published var search = ""

    private let persistenceKey = "ams.pantry.products.v1"
    private let markets = ["Sweden · SEK", "Germany · EUR"]
    private let stores = ["All stores", "ICA", "Coop", "Willys", "Lidl", "Other"]

    init() {
        if let data = UserDefaults.standard.data(forKey: persistenceKey),
           let saved = try? JSONDecoder().decode([PantryProduct].self, from: data) {
            products = saved
        } else if let url = Bundle.main.url(forResource: "SeedProducts", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let catalog = root["products"] as? [[String: Any]],
                  let catalogData = try? JSONSerialization.data(withJSONObject: catalog),
                  let decoded = try? JSONDecoder().decode([PantryProduct].self, from: catalogData) {
            products = decoded
        } else { products = [] }
    }

    var visibleProducts: [PantryProduct] {
        products.filter { product in
            (search.isEmpty || product.name.localizedCaseInsensitiveContains(search) || product.category.localizedCaseInsensitiveContains(search)) &&
            (selectedStore == "All stores" || product.stores.contains(selectedStore)) &&
            (selectedMarket.hasPrefix("Sweden") ? product.countries.contains("SE") : product.countries.contains("DE"))
        }
    }
    var categories: [String] { Array(Set(visibleProducts.map(\.category))).sorted() }
    func product(_ id: String) -> PantryProduct? { products.first { $0.id == id } }
    func update(_ value: PantryProduct) { if let i = products.firstIndex(where: { $0.id == value.id }) { products[i] = value } }
    func add(_ value: PantryProduct) { products.insert(value, at: 0) }
    func toggle(_ value: PantryProduct) { var p = value; p.checked.toggle(); update(p) }
    func setApproval(_ value: PantryProduct, householdMember: String) {
        var p = value
        if householdMember == "Martin" { p.martinApproved = true } else { p.annaApproved = true }
        p.approved = p.martinApproved && p.annaApproved
        update(p)
    }
    private func save() { if let data = try? JSONEncoder().encode(products) { UserDefaults.standard.set(data, forKey: persistenceKey) } }
}

@main
struct AMSNutritionCompanionApp: App {
    @StateObject private var store = PantryStore()
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            PantryRootView().environmentObject(store).frame(minWidth: 760, minHeight: 540)
            #else
            PantryRootView().environmentObject(store)
            #endif
        }
            .commands {
                CommandGroup(replacing: .newItem) { Button("Add Shopping Item…") { NotificationCenter.default.post(name: .addPantryItem, object: nil) }.keyboardShortcut("n", modifiers: .command) }
                CommandGroup(after: .saveItem) { Button("Search Products") { NotificationCenter.default.post(name: .focusPantrySearch, object: nil) }.keyboardShortcut("f", modifiers: .command) }
            }
    }
}

private extension Notification.Name {
    static let addPantryItem = Notification.Name("ams.addPantryItem")
    static let focusPantrySearch = Notification.Name("ams.focusPantrySearch")
}

struct PantryRootView: View {
    @EnvironmentObject private var store: PantryStore
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selection: String?
    @State private var selectedSection = "Shopping"
    @State private var showingAdd = false
    @State private var showingGuide = false
    @FocusState private var searchFocused: Bool

    private var selectedProduct: PantryProduct? { selection.flatMap(store.product) }
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            sidebar.frame(minWidth: 175)
        } content: {
            sectionContent.frame(minWidth: 260)
        } detail: {
            detailPane.frame(minWidth: 350)
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar { toolbarItems }
        .sheet(isPresented: $showingAdd) { ProductEditorSheet(product: nil).environmentObject(store).frame(minWidth: 480, minHeight: 520) }
        .sheet(isPresented: $showingGuide) { LabelGuideView().frame(minWidth: 550, minHeight: 500) }
        .onReceive(NotificationCenter.default.publisher(for: .addPantryItem)) { _ in showingAdd = true }
        .onReceive(NotificationCenter.default.publisher(for: .focusPantrySearch)) { _ in searchFocused = true }
        #else
        if sizeClass == .regular {
            NavigationSplitView {
                sidebar
            } content: {
                sectionContent
            } detail: {
                detailPane
            }
            .toolbar { toolbarItems }
            .sheet(isPresented: $showingAdd) { ProductEditorSheet(product: nil).environmentObject(store) }
            .sheet(isPresented: $showingGuide) { NavigationStack { LabelGuideView().toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingGuide = false } } } } }
            .onReceive(NotificationCenter.default.publisher(for: .addPantryItem)) { _ in showingAdd = true }
            .onReceive(NotificationCenter.default.publisher(for: .focusPantrySearch)) { _ in searchFocused = true }
        } else {
        NavigationStack {
            sectionContent
                .navigationTitle(selectedSection)
                .toolbar { toolbarItems }
                .navigationDestination(for: String.self) { id in ProductDetailView(productID: id) }
        }
        .sheet(isPresented: $showingAdd) { ProductEditorSheet(product: nil).environmentObject(store) }
        .sheet(isPresented: $showingGuide) { NavigationStack { LabelGuideView().toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showingGuide = false } } } } }
        .onReceive(NotificationCenter.default.publisher(for: .addPantryItem)) { _ in showingAdd = true }
        .onReceive(NotificationCenter.default.publisher(for: .focusPantrySearch)) { _ in searchFocused = true }
        }
        #endif
    }

    @ToolbarContentBuilder private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) { Button("Add item") { showingAdd = true }.accessibilityIdentifier("shopping.addItem") }
        #if os(iOS)
        ToolbarItem(placement: .automatic) { Button(selectedSection == "Shopping" ? "Product library" : "Shopping") { selectedSection = selectedSection == "Shopping" ? "Product library" : "Shopping" } }
        #endif
        ToolbarItem(placement: .automatic) {
            Menu {
                Picker("Market", selection: $store.selectedMarket) { ForEach(["Sweden · SEK", "Germany · EUR"], id: \.self) { Text($0) } }
                Picker("Store", selection: $store.selectedStore) { ForEach(retailerOptions, id: \.self) { Text($0) } }
            } label: { Text("Market and store") }.accessibilityIdentifier("shopping.storeFilter")
        }
        ToolbarItem(placement: .automatic) { Button("Label guide") { showingGuide = true } }
    }

    private var sidebar: some View {
        List {
            Button("Shopping") { selectedSection = "Shopping"; selection = nil }.buttonStyle(.plain)
            Button("Product library") { selectedSection = "Product library"; selection = nil }.buttonStyle(.plain)
            Button("Label guide") { showingGuide = true }.buttonStyle(.plain)
            Section("Market") { Text(store.selectedMarket).font(.subheadline).foregroundStyle(.secondary) }
        }
        .listStyle(.sidebar)
        .navigationTitle("Pantry")
        .safeAreaInset(edge: .bottom) { VStack(alignment: .leading, spacing: 2) { Text("Martin + Anna"); Text("Version 0.1.0") }.font(.caption).foregroundStyle(.secondary).padding() }
    }

    private var shoppingList: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search foods", text: $store.search).textFieldStyle(.roundedBorder).focused($searchFocused).accessibilityIdentifier("shopping.search")
                if !isPhone { marketPicker }
            }.padding(.horizontal).padding(.vertical, 10)
            List {
                let listItems = store.visibleProducts.filter { $0.listQuantity != nil }
                if listItems.isEmpty {
                    EmptyStateView(title: "Your list is empty", detail: "Add household-approved foods from the product library.")
                } else {
                    ForEach(store.categories.filter { category in listItems.contains(where: { $0.category == category }) }, id: \.self) { category in
                        Section(category) { ForEach(listItems.filter { $0.category == category }) { product in productRow(product) } }
                    }
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.inset)
            #endif
            .accessibilityIdentifier("shopping.list")
        }
        .navigationTitle("Shopping")
    }

    private var libraryList: some View {
        List {
            ForEach(store.categories, id: \.self) { category in
                Section(category) {
                    ForEach(store.visibleProducts.filter { $0.category == category }) { product in productRow(product) }
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
        .accessibilityIdentifier("library.list")
        .navigationTitle("Product library")
    }
    @ViewBuilder private var sectionContent: some View {
        if selectedSection == "Product library" { libraryList }
        else { shoppingList }
    }

    private var isPhone: Bool {
        #if os(iOS)
        sizeClass == .compact
        #else
        false
        #endif
    }
    private var marketPicker: some View {
        Menu {
            Picker("Market", selection: $store.selectedMarket) { ForEach(["Sweden · SEK", "Germany · EUR"], id: \.self) { Text($0) } }
            Picker("Store", selection: $store.selectedStore) { ForEach(retailerOptions, id: \.self) { Text($0) } }
        } label: { Text(store.selectedStore == "All stores" ? store.selectedMarket : "\(store.selectedStore) · \(store.selectedMarket.components(separatedBy: " · ").last ?? "SEK")") }
            .accessibilityIdentifier("shopping.storeFilter")
    }
    private var retailerOptions: [String] {
        store.selectedMarket.hasPrefix("Sweden") ? ["All stores", "ICA", "Coop", "Willys", "Lidl", "Other"] : ["All stores", "Aldi", "Edeka", "REWE", "Lidl", "Other"]
    }
    @ViewBuilder private func productRow(_ product: PantryProduct) -> some View {
        #if os(macOS)
        HStack(spacing: 10) {
            Button { store.toggle(product) } label: { PantryCheck(checked: product.checked) }.buttonStyle(.plain).accessibilityLabel(product.checked ? "Mark \(product.name) not bought" : "Mark \(product.name) bought")
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name).strikethrough(product.checked).foregroundStyle(product.checked ? .secondary : .primary)
                Text(product.approved ? "Household approved" : "Suggested · review together").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            if product.maximumPrice != nil { Text(priceRange(product)).font(.caption).foregroundStyle(.secondary) }
        }
        .contentShape(Rectangle()).onTapGesture { selection = product.id }
        .tag(product.id)
        #else
            NavigationLink(value: product.id) {
            HStack(spacing: 12) {
                Button { store.toggle(product) } label: { PantryCheck(checked: product.checked) }.buttonStyle(.plain).accessibilityLabel("Toggle \(product.name)")
                VStack(alignment: .leading, spacing: 3) { Text(product.name).strikethrough(product.checked); Text(product.approved ? "Approved" : "Suggested · review together").font(.caption).foregroundStyle(.secondary) }
            }
        }
        .swipeActions(edge: .trailing) { Button(product.listQuantity == nil ? "Add" : "Remove") { var p = product; p.listQuantity = p.listQuantity == nil ? "1" : nil; store.update(p) }.tint(PantryStyle.green) }
        #endif
    }
    private var currency: String { store.selectedMarket.hasPrefix("Sweden") ? "SEK" : "EUR" }
    private func priceRange(_ p: PantryProduct) -> String {
        guard p.priceCurrency == currency else { return "Price stored in \(p.priceCurrency ?? "unspecified currency")" }
        return "\(currency) \(p.minimumPrice.map { String(format: "%.2f", $0) } ?? "—")–\(p.maximumPrice.map { String(format: "%.2f", $0) } ?? "—")"
    }

    @ViewBuilder private var detailPane: some View {
        if let product = selectedProduct { ProductDetailView(productID: product.id) }
        else { EmptyStateView(title: "Choose a food", detail: "See product details, selection tips, and household price limits.") }
    }
}

struct ProductDetailView: View {
    @EnvironmentObject private var store: PantryStore
    @State private var editing = false
    let productID: String
    private var product: PantryProduct? { store.product(productID) }
    var body: some View {
        Group {
            if let p = product {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if let data = p.imageData { PackagePhoto(data: data).clipShape(RoundedRectangle(cornerRadius: 14)) }
                        Text(p.category.uppercased()).font(.caption.weight(.semibold)).foregroundStyle(PantryStyle.green)
                        Text(p.name).font(.largeTitle.bold()).accessibilityIdentifier("product.title")
                        Text(p.approved ? "Approved by Martin + Anna" : "Candidate · review together")
                            .font(.subheadline).foregroundStyle(p.approved ? PantryStyle.green : .secondary)
                        if let exact = p.suggestedProduct { detailSection("Exact product", exact) }
                        detailSection("What to look for", p.selectionGuide)
                        detailSection("Ingredients and processing", p.ingredientsCriteria)
                        detailSection("Store and price", storeSummary(p))
                        HStack {
                            Button("Edit details") { editing = true }.buttonStyle(.bordered)
                            if !p.martinApproved { Button("Martin approves") { store.setApproval(p, householdMember: "Martin") }.buttonStyle(.bordered).accessibilityIdentifier("product.approve.martin") }
                            if !p.annaApproved { Button("Anna approves") { store.setApproval(p, householdMember: "Anna") }.buttonStyle(.bordered).accessibilityIdentifier("product.approve.anna") }
                            if p.approved && p.listQuantity == nil {
                                Button("Add to shopping list") { var updated = p; updated.listQuantity = "1"; store.update(updated) }.buttonStyle(.borderedProminent).tint(PantryStyle.green).accessibilityIdentifier("product.addToList")
                            }
                        }
                    }.frame(maxWidth: 600, alignment: .leading).padding(24).frame(maxWidth: .infinity)
                }
                .navigationTitle(p.name)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .sheet(isPresented: $editing) { ProductEditorSheet(product: p).environmentObject(store) }
            } else { EmptyStateView(title: "Food not found", detail: "Return to the product library and choose another food.") }
        }
    }
    private func detailSection(_ title: String, _ text: String) -> some View { VStack(alignment: .leading, spacing: 6) { Text(title).font(.headline); Text(text).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true) } }
    private func storeSummary(_ p: PantryProduct) -> String {
        let stores = p.stores.isEmpty ? "Stores not set" : p.stores.joined(separator: ", ")
        let currency = store.selectedMarket.hasPrefix("Sweden") ? "SEK" : "EUR"
        let prices = if p.minimumPrice != nil || p.maximumPrice != nil {
            p.priceCurrency == currency ? " · \(currency) \(p.minimumPrice.map { String(format: "%.2f", $0) } ?? "—")–\(p.maximumPrice.map { String(format: "%.2f", $0) } ?? "—")" : " · Price stored in \(p.priceCurrency ?? "unspecified currency")"
        } else { " · Price limit not set" }
        return stores + prices
    }
}

struct ProductEditorSheet: View {
    @EnvironmentObject private var store: PantryStore
    @Environment(\.dismiss) private var dismiss
    let product: PantryProduct?
    @State private var name = ""
    @State private var category = "Fruit"
    @State private var tips = ""
    @State private var criteria = ""
    @State private var storeChoice = "ICA"
    @State private var minimum = ""
    @State private var maximum = ""
    @State private var exactProduct = ""
    @State private var packageSize = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    private let categories = ["Berries", "Fruit", "Vegetables", "Beans & lentils", "Nuts & seeds", "Grains", "Plant-based dairy", "Oils", "Other"]
    var body: some View {
        NavigationStack {
            Form {
                Section("Food") {
                    TextField("Product or food name", text: $name).accessibilityIdentifier("product.edit.name")
                    TextField("Exact brand / product", text: $exactProduct)
                    TextField("Package size or unit", text: $packageSize)
                    Picker("Category", selection: $category) { ForEach(categories, id: \.self) { Text($0) } }
                    TextField("Selection tip", text: $tips, axis: .vertical).lineLimit(2...4)
                    TextField("Ingredients / processing rule", text: $criteria, axis: .vertical).lineLimit(2...4)
                }
                Section("Store and price guardrail") {
                    Picker("Store", selection: $storeChoice) { ForEach(store.selectedMarket.hasPrefix("Sweden") ? ["ICA", "Coop", "Willys", "Lidl", "Other"] : ["Aldi", "Edeka", "REWE", "Lidl", "Other"], id: \.self) { Text($0) } }
                    HStack { TextField("Minimum", text: $minimum); TextField("Maximum", text: $maximum) }
                    Text("Prices are entered and maintained by your household.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Package photo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) { Text("Choose package photo") }
                    if let photoData { PackagePhoto(data: photoData).frame(maxHeight: 150) }
                }
            }
            .navigationTitle(product == nil ? "Add food" : "Edit food")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.keyboardShortcut(.cancelAction) }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty).keyboardShortcut("s", modifiers: .command).accessibilityIdentifier("product.edit.save") }
            }
            .onAppear(perform: load)
            .task(id: selectedPhoto) { if let selectedPhoto { photoData = try? await selectedPhoto.loadTransferable(type: Data.self) } }
        }
    }
    private func load() {
        guard let p = product else {
            if store.selectedMarket.hasPrefix("Germany") { storeChoice = "Aldi" }
            return
        }
        name = p.name; category = p.category; tips = p.selectionGuide; criteria = p.ingredientsCriteria
        exactProduct = p.suggestedProduct ?? ""; packageSize = p.packageSize ?? ""
        storeChoice = p.stores.first ?? "ICA"; minimum = p.minimumPrice.map { String($0) } ?? ""; maximum = p.maximumPrice.map { String($0) } ?? ""; photoData = p.imageData
    }
    private func save() {
        let minVal = Double(minimum.replacingOccurrences(of: ",", with: ".")); let maxVal = Double(maximum.replacingOccurrences(of: ",", with: "."))
        if var p = product {
            p.name = name; p.category = category; p.suggestedProduct = exactProduct.isEmpty ? nil : exactProduct; p.packageSize = packageSize.isEmpty ? nil : packageSize; p.selectionGuide = tips; p.ingredientsCriteria = criteria; p.stores = [storeChoice]; p.minimumPrice = minVal; p.maximumPrice = maxVal; p.priceCurrency = store.selectedMarket.hasPrefix("Sweden") ? "SEK" : "EUR"; p.imageData = photoData
            p.approved = false; p.martinApproved = false; p.annaApproved = false
            store.update(p)
        } else {
            store.add(PantryProduct(id: UUID().uuidString, name: name, category: category, suggestedProduct: exactProduct.isEmpty ? nil : exactProduct, packageSize: packageSize.isEmpty ? nil : packageSize, ingredientsCriteria: criteria, selectionGuide: tips, countries: [store.selectedMarket.hasPrefix("Sweden") ? "SE" : "DE"], approved: false, stores: [storeChoice], minimumPrice: minVal, maximumPrice: maxVal, priceCurrency: store.selectedMarket.hasPrefix("Sweden") ? "SEK" : "EUR", listQuantity: nil, imageData: photoData))
        }
        dismiss()
    }
}

struct LabelGuideView: View {
    var body: some View {
        List {
            Section("Start with the ingredient list") {
                guide("Look for whole or minimally processed foods", "Choose familiar ingredients and compare similar products by their ingredient lists.")
                guide("Check the order", "Ingredients are listed by weight. The first ingredients make up most of the product.")
                guide("Use the nutrition table", "Compare per 100 g or 100 ml when comparing products. Check fibre, salt, sugars and saturated fat against your household rules.")
            }
            Section("Swedish labels") {
                guide("Common terms", "Energi (energy), fett (fat), varav mättat fett (of which saturates), kolhydrat (carbohydrate), varav sockerarter (of which sugars), fiber (fibre), protein (protein), salt (salt).")
                guide("Allergen emphasis", "Swedish ingredient lists emphasize regulated allergens in the ingredient text. Still read the full list each time.")
            }
            Section("German labels") {
                guide("Common terms", "Brennwert (energy), Fett (fat), davon gesättigte Fettsäuren (of which saturates), Kohlenhydrate (carbohydrate), davon Zucker (of which sugars), Ballaststoffe (fibre), Eiweiß (protein), Salz (salt).")
                guide("Ingredients", "Zutaten means ingredients. Read the full list and compare per 100 g or 100 ml.")
            }
            Section { Text("This guide helps translate label terms. It does not score foods or replace your own household rules.").font(.footnote).foregroundStyle(.secondary) }
        }
        .navigationTitle("Reading food labels")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
    private func guide(_ title: String, _ body: String) -> some View { VStack(alignment: .leading, spacing: 5) { Text(title).font(.headline); Text(body).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true) }.padding(.vertical, 3) }
}
