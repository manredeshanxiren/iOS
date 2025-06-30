# Lecture 5  Stanford CS193p 2023

[TOC]

# 1.`enum`

------

## 1.1 基础定义

```swift
enum FastFoodMenuItem {
  case hamburger
  case fries
  case drink
  case cookie
}
```

- **值类型**：枚举实例传递或赋值时会被拷贝。
- **协议支持**：可实现 `Equatable`、`Hashable`、`CaseIterable`、`CustomStringConvertible` 等。

------

## 1.2 关联值（Associated Data）

```swift
enum FastFoodMenuItem {
  case hamburger(numberOfPatties: Int)
  case fries(size: FryOrderSize)
  case drink(String, ounces: Int)    // 第一个参数未命名
  case cookie
}

enum FryOrderSize { case large, small }
```

- **定义**：每个 `case` 自带不同类型／数量的数据。

- **构造示例**：

  ```swift
  let order1 = FastFoodMenuItem.hamburger(numberOfPatties: 2)
  let order2 = FastFoodMenuItem.drink("Coke", ounces: 12)
  ```

- **匹配与解包**：

  ```swift
  switch order2 {
  case .drink(let brand, let oz):
    print("\(brand)：\(oz)oz")
  default:
    break
  }
  ```

------

## 1.3 类型推断与简写

```swift
let item1 = FastFoodMenuItem.hamburger(numberOfPatties: 2)
var item2: FastFoodMenuItem = .cookie   // 可省略枚举名
// var item3 = .cookie                  // 无上下文时编译失败
```

- **要求**：只有当变量／参数处显式声明了枚举类型，才能在赋值处写成 `.caseName`。

- **函数调用推断**：

  ```swift
  func serve(_ item: FastFoodMenuItem) { … }
  serve(.fries(size: .large))
  ```

------

## 1.4 状态检查（`switch`）

```swift
switch menuItem {
case .hamburger:
  print("burger")
case .fries:
  print("fries")
case .drink:
  print("drink")
case .cookie:
  print("cookie")
}
```

- **强制穷举**：必须覆盖所有 `case` 或提供 `default`。

- **忽略关联值**：`case .drink:` 等同于 `case .drink(_, _)`。

- **条件匹配**：

  ```swift
  switch order {
  case .hamburger(let n) where n > 2:
    print("大份汉堡")
  default:
    break
  }
  ```

------

## 1.5 `break` 与 `fallthrough`

- **`break`**
   Swift `switch` 不会自动穿透，空 `case` 可省略 `break`。

- **`fallthrough`**

  ```swift
  switch code {
  case 401:
    print("Unauthorized")
    fallthrough
  case 403:
    print("Forbidden")
  default:
    break
  }
  ```

  > `fallthrough` 仅跳到下一个 `case`，不会重新判断条件或解包关联值。

------

## 1.6 注意事项

- **关联值比较**：自动合成的 `Hashable`/`Equatable` 会将关联值纳入比较。

- **ID 冲突**：使用 `CaseIterable` 时要避免不同枚举重复。

- **递归枚举**：使用 `indirect` 支持递归结构。

  ```swift
  indirect enum Expr {
    case number(Int)
    case add(Expr, Expr)
  }
  ```

- **同名枚举**：在多枚举同名 `case` 场景下，赋值处需显式指明类型以消除歧义。

------

## 1.7 拓展用法

1. **`CaseIterable`**

   ```swift
   enum FastFoodMenuItem: CaseIterable {
     case hamburger, fries, drink, cookie
   }
   FastFoodMenuItem.allCases  // [.hamburger, .fries, ...]
   ```

2. **原始值枚举**

   ```swift
   enum HTTPStatus: Int {
     case ok = 200, notFound = 404, unauthorized = 401
   }
   HTTPStatus(rawValue: 404)  // .notFound
   ```

3. **协议实现**

   - 自定义 `CustomDebugStringConvertible` 打印关联值细节。
   - 实现 `Codable` 可直接 JSON 序列化／反序列化。

4. **模式匹配**

   ```swift
   if case .cookie = item {
     print("吃饼干")
   }
   ```

------

## 1.8 `default` 分支

- **用途**：当你只关注部分 case，其它“其余情况”可统一归入 `default`。

- **示例**

  ```swift
  var menuItem = FastFoodMenuItem.cookie
  
  switch menuItem {
  case .hamburger:
    print("🍔")
  case .fries:
    print("🍟")
  default:
    print("其它")      // cookie、drink 都走到这里
  }
  // 输出："其它"
  ```

- **注意**

  - 一旦包含了 `default`，编译器将不再强制你穷举所有具体 case。
  - 若同时存在 `default` 且又写了所有 case，则 `default` 只处理未来新增或遗漏的 case。

------

## 1.9 关联值的取出（`let` 语法）

- **目的**：在 `switch` 中解包并绑定每个 case 的关联数据。

- **核心写法**：

  ```swift
  switch order {
  case .hamburger(let patties):
    print("汉堡：\(patties) 份")
  case .fries(let size):
    print("薯条：\(size)")
  case .drink(let brand, let ounces):
    print("\(brand) — \(ounces)oz")
  case .cookie:
    print("饼干")
  }
  ```

- **同类写法**

  ```swift
  case let .hamburger(patties):
    // 与上面等价
  ```

- **注意**

  - 可省略标签位置，但位置与类型必须一一对应。
  - 若只想匹配而不需要值，可写成 `case .drink:`（等同于 `.drink(_, _)`）。

------

## 1.10 遍历所有 case：`CaseIterable`

- **定义**：让枚举自动生成一个静态数组 `allCases`，包含所有 case。

- **示例**

  ```swift
  enum TeslaModel: CaseIterable {
    case X, S, three, Y
  }
  
  // 遍历
  for model in TeslaModel.allCases {
    print(model)
  }
  // 输出：X S three Y
  ```

- **应用**

  - 快速构建 UI 列表：

    ```swift
    Picker("选择车型", selection: $selectedModel) {
      ForEach(TeslaModel.allCases, id: \.self) { m in
        Text("\(m)")
      }
    }
    ```

  - 批量统计／上报：

    ```swift
    func reportSales() {
      TeslaModel.allCases.forEach { model in
        reportSales(for: model)
      }
    }
    ```

- **注意**

  - 仅支持无关联值的简单枚举。
  - 若有关联值／原始值枚举，需自行实现 `allCases`。

------

# 2. Optional（可选类型）

## 2.1 定义

在 Swift 中，`Optional` 就是一个带有关联值的枚举：

```swift
enum Optional<Wrapped> {
  case none
  case some(Wrapped)
}
```

- `none`：表示“缺值”（`nil`）。
- `some(Wrapped)`：表示“有值”，其中 `Wrapped` 是任意类型。

## 2.2 样例

```swift
let possibleName: String? = "Alice"
let noName: String?     = nil

// 强制解包（可能崩溃）
print(possibleName!)     // "Alice"
// print(noName!)        // Crashes

// 安全解包—if let
if let name = possibleName {
    print("Hello, \(name)")
} else {
    print("No name")
}

// 安全解包—guard let
func greet(_ name: String?) {
    guard let n = name else {
        print("Missing name"); return
    }
    print("Hi, \(n)")
}

// switch+pattern
switch possibleName {
case .none:
    print("无值")
case .some(let actual):
    print("值是：\(actual)")
}
```

## 2.3 注意事项

1. **强制解包风险**
    使用 `!` 前须确保非 `nil`，否则运行时崩溃。

2. **Optional chaining**

   ```swift
   let length = possibleName?.count  // 返回 Int? 
   ```

3. **Nil 合并运算符**

   ```swift
   let displayName = possibleName ?? "Guest"
   
   //等价于如下：
   
   let displayName = possibleName != nil ? possibleName! : "Guest"
   ```

4. **`map` / `flatMap`**

   ```swift
   let upper = possibleName.map { $0.uppercased() }        // String?
   let num   = Int("123").flatMap { $0 * 2 }               // Int?
   ```

## 2.4 拓展

- **`guard` vs `if`**：建议在函数开头用 `guard` 提前退出，保持主逻辑左括号少嵌套。

- **自定义解包**：自定义操作符或扩展，比如

  ```swift
  postfix operator ??
  postfix func ??<T>(value: T?) -> T {
    return value ?? fatalError("Unexpected nil")
  }
  ```

- **`Optional` 本质**：知道它就是个枚举，能帮助你用 `switch`、关联值等枚举技巧处理它。

------

# 2. Functions as Arguments（函数/闭包作为参数）

## 2.1定义

Swift 函数是第一类类型，可以作为参数、返回值或存储：

```swift
func foo(x: Int) -> String { … }

func bar(transform: (Int) -> String) {
    let s = transform(42)
    print(s)
}
bar(transform: foo)           // 传函数名
bar { "\($0)" }               // 传尾随闭包
```

## 2.2样例（MemoryGame）

```swift
struct MemoryGame<CardContent> {
  var cards: [Card]
  // cardContentFactory: 从索引 Int 构造内容的闭包
  init(numberOfPairs: Int, cardContentFactory: (Int) -> CardContent) {
    cards = []
    for pairIndex in 0..<numberOfPairs {
      let content = cardContentFactory(pairIndex)
      cards.append(Card(content: content, id: pairIndex*2))
      cards.append(Card(content: content, id: pairIndex*2+1))
    }
  }
}
// 调用方式：
let game = MemoryGame<String>(
    numberOfPairs: 5,
    cardContentFactory: { index in
        return ["🐶","🐱","🐭","🦊","🐻"][index]
    }
)
// 或者尾随闭包
let game2 = MemoryGame<Int>(numberOfPairs: 3) { $0 * $0 }
```

## 2.3注意事项

1. **`@escaping`**

   - 如果闭包被保存在实例中、或异步调用，参数需标记 `@escaping`。

   ```swift
   init(factory: @escaping (Int)->CardContent) { … }
   ```

2. **`@autoclosure`**

   - 用于延迟求值、消除调用时 `{}`。

   ```swift
   func log(_ message: @autoclosure ()->String) { … }
   log("Hello \(Date())")  // 自动转换为闭包
   ```

3. **捕获列表**

   - 小心闭包对外部变量／`self` 的捕获，可能导致循环引用。

   ```swift
   class A {
     lazy var printer: ()->Void = { [weak self] in print(self?.description) }
   }
   ```

## 2.4拓展

- **高阶函数**：`map`、`filter`、`reduce` 都是典型示例。
- **函数组合**：可用自定义运算符将多个 `(A)->B` 链接成一个。
- **协议与闭包**：有时可用协议替代闭包，取决于代码可读性和扩展性需求。

------

# 3. 计算属性（`get` / `set`）

## 3.1定义

`computed property`：不存储值，而是通过 `get`、`set` 动态计算。

```swift
struct Circle {
  var radius: Double

  // 只读
  var area: Double {
    return .pi * radius * radius
  }

  // 读写
  var diameter: Double {
    get { return radius * 2 }
    set { radius = newValue / 2 }
  }
}
```

## 3.2样例（MemoryGame 的唯一翻面卡索引）

```swift
struct MemoryGame<CardContent> {
  private(set) var cards: [Card]

  // 只读或读写
  private var indexOfTheOneAndOnlyFaceUpCard: Int? {
    get {
      let faceUpIndices = cards.indices.filter { cards[$0].isFaceUp }
      return faceUpIndices.count == 1 ? faceUpIndices.first : nil
    }
    set {
      // 将所有卡片翻到 newValue，或都背面
      for idx in cards.indices {
        cards[idx].isFaceUp = (idx == newValue)
      }
    }
  }

  mutating func choose(_ card: Card) {
    if let chosenIndex = cards.firstIndex(matching: card),
       let potentialMatch = indexOfTheOneAndOnlyFaceUpCard {
      // ... 匹配逻辑
      indexOfTheOneAndOnlyFaceUpCard = nil
    } else {
      indexOfTheOneAndOnlyFaceUpCard = cards.firstIndex(matching: card)
    }
  }
}
```

## 3.3注意事项

1. **`newValue`**

   - `set` 中默认参数名是 `newValue`，也可自定义：

     ```swift
     set(updatedIndex) { … }
     ```

2. **只能用于计算属性**

   - `willSet`/`didSet` 只能用于存储属性，不能与 `get/set` 同时使用。

3. **性能**

   - 复杂计算应避免在频繁访问的属性里卡顿，可考虑缓存或存储属性。

## 3.4拓展

- **`lazy var`**

  - 延迟初始化存储属性，第一次访问时计算并保存。

- **下标（`subscript`）**

  - 类似计算属性，可带 `get`/`set`：

    ```swift
    struct Matrix {
      var data: [Double]
      let rows, cols: Int
      subscript(r: Int, c: Int) -> Double {
        get { data[r*cols + c] }
        set { data[r*cols + c] = newValue }
      }
    }
    ```

------

# 4. Extension（扩展）

## 4.1 定义

使用 `extension`，可为已有类型（`struct`、`class`、`enum`、`protocol`）新增功能：

```swift
extension String {
  // 计算属性
  var isPalindrome: Bool {
    let s = lowercased().filter { $0.isLetter }
    return s == String(s.reversed())
  }

  // 方法
  func truncated(to length: Int) -> String {
    return (count > length) ? prefix(length) + "…" : self
  }

  // 下标
  subscript(idx: Int) -> Character {
    self[index(startIndex, offsetBy: idx)]
  }

  // 嵌套类型
  enum Kind { case vowel, consonant, other }
}
```

## 4.2 注意事项

1. **不能添加存储属性**

   - 只能新增计算属性、方法、构造器（`init`）、下标、嵌套类型、协议遵循。

2. **协议扩展**

   - 可给协议提供“默认实现”：

     ```swift
     protocol Drawable { func draw() }
     extension Drawable {
       func draw() { print("Default draw") }
     }
     ```

3. **命名冲突**

   - 与原类型或其他扩展同名成员，后加载的会覆盖，需谨慎避免冲突。

## 4.3 拓展

- **条件扩展**

  - 为满足特定 `where` 条件的泛型类型扩展：

    ```swift
    extension Array where Element: Equatable {
      func occurrences(of x: Element) -> Int {
        filter { $0 == x }.count
      }
    }
    ```

- **模块统一**

  - 将常用工具方法放在单独文件，通过 `extension` 统一管理。

- **链式调用**

  - 为类型添加可变方法，并返回 `Self` 支持链式：

    ```swift
    extension UIView {
      @discardableResult
      func corner(radius: CGFloat) -> Self {
        layer.cornerRadius = radius; return self
      }
    }
    view.corner(radius: 8).backgroundColor = .red
    ```

------

> **总结**
>
> - **Optional**：理解其枚举本质，安全解包与链式操作。
> - **函数参数**：灵活运用闭包、尾随、`@escaping`、`@autoclosure`。
> - **计算属性**：`get`/`set` 强大，能实现高度封装。
> - **Extension**：无侵入地增强类型功能，写出更优雅、可复用的代码。

# 5.Protocol

## 5.1 协议的本质

- **协议（Protocol）是一种抽象“契约”**，它只声明了要做什么（方法、属性、下标），而不关心具体如何实现。
- 任意类型（结构体、类、枚举）只要承诺遵守该协议，就必须实现协议中所有的“要求”，从而保证了不同类型之间的**统一行为**。

------

## 5.2 协议的基本语法

```swift
protocol Vehicle {
    // 属性要求
    var numberOfWheels: Int { get }      // 只读
    var color: String { get set }        // 可读写

    // 方法要求
    func startEngine()                   // 实例方法
    mutating func turn(direction: String) // 可变方法（值类型用 mutating）

    // 构造器要求（只能用 class/struct 遵守）
    init(model: String)
}
```

- `var 属性名: 类型 { get | get set }`：声明属性的读写权限。
- 普通实例方法无需额外前缀；如果是**值类型**（struct/enum）中会修改自身的状态，需加 `mutating`。
- `init(...)`：协议可以要求实现特定的构造器，但只有类/结构体能遵守。

------

## 5.3 类型如何遵守协议

以结构体 `Car` 为例：

```swift
struct Car: Vehicle {
    let numberOfWheels = 4
    var color: String
    var model: String

    func startEngine() {
        print("\(model) 发动机已启动")
    }

    mutating func turn(direction: String) {
        print("\(model) 向 \(direction) 转弯")
        // （如果要改变自身属性，必须用 mutating）
        color = "正在转弯时的颜色变化示例"
    }

    init(model: String) {
        self.model = model
        self.color = "黑色"  // 默认颜色
    }
}
```

- `Car` 必须实现 `Vehicle` 中所有要求的属性、方法和构造器。
- 可以利用常量 `let` 或变量 `var` 来满足读写需求；只读可用 `let`。

------

## 5.4 协议作为类型使用

协议本身也构成了一种**类型**，可用于：

1. **函数参数/返回值**
2. **数组、字典等容器元素**
3. **变量、常量类型**

```swift
func testDrive(vehicle: Vehicle) {
    vehicle.startEngine()
}

let myCar = Car(model: "Model S")
testDrive(vehicle: myCar)  // 不关心具体是 Car 还是 Bike，只要是 Vehicle 即可
```

------

## 5.5 协议继承与组合

- **继承**：协议可以从一个或多个父协议继承，获得更丰富的要求。
- **组合**：使用 `&` 符号将多个协议合并为一个复合类型。

```swift
protocol Electric {
    var batteryLevel: Double { get }
    func recharge()
}

protocol ElectricVehicle: Vehicle, Electric { }

func statusReport(ev: ElectricVehicle) {
    ev.startEngine()
    print("电量：\(ev.batteryLevel)")
}

// 组合类型
func check<T: Vehicle & Electric>(item: T) {
    print("轮子数：", item.numberOfWheels)
}
```

------

## 5.6 关联类型（Associated Type）

当协议中需要“占位”类型时，用 `associatedtype` 声明：

```swift
protocol Container {
    associatedtype Item  // 占位
    var count: Int { get }
    mutating func append(_ item: Item)
    subscript(i: Int) -> Item { get }
}

struct IntStack: Container {
    // 自动推断 Item = Int
    var items = [Int]()
    var count: Int { items.count }
    mutating func append(_ item: Int) { items.append(item) }
    subscript(i: Int) -> Int { items[i] }
}
```

- 遵守方会**指定**关联类型（或让编译器推断）。

------

## 5.7 协议扩展与默认实现

协议扩展可提供默认行为，遵守类型可直接使用或自行覆盖：

```swift
extension Vehicle {
    func describe() {
        print("这是一个有 \(numberOfWheels) 个轮子、颜色为 \(color) 的交通工具")
    }
}

let car = Car(model: "Civic")
car.describe()  // 协议扩展里的默认实现
```

- 扩展中也可添加**非要求**（Unrelated）方法，统一所有遵守类型的工具函数。

------

## 5.8 可选协议要求（@objc 协议）

只适用于继承自 Objective-C 的类，需加 `@objc` 及 `optional`：

```swift
@objc protocol DownloadDelegate {
    @objc optional func didStart()
    @objc optional func didFinish()
}

class Downloader {
    weak var delegate: DownloadDelegate?
    func start() {
        delegate?.didStart?()
        // … 下载逻辑 …
        delegate?.didFinish?()
    }
}
```

- 只有类能遵守 `@objc` 协议，且方法前要加 `optional`。

------

## 5.9 小例：绘制不同图形并计算面积

```swift
// 定义协议
protocol Shape {
    func area() -> Double
}

// 不同类型实现该协议
struct Circle: Shape {
    var radius: Double
    func area() -> Double { .pi * radius * radius }
}

struct Rectangle: Shape {
    var width, height: Double
    func area() -> Double { width * height }
}

// 使用协议类型
let shapes: [Shape] = [Circle(radius: 2), Rectangle(width: 3, height: 4)]
for s in shapes {
    print("面积：", s.area())
}
```

- 这样无需关心具体图形类型，即可统一处理。

------

## 5.10 应用场景与建议

1. **解耦**：将行为抽象成协议，而非继承体系，增加灵活性。
2. **泛型约束**：在泛型中用协议做约束，提高复用性和类型安全。
3. **分层设计**：先定义协议契约，再按职责划分具体实现，便于测试和 Mock。
4. **默认实现**：在协议扩展中编写公共逻辑，减少重复代码。

下面再补充两部分内容，分别介绍 **Swift 标准库中常见的“自带”协议**，以及 **如何自定义并实现自己的协议**。

------

## 5.11 常见标准库协议

| 协议名                               | 功能简介                                                     |
| ------------------------------------ | ------------------------------------------------------------ |
| `Equatable`                          | 判断两个实例是否相等，只需实现 `static func ==(lhs:Self, rhs:Self) -> Bool`。 |
| `Comparable`                         | 提供 `<`, `<=`, `>`, `>=` 等比较操作，需要同时遵守 `Equatable`，并实现 `static func <(lhs:Self, rhs:Self) -> Bool`。 |
| `Hashable`                           | 支持哈希运算，使类型可用于 `Set` 或字典的键。需实现 `func hash(into: inout Hasher)`，并自动满足 `Equatable`。 |
| `Codable`（`Encodable`+`Decodable`） | 支持自动或手动将类型与 JSON、Plist 等外部表示相互转换。多数简单类型可“自动合成”。 |
| `CustomStringConvertible`            | 自定义打印时的描述，只需实现 `var description: String { get }`。 |
| `Sequence`                           | 表示可枚举（迭代）的集合类型。需要实现 `makeIterator()`，返回符合 `IteratorProtocol` 的迭代器。 |
| `Collection`                         | 在 `Sequence` 基础上增加索引访问、 `startIndex` / `endIndex` 等要求，用于更复杂的集合。 |
| `RawRepresentable`                   | 将类型与“原始值”（如 `String`、`Int`）相互映射；常用于枚举。需实现 `init?(rawValue:)` 和 `var rawValue`。 |
| `ExpressibleByLiteral...` 系列       | 允许类型通过字面量直接初始化，如 `ExpressibleByStringLiteral`、`ExpressibleByIntegerLiteral` 等。 |

### 示例：让自定义类型支持 `Codable`、`CustomStringConvertible`

```swift
struct User: Codable, CustomStringConvertible {
    var id: Int
    var name: String

    // CustomStringConvertible 要求
    var description: String {
        return "User(id: \(id), name: \(name))"
    }
}

// 自动合成 JSON 编解码
let json = """
{"id": 42, "name": "Alice"}
""".data(using: .utf8)!

let decoder = JSONDecoder()
let alice = try decoder.decode(User.self, from: json)
print(alice)  // 输出：User(id: 42, name: Alice)

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
print(String(data: try encoder.encode(alice), encoding: .utf8)!)
```

------

## 5.12 自定义协议的完整流程

1. **定义协议**
    使用 `protocol` 关键字声明属性、方法、构造器等“契约”。
2. **扩展协议（可选）**
    通过 `extension` 为协议添加默认实现或辅助方法。
3. **遵守协议**
    在 `class`／`struct`／`enum` 声明处加上 `: YourProtocol`，并实现所有要求。
4. **作为类型使用**
    将协议名作为函数参数、返回值或容器元素类型，实现多态。

### 例：定义一个可缓存（Cacheable）的协议

```swift
// 1. 定义协议
protocol Cacheable {
    associatedtype DataType
    var cacheKey: String { get }           // 缓存标识
    func save(_ value: DataType)           // 保存到缓存
    func load() -> DataType?               // 从缓存读取
}

//全局私有存储（文件作用域）
fileprivate var _globalMemoryCache = [String: Any]()

// 2. 协议扩展：提供一个默认的内存缓存实现
extension Cacheable {
    // 静态计算属性，读写都转发到 _globalMemoryCache
    private static var memoryCache: [String: Any] {
        get { _globalMemoryCache }
        set { _globalMemoryCache = newValue }
    }
  
    func save(_ value: DataType) {
        Self.memoryCache[cacheKey] = value
    }

    func load() -> DataType? {
        return Self.memoryCache[cacheKey] as? DataType
    }
}

// 3. 遵守协议：为 String 类型提供缓存支持
struct StringCache: Cacheable {
    typealias DataType = String

    let cacheKey: String

    init(key: String) {
        self.cacheKey = key
    }
}

// 4. 使用示例
var userCache = StringCache(key: "currentUserName")
userCache.save("张三")
if let name = userCache.load() {
    print("从缓存加载用户名：\(name)")  // 输出：从缓存加载用户名：张三
}
```

通过上述流程，你可以轻松地：

- **定义灵活的抽象**（`Cacheable`），
- **提供默认实现**（内存缓存），
- **在不同类型上复用**（可为图片、数据模型等实现缓存），
- **并在业务代码中统一使用协议类型**，实现低耦合、高扩展性。