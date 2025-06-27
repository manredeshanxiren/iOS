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