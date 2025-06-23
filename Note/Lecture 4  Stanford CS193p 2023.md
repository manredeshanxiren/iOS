# Lecture 4 | Stanford CS193p 2023

- 课程链接：https://www.youtube.com/watch?v=4CkEVfdqjLw

- 代码仓库：[iOS](https://github.com/manredeshanxiren/iOS)

- 课程大纲：

  **简要课程大纲：SwiftUI 高级主题**

  1. **Swift 访问控制（Access Control）**
     - 5 个级别：`open`、`public`、`internal`、`fileprivate`、`private`
     - `private(set)` 与 `fileprivate(set)` 的用法
     - 在 SwiftUI 视图与模块化中的最佳实践
  2. **视图初始化（`init`）与属性包装器配合**
     - 合成 `init` 与自定义 `init` 时机
     - 在 `init` 中正确配置：
       - `@Binding`（父–子双向绑定）
       - `@ObservedObject`（外部传入模型）
       - `@StateObject`（首次创建模型）
     - `init` 中的限制与应将副作用延后到 `onAppear`
  3. **循环与遍历 (`for-in`)**
     - 遍历数组、字典、范围 (`Range`)
     - `enumerated()` 获取索引
     - `where` 条件过滤、`break`/`continue`
     - 修改原集合的技巧
  4. **函数类型与闭包（Functions & Closures）**
     - 函数即类型：`() -> Void`、`(Int) -> String`、`() -> some View`
     - 回调参数与自定义 `ViewBuilder`
     - 闭包语法简写：类型推断、`$0`、省略 `return`
     - **捕获（Capturing）**：闭包如何“包住”外部变量
  5. **异步与逃逸闭包 (`@escaping`、`async/await`)**
     - 何时使用 `@escaping`：网络请求、GCD、定时器
     - SwiftUI 中的异步：`Task { await … }`、`.task` & 按钮内部
     - 结合 `@MainActor` 回到主线程更新状态
  6. **类型级成员：`static` 变量与函数**
     - 与实例无关的常量、工具方法
     - 共享样式、格式化器、预览提供者 (`PreviewProvider`)
     - `struct`/`enum` 命名空间模式
  7. **值类型方法的 `mutating`**
     - 为什么值类型默认不可变
     - 在模型层封装可变逻辑：`mutating func`
     - SwiftUI 中通过 `@State`/`@Binding` 替代直接使用
  8. **语义化重命名（Semantic Rename）**
     - Xcode Refactor → Rename 操作
     - 跨文件、跨模块安全重命名接口／类型
     - 保持项目代码一致性
  9. **SwiftUI 响应式 UI 与状态管理**
     - **单一真相** 与 **声明式＋响应式** 流程
       1. 状态改变（`@State`、`@Published`、环境值）
       2. Combine Publisher 发事件
       3. SwiftUI 标记 View 失效 → 重算 `body` → diff → 渲染
     - 属性包装器详解：
       - `@State`：局部轻量状态
       - `@Binding`：父–子双向绑定
       - `@StateObject`：首次创建并拥有的模型
       - `@ObservedObject`：外部传入并订阅的模型
       - `@EnvironmentObject`：跨层级共享模型
       - `@Environment`: 系统／自定义环境值
     - 典型场景示例与对比

  
---
[TOC]



# 1. access control
在 SwiftUI 中，访问控制（Access Control）沿用了 Swift 语言本身的五个级别：open、public、internal（默认）、fileprivate、private。合理运用这些修饰符，能有效隔离视图接口与内部实现，增强模块化与可维护性。以下分几部分详述其在 SwiftUI 开发中的常见应用和注意事项。
| 级别          | 模块外可见 | 同一模块内可见 | 同一文件内可见 | 同一类型内可见 |
| ------------- | :--------: | :------------: | :------------: | :------------: |
| `open`        |     ✅      |       ✅        |       ✅        |       ✅        |
| `public`      |     ✅      |       ✅        |       ✅        |       ✅        |
| `internal`    |     ❌      |       ✅        |       ✅        |       ✅        |
| `fileprivate` |     ❌      |       ❌        |       ✅        |       ✅        |
| `private`     |     ❌      |       ❌        |       ❌        |       ✅        |

- open/public：导出的 API，可被外部模块导入与调用；只有 open 允许被子类化与重写。
- internal（默认）：仅限当前模块（App 或 Framework）内部可见。
- fileprivate：仅限同一源文件内可见。
- private：仅限同一声明域（类型或扩展）内可见。
---

## 1.1 叠加用法：

Swift 目前只支持将 setter 访问权限 狭窄化到 fileprivate 或 private，也就是只有这两种写法，你可以把它们和任何更宽松的访问级别（open、public、internal、fileprivate）配合使用，但不能反过来扩大：

```swift
// —— 合法：只能比声明级别更“私有” ——

// 1️⃣ 完全私有：同类型（同扩展/同花括号）内可写，其它地方只读
private(set) var foo: Int  

// 2️⃣ 文件私有：同文件内可写，其它文件只读
fileprivate(set) var bar: Int  

// 3️⃣ 公共只读：模块外可读，模块/文件内可读，只有类型内部可写
public private(set) var baz: Int  

// 4️⃣ 开放只读（rare）：模块外可继承/可重写，外部可读，只有类型内私有写
open private(set) var qux: Int  

// 5️⃣ 模块内只写：显式写 internal private(set)，等同默认 internal＋private(set)
internal private(set) var quux: Int  
```
不能写成 public(set)、internal(set)、open(set) 之类的——编译器只允许你用 fileprivate(set) 或 private(set)。


## 1.2 细节：

1️⃣ open和public的区别：

- open = 公共可访问 + 外部可继承/可重写
- public = 仅公共可访问，外部不可继承/不可重写

选择时，牢记“最小暴露原则”：能用 public 限制就别用 open，避免无意中开放过多扩展点。另外这里可以看到差异主要在继承性上，所以**open只能修饰可继承的类型**！



2️⃣ 视图类型（struct View）的可见性：

- 默认 internal：如果你不标注，SwiftUI 视图对同一模块内都可见；通常足够应用内部模块化。


# 2.init
在 SwiftUI 中，所有视图（View）本质上都是值类型（struct），它们的初始化器（init）承担着以下核心职责：

 1. 接收外部参数并初始化存储属性
 2. 配置属性包装器（@State、@Binding、@ObservedObject、@StateObject 等）
 3. 决定视图的初始状态

下面从几个角度详细说明 SwiftUI 中的 init 使用要点。

## 2.1  默认合成的 init 与何时需要自定义
- **合成初始化器:**
如果你的 `struct MyView: View `中所有存储属性都有默认值，且你没有显式定义任何` init`，Swift 会自动合成一个无参 `init()`。
- **需要自定义的场景:**
视图需要接受参数，例如：
```swift
struct GreetingView: View {
  let name: String
  var body: some View { Text("Hello, \(name)!") }
}
// Swift 会合成: init(name: String)
```

## 2.2 与属性包装器配合
@State、@Binding、@ObservedObject、@StateObject

> [!NOTE]
>
> 注意：SwiftUI 中的这些属性包装器都遵从 DynamicProperty，init 中的赋值通常要用底层存储属性（带下划线的形式）。

| 包装器                                | 初始化要求                                                   |
| ------------------------------------- | ------------------------------------------------------------ |
| `@State`                              | 可给出初始值：`@State private var count = 0`，无需在 `init` 中处理 |
| `@Binding`                            | 必须由父视图传入：`init(isOn: Binding<Bool>) { _isOn = isOn }` |
| `@ObservedObject`                     | 通常由外部传入已有的 ObservableObject：`init(viewModel: VM) { _viewModel = ObservedObject(wrappedValue: viewModel) }` |
| `@StateObject`                        | 只在视图生命周期内首次创建：`init() { _vm = StateObject(wrappedValue: VM()) }` 或通过参数注入 |
| `@EnvironmentObject` / `@Environment` | 由系统注入，不需手动初始化                                   |

例如：

```swift
class VM: ObservableObject {
  @Published var name = "World"
}

struct DetailView: View {
  // 父视图或外部注入
  @ObservedObject private var viewModel: VM
  // 或首次创建
  @StateObject private var createdVM: VM

  // custom init 必须配置包装器的底层存储
  init(viewModel: VM) {
    // 注意左侧下划线：访问包装器的底层存储
    _viewModel = ObservedObject(wrappedValue: viewModel)
    _createdVM = StateObject(wrappedValue: VM())
  }

  var body: some View {
    VStack {
      Text("Observed: \(viewModel.name)")
      Text("Created: \(createdVM.name)")
    }
  }
}
```

- **`@Binding` 示例**：

```swift
struct ToggleView: View {
  @Binding private var isOn: Bool

  init(isOn: Binding<Bool>) {
    _isOn = isOn
  }

  var body: some View {
    Toggle("Switch", isOn: $isOn)
  }
}
```

## 2.3`init` 中的限制与行为

1. **`body` 尚不可用**
    `init` 执行时 `body` 尚未构建，不要在 `init` 里触发视图渲染或依赖 `body` 属性。
2. **禁止在 `init` 中做副作用**
    避免在 `init` 中执行网络请求、定时器启动等副作用；应把这类逻辑放在 `onAppear` 或视图模型里。
3. **`@StateObject` 首次初始化**

- `@StateObject` 只能在视图的 `init` 中赋予初始值一次；后续视图重建时（如父视图刷新）不会重新初始化。

- 切记不要在视图的其它生命周期方法（如 `body`）中再次创建 `StateObject`，以免丢失状态。

# 3. for in

## 3.1 基本语法

```swift
for item in collection {
    // 执行操作
}

//或者我们在循环中并不关心索引,只是想循环若干次，那么就使用_来代替
for _ in 1..<5 {
    // 执行操作
}
```

------

## 3.1 遍历常见类型

### 3.1.1 遍历数组

```swift
let fruits = ["Apple", "Banana", "Cherry"]

for fruit in fruits {
    print("I like \(fruit)")
}
```

### 3.1.2 遍历区间（范围）

```swift
for i in 1...5 {
    print(i)  // 输出 1 到 5（闭区间）
}

for i in 1..<5 {
    print(i)  // 输出 1 到 4（半开区间）
}
```

> [!NOTE]
>
> 关于范围：
>
>  Swift 中的 `1...n` 这种写法，也叫**区间运算符（Range Operator）**，在 `for-in` 循环中经常使用。
>
> - `1...n`：闭区间运算符（Closed Range）,表示[1, n]
> - `1..<n`：半开区间运算符（Half-Open Range）,表示[1, n)
> - 逆序遍历: `(1...5).reversed()`

### 3.1.3 遍历字典

```swift
let scores = ["Alice": 90, "Bob": 85]

//有点类似于C++17中的结构化绑定的写法，只不过C++用的是[]
for (name, score) in scores {
    print("\(name): \(score)")
}
```

### 3.1.4 遍历并获取索引（`enumerated()`）

```swift
let names = ["Tom", "Jerry", "Spike"]

for (index, name) in names.enumerated() {
    print("\(index): \(name)")
}
```

------

## 3.2 控制语句搭配

### 3.2.1 使用 `where` 添加条件

```swift
for i in 1...10 where i % 2 == 0 {
    print(i)  // 输出偶数
}
```

### 3.2.2 使用 `break` 和 `continue`

```swift
for i in 1...5 {
    if i == 3 { continue }  // 跳过3
    if i == 5 { break }     // 提前终止
    print(i)
}
```

------

### 3.2.3 注意事项

- 循环变量默认为常量（`let`），不可修改：

  ```swift
  for n in numbers {
      n += 1  // ❌ 编译错误
  }
  ```

- 如需修改原数组，建议使用下标访问：

  ```swift
  for i in 0..<array.count {
      array[i] += 1
  }
  ```

------

### 3.2.4 小结表格

| 类型     | 示例                               | 说明             |
| -------- | ---------------------------------- | ---------------- |
| 数组     | `for x in arr`                     | 遍历元素         |
| 区间     | `for i in 1...n`                   | 闭/开区间        |
| 字典     | `for (k, v) in dict`               | 遍历键值对       |
| 索引+值  | `for (i, v) in arr.enumerated()`   | 同时获取索引和值 |
| 条件遍历 | `for i in 1...10 where i % 2 == 0` | 添加筛选条件     |

# 4. functions as types

在 SwiftUI 中，**“functions as types”** 是一个很重要的概念，尤其是在写 `ViewBuilder`、事件回调（例如 `.onTapGesture`）或自定义组件时。它体现的是 Swift 的**一等函数（first-class functions）**特性 —— 也就是说，函数本身就是一种类型，可以作为值传递、赋值、返回或存储。

🧠 一句话理解

> 在 SwiftUI 中，函数不仅能“被调用”，还能“被传递”或“存储”为类型使用。

## 4.1 函数作为类型的几种场景

### 4.1.1 **回调函数传参**

```swift
struct MyButton: View {
    let action: () -> Void  // 函数作为类型（无参数、无返回）

    var body: some View {
        Button("Tap Me", action: action)
    }
}

// 使用方式
MyButton {
    print("Button tapped!")
}
```

- `() -> Void` 是一个**函数类型**，表示无参无返回值。
- 可以把函数当作变量一样传进视图中。

------

### 4.1.2 **作为 ViewBuilder 的函数参数**

```swift
struct CardView<Content: View>: View {
    let content: () -> Content  // 函数类型：返回一个 View

    var body: some View {
        VStack {
            Text("Title")
            content()  // 调用函数，插入子视图
        }
    }
}

// 使用
CardView {
    Text("Hello")
}
```

这就是 SwiftUI 的声明式 UI：**子视图就是一个函数返回的 View 类型！**

------

### 4.1.3 **事件处理（onTap、gesture）**

```swift
Text("Tap me")
    .onTapGesture(perform: {
        print("Tapped")
    })
```

- 这里的 `perform:` 参数是一个 `() -> Void` 函数。
- 你可以传匿名函数（闭包），也可以传已有函数名。

------

## 4.1.4 函数类型的形式

| 函数签名               | 意义                   |
| ---------------------- | ---------------------- |
| `() -> Void`           | 无参无返回             |
| `(Int) -> String`      | 传入 Int，返回 String  |
| `() -> some View`      | 返回一个 SwiftUI 视图  |
| `@escaping () -> Void` | 函数逃逸，用于异步回调 |

------

## 4.1.5 SwiftUI 中 View 本质上也是函数调用链

SwiftUI 中写：

```swift
Text("Hi")
    .foregroundColor(.red)
```

本质是函数组合：

```swift
func foregroundColor(_ color: Color) -> some View
```

所以整个 `.modifier(...)` 等链式调用，都依赖于“函数作为类型”这一底层支持。

------

## 4.1.6 总结要点

- Swift 中函数是**一等类型**，可以像变量一样使用。
- SwiftUI 中大量用到 `() -> View` 类型构建视图树。
- 事件、回调、声明式组件传递都依赖于“函数类型”。
- 泛型和 `@ViewBuilder` 常用于约束这类函数。

# 5.闭包

## 5.1 什么是闭包（Closure）？

✅ 通俗解释：

> 闭包就是“一段可以被当作变量使用的函数代码”。

你可以像“值”一样，把它传给别人、存起来，或者作为参数传入另一个函数中。

---

🧩 为什么叫“闭包”？

闭包这个名字来自于它**“捕获”并“记住”其作用域内的变量** —— 就像一个函数“包住”了它定义时的上下文。

------

## 5.2 闭包的基本语法

```swift
let greet = {
    print("Hello")
}

greet()  // 调用闭包，输出：Hello
```

- `{ ... }` 是闭包体，和函数体很像。
- `greet` 是闭包变量，类型是 `() -> Void`，表示“无参无返回值的函数”。

------

### 5.2.1 带参数的闭包

```swift
let square = { (x: Int) -> Int in
    return x * x
}

let result = square(5)  // 输出 25
```

- `(x: Int) -> Int` 是闭包类型。
- `in` 把参数和闭包体分开。

------

### 5.2.2 闭包 vs 函数

| 项目       | 闭包                        | 函数                         |
| ---------- | --------------------------- | ---------------------------- |
| 语法       | `{ (param) -> Ret in ... }` | `func name(param) -> Ret {}` |
| 用途       | 传值、回调、构建视图等      | 定义具体逻辑单元             |
| 是否有名字 | 一般没有（也可以有）        | 一定有名字                   |

------

## 5.3 闭包的常见应用（SwiftUI 初学者常见场景）

### 5.3.1 **事件回调**

```swift
Button("Tap me") {
    print("Button clicked!")  // 这个就是闭包
}
```

### 5.3.2 **传入函数中**

```swift
func performTwice(action: () -> Void) {
    action()
    action()
}

performTwice {
    print("Doing it twice")
}
```

### 5.3.3 **构建 UI 视图（@ViewBuilder）**

```swift
VStack {
    Text("Line 1")
    Text("Line 2")
}
```

其实 `VStack {}` 括号中的内容就是一个返回 `View` 的闭包。

---

✅ 小结

- 闭包 = 可以当作变量传来传去的“函数代码块”
- 语法：`{ (参数) -> 返回类型 in 代码 }`
- SwiftUI 到处都在用闭包，比如构建 UI、处理按钮点击、响应变化等等

## 5.4 Swift 闭包的简写语法

Swift 提供了非常强大的**闭包语法简化能力**，常见于 SwiftUI、排序、过滤等场景。

✅ 简写 1：省略返回类型（类型可推断）

```swift
let double: (Int) -> Int = { x in
    return x * 2
}
```

✅ 简写 2：省略参数名，用 `$0`、`$1` 等表示

```swift
let double: (Int) -> Int = { $0 * 2 }

let sum: (Int, Int) -> Int = { $0 + $1 }

print(double(3))  // 输出 6
print(sum(3, 4))  // 输出 7
```

> [!NOTE]
>
> 这里看到`return`也被省略了，原因是闭包**只有一个表达式**，Swift 编译器就自动将那个表达式作为返回值。

---

🧪 应用例子：数组 map / filter

```swift
let numbers = [1, 2, 3]

// 用闭包把每个数 *2
let doubled = numbers.map { $0 * 2 }
print(doubled) // [2, 4, 6]

// 过滤出大于1的数
let filtered = numbers.filter { $0 > 1 }
print(filtered) // [2, 3]
```

- `map {}` 和 `filter {}` 都接受闭包作为参数。
- `$0` 是当前遍历的元素。

---

✅ 小结：闭包简写语法顺序

| 步骤           | 示例                         | 说明                     |
| -------------- | ---------------------------- | ------------------------ |
| 完整写法       | `{ (x: Int) -> Int in ... }` | 明确参数和返回类型       |
| 推断类型       | `{ x in ... }`               | 参数类型被类型系统推断   |
| 使用简写参数名 | `{ $0 + 1 }`                 | 用 `$0` 表示第一个参数   |
| 单表达式       | `{ $0 + 1 }` 无需 `return`   | Swift 自动返回表达式结果 |

## 5.5 闭包是如何“捕获值”的？

✅ 一句话理解：

> Swift 的闭包可以“记住”它**创建时上下文中的变量值**，即使这些变量的作用域已经消失。

这就是闭包名字的由来：**<u>“闭”住了上下文，“包”住了变量。</u>**

🧪 **示例一：最经典的捕获行为**

```swift
func makeCounter() -> () -> Int {
    var count = 0

    let counter = {
        count += 1
        return count
    }

    return counter
}

let c = makeCounter()

print(c())  // 1
print(c())  // 2
print(c())  // 3
```

> [!NOTE]
>
> - `count` 是 `makeCounter` 函数里的局部变量。
> - 闭包 `{ count += 1 }` 把它“捕获”了，**即使函数早就返回了，count 依然存在并可访问**。
> - 每次调用 `c()` 都在修改它“私有”的那份 `count`。
>
> 这就叫闭包捕获（Closure Capturing）。

---

🧪 示例二：多个闭包共享同一个上下文变量

```swift
func makeTwoCounters() -> (() -> Int, () -> Int) {
    var count = 0

    let increment = { () -> Int in
        count += 1
        return count
    }

    let report = { () -> Int in
        return count
    }

    return (increment, report)
}

let (inc, read) = makeTwoCounters()
print(inc())  // 1
print(inc())  // 2
print(read()) // 2 （共享变量）
```

两个闭包 **捕获了同一个变量**，它们共享状态！

---

✅ 闭包捕获变量的特点

| 特性           | 说明                                           |
| -------------- | ---------------------------------------------- |
| 持久性         | 被捕获的变量不会因为函数返回而销毁             |
| 引用语义       | 闭包对变量是“引用”而不是“拷贝”（除非显式处理） |
| 多闭包共享变量 | 多个闭包可共享同一捕获的变量                   |

---

📌 Swift 中常见的闭包捕获用法

1. **计数器（如上例）**
2. **异步回调（需要捕获某些状态）**
3. **SwiftUI 的动画或响应事件回调**
4. **GCD、Timer、URLSession 中使用 self 时注意捕获方式**

---

✅ 小结

- 闭包“包住”它创建时的变量环境，函数作用域结束后也能继续访问。
- 这是闭包最大的特性之一。
- 被捕获的变量其实是“引用捕获”，会被闭包持有。

------

## 5.6 闭包 + 状态（@State / @Binding）的常见模式

SwiftUI 中的视图是“声明式的 + 响应式的”，**状态改变会自动触发 UI 更新**。而闭包，正是负责**驱动状态改变、处理用户操作**的关键。

---

🎯 目标例子：计数器按钮

```swift
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
                .font(.largeTitle)

            Button("Tap Me") {
                // 这个闭包被触发后，count 状态会更新，UI 自动刷新
                count += 1
            }
        }
    }
}
```

> [!NOTE]
>
> ✅ 分析：
>
> - `@State` 是一个**源状态**，`count` 是 UI 的数据来源。
> - `Button {}` 中的闭包负责**更改状态**。
> - SwiftUI 自动追踪这个状态，**状态变 → UI 自动变**。

---

🔁 **模式 1：闭包响应状态更新**

🧪 示例：切换开关

```swift
@State private var isOn = false

Toggle("Enable feature", isOn: $isOn)
//$isOn 是绑定（Binding<Bool>），它把对 isOn 的读写操作封装起来，传给 Toggle 控件。
//当开关切换时，Toggle 会通过这个 Binding 自动更新 isOn。
//当 isOn 变化时，界面也会自动刷新。
```

- 这个 `Toggle` 会自动绑定 `isOn` 状态。
- 你也可以加入闭包响应状态变化：

```swift
Toggle("Enable", isOn: $isOn)
    .onChange(of: isOn) { newValue in
        print("Switch changed: \(newValue)")
    }
```

- `onChange` 接收一个闭包 `(T) -> Void`，在状态变更时调用。

---

🔄 **模式 2：父子组件通信用闭包 + @Binding**

✅ 目标：点击子视图按钮，让父视图的计数器增加

🔧 子视图：

```swift
struct ChildView: View {
    let onTap: () -> Void  // 闭包作为参数

    var body: some View {
        Button("Child Tap", action: onTap)
    }
}
```

🧩 父视图：

```swift
struct ParentView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
            ChildView {
                count += 1  // 闭包捕获父视图状态
            }
        }
    }
}
```

🧠 总结：

- 子视图通过闭包 `onTap` 通知父视图。
- 父视图通过 `@State` 持有状态并在闭包中修改它。
- 这是 SwiftUI **单向数据流 + 闭包回调机制**的体现。

---

📦 模式 3：@Binding + 闭包做表单交互组件

```swift
struct LabeledToggle: View {
    @Binding var isOn: Bool  // 由父视图提供状态

    var body: some View {
        Toggle("Enabled", isOn: $isOn)
    }
}
```

在父视图中这样使用：

```swift
@State private var active = false

LabeledToggle(isOn: $active)
```

- 这里没有显式闭包，但其实**`$isOn` 就是一个双向绑定的“状态驱动型闭包”**。
- 你可以想象它像这样工作：

```swift
Toggle("...", isOn: Binding(
    get: { active },
    set: { active = $0 }
))
```

---

✅ 小结：闭包 + 状态模式对照表

| 场景             | 使用方式                       | 本质                |
| ---------------- | ------------------------------ | ------------------- |
| 点击按钮更新状态 | `Button { count += 1 }`        | 闭包捕获 @State     |
| 状态变更响应     | `.onChange(of: var) { ... }`   | 闭包监听状态        |
| 子传父回调       | `ChildView(onTap: { ... })`    | 闭包回调 + 状态驱动 |
| 组件绑定         | `@Binding var isOn` + `$value` | 双向状态驱动        |

------

好的，我们继续进入 SwiftUI 中闭包学习的第 5 部分，这部分将引入一个非常重要但常被忽略的实践主题：

------

## 5.7`@escaping` 和异步闭包在 SwiftUI 中的角色

✅ 一句话理解

> 在 SwiftUI 中，所有**延迟执行、异步触发或持久保存的闭包**都必须标注为 `@escaping`，这是确保闭包在作用域外仍然有效的关键。

而 SwiftUI + async/await 的结合，也需要闭包支持异步结构。

---

🔍 回顾：什么是 `@escaping`

在 Swift 中，默认闭包是 **非逃逸（non-escaping）** —— 也就是说必须在函数体内被调用完。

**而 `@escaping` 表示：这个闭包可能在函数返回之后才会被调用。**

---

场景 1：异步请求（如网络请求）

```swift
func loadData(completion: @escaping (String) -> Void) {
    DispatchQueue.global().async {
        // 模拟异步任务
        sleep(1)
        DispatchQueue.main.async {
            completion("Loaded result")
        }
    }
}
```

调用：

```swift
loadData { result in
    print("Result is \(result)")
}
```

- 闭包作为回调函数，要等异步操作完成后再调用，所以必须是 `@escaping`。

---

**场景 2：SwiftUI 中异步任务配合闭包更新状态**

```swift
struct AsyncExample: View {
    @State private var message = "Loading..."

    var body: some View {
        VStack {
            Text(message)
            Button("Load") {
                loadData { result in
                    message = result
                }
            }
        }
    }
}
```

> [!NOTE]
>
> - `loadData` 是一个接受 `@escaping` 闭包的异步函数。
> - SwiftUI 中的 `@State` 被闭包捕获后，更新状态会自动刷新 UI。

---

✅ 进阶：SwiftUI + async/await

从 Swift 5.5 开始，你可以用 `async` 和 `await` 写更清晰的异步逻辑，配合 SwiftUI 的 `.task` 或 `Button`：

🔧 示例：

```swift
struct AsyncAwaitExample: View {
    @State private var message = "Loading..."

    var body: some View {
        VStack {
            Text(message)

            Button("Fetch") {
                Task {
                    message = await fetchData()
                }
            }
        }
    }

    func fetchData() async -> String {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return "Async result"
    }
}
```

> [!NOTE]
>
> - `Task {}` 是一个自动逃逸的异步环境（相当于 GCD）。
> - 闭包内部可以写 `await`。
> - 你无需显式写 `@escaping`，因为 `Task` 本身持有闭包。

---

✅ 闭包 + @escaping + @MainActor 常见组合

```swift
func asyncWork(completion: @escaping (String) -> Void) {
    Task {
        let result = await fetchData()
        await MainActor.run {
            completion(result)
        }
    }
}
```

- 在后台执行异步任务
- 回到主线程通过 `@MainActor` 调用闭包更新 UI

---

✅ 小结

| 场景              | 是否需要 `@escaping` | 示例                               |
| ----------------- | -------------------- | ---------------------------------- |
| 异步请求回调      | ✅ 是                 | `completion: @escaping () -> Void` |
| SwiftUI 的 Button | ❌ 否（立即调用）     | `Button {}`                        |
| Task 内异步闭包   | ✅ 自动逃逸           | `Task { await ... }`               |
| 网络或后台任务    | ✅ 是                 | `URLSession`, `DispatchQueue` 等   |

> [!NOTE]
>
> - 在 SwiftUI 中，大多数闭包是非逃逸的，除非你进入异步、后台、回调等场景。
> - 使用 `@escaping` 的函数通常与你的状态更新有关，所以要注意闭包捕获 `@State` 或 `@Binding` 的方式，避免内存泄漏。

# 6.static vars and func

在 Swift（包括 SwiftUI）中，用 `static` 修饰的属性和方法都是“类型级”（type-level）的，而不是“实例级”（instance-level）的。它们的主要特点和常见用法包括：

------

### 6.1 `static` 属性（静态变量／常量）

- **定义方式**

  ```swift
  struct ContentView: View {
      // 存储型静态常量
      static let defaultTitle: String = "欢迎"
      
      // 计算型静态属性
      static var defaultColor: Color {
          return .blue.opacity(0.8)
      }
      
      var body: some View {
          Text(Self.defaultTitle)
              .foregroundColor(Self.defaultColor)
      }
  }
  ```

- **特点**

  1. **与实例无关**：不需要创建 `ContentView()` 实例，就可以直接通过 `ContentView.defaultTitle` 访问。
  2. **共享**：在所有实例中只有一份存储或计算逻辑，可用于缓存重用，比如 `NumberFormatter`、`DateFormatter`、自定义样式等。
  3. **延迟初始化**：存储型 `static` 属性在首次访问时才会创建（thread-safe）。

------

### 6.2 `static` 方法（静态函数）

- **定义方式**

  ```swift
  struct ContentView: View {
      static func greeting(for name: String) -> String {
          "Hello, \(name)!"
      }
      
      var body: some View {
          Text(Self.greeting(for: "SwiftUI"))
      }
  }
  ```

- **用途**

  - 编写与实例无关的“工具函数”或“工厂方法”。
  - 在 `View` 中作为辅助逻辑，避免在 `body` 中出现复杂计算。

------

### 6.3 与 `class` 的区别

- `static` 只能用于**值类型**（如 `struct`、`enum`）或 `class` 的“不可重写”成员。
- `class` 方法或属性可以在子类中用 `override` 重写；而 `static` 则不允许重写。

------

### 6.4 SwiftUI 特殊用例：预览提供者

```swift
struct ContentView_Previews: PreviewProvider {
    // SwiftUI 要求：必须是 static var
    static var previews: some View {
        ContentView()
            .previewLayout(.sizeThatFits)
    }
}
```

- `PreviewProvider` 协议要求提供一个 `static var previews`，用来在 Xcode 画布中渲染多组预览。

------

### 6.5 使用建议

1. **常量、共享资源**：将不随实例变化的配置、样式、Formatter 等放进 `static let`。
2. **辅助函数**：与视图实例状态无关的纯函数可声明为 `static func`。
3. **命名空间**：可利用 `struct` + `static` 对一组相关常量／方法进行逻辑分组。

# 7.semantic rename 

在Xcode中我们如果想对一个接口或者类型进行修改命名的话，如果我们直接手动修改会比较麻烦，并且会导致修改错误；

这时候我们就可以借Xcode提供的修改接口来完成我们的修改操作：

- Step1：选择你要修改类型名右键之后选择refactor->rename

![Lecture4-1](/Users/qingyangmi/learn/iOS/Note/image/Lecture4-1.png)

- Step2: 在输入框里写入修改后的名称，然后点击rename 就好了！

![Lecture4-2](/Users/qingyangmi/learn/iOS/Note/image/Lecture4-2.png)

# 8.mutating

在 Swift 里，`mutating` 是一个修饰符，用在**值类型**（`struct` 或 `enum`）的方法前，表示这个方法会修改它自身（`self`）或它的属性。因为值类型默认方法不能改变自己（以保证值语义），加上 `mutating` 后，编译器才允许你在方法里写诸如 `self.count += 1` 之类的操作。

------

## 8.1为什么需要 `mutating`

- **值类型不可变性**
   默认情况下，`struct`/`enum` 的方法里不允许修改它们的存储属性：

  ```swift
  struct Point {
      var x: Double, y: Double
  
      func moveBy(dx: Double, dy: Double) {
          // x += dx   // ❌ 编译错误：Cannot assign to property: 'self' is immutable
      }
  }
  ```

- **加上 `mutating` 后就行了**

  ```swift
  struct Point {
      var x: Double, y: Double
  
      mutating func moveBy(dx: Double, dy: Double) {
          x += dx    // ✅
          y += dy
      }
  }
  ```

------

## 8.2 在 SwiftUI 中的典型用法

虽然 SwiftUI 的 `View` 本身也是一个 `struct`，但你几乎不会在自定义的 `View` 上直接写 `mutating func`；而是通过**属性包装器**（如 `@State`、`@Binding`）来管理可变状态。比如：

```swift
struct CounterView: View {
    // 这是一个引用类型的“盒子”，底层帮你做了 mutating
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1   // 不用自己写 mutating
            }
        }
    }
}
```

如果你要在 **独立的模型类型**（非 View）里封装修改逻辑，就要用 `mutating`：

```swift
// 只是一个纯值类型模型，它会被 @State 或 @ObservedObject 持有
struct Counter {
    var value = 0

    mutating func increment() {
        value += 1
    }
}

struct CounterView: View {
    @State private var counter = Counter()

    var body: some View {
        VStack {
            Text("Value: \(counter.value)")
            Button("＋") {
                counter.increment()  // 调用的是 mutating 方法
            }
        }
    }
}
```

------

## 8.3 何时在 SwiftUI 里真正用到 `mutating`

1. **自定义业务模型**（纯 Swift 结构体）
   - 将可变逻辑封装在模型内部，用 `mutating` 标记。
   - 通过 `@State`、`@Binding` 或 `@ObservedObject` 在 View 中引用模型实例。
2. **扩展值类型**
   - 例如给自定义 `Shape`、`Layout`、`PreferenceKey` 等结构体添加修改自身状态的方法。
3. **协议实现里需要修改自身**
   - 某些协议（如自定义的协议）要求方法能改变结构体属性，就要在方法签名前加 `mutating`。

------

## 8.4 小结

- **Swift 语言层面**：`mutating` 让值类型方法能够改变 `self`。
- **SwiftUI 层面**：大多数状态变化都是通过属性包装器来实现，你很少在 `View` 上直接写 `mutating`。
- **最佳实践**：如果模型本身是值类型，而且你想把修改逻辑封装进去，别忘了在方法前加 `mutating`；在 View 里就直接调用模型方法或操作 `@State`／`@Binding` 即可。

# 9.Swift中的状态管理

## 9.1 核心理念

- **声明式＋响应式**：UI 声明“我想展示什么”，状态改变后自动“重绘”界面。
- **单一真相**（Single Source of Truth）：状态（State）是唯一可靠的数据源，所有 UI 都从它派生。
- **响应式更新流程**：
  1. **状态改变**（@State、@Published…）
  2. **Publisher 发事件**
  3. **SwiftUI 标记失效**
  4. **重新执行 `body`**
  5. **diff & 渲染**（只是更新必要部分）

------

## 9.2 属性包装器详解

下面以**定义 → 具体代码示例 → 数据流通 → 应用场景**四步来展开讲解。

------

### 1. @State

- **定义**：在单个 View 内部管理私有、可变的值类型状态。

- **示例**：

  ```swift
  struct CounterView: View {
      @State private var count: Int = 0
  
      var body: some View {
          VStack {
              Text("Count: \(count)")
              Button("＋1") { count += 1 }
          }
          .padding()
      }
  }
  ```

- **数据流通**：

  1. `count += 1` → 写入内部“状态槽”
  2. `@State` 底层是 Combine Publisher，发出新值事件
  3. SwiftUI 标记该 View 失效 → 下一帧调用 `body`
  4. diff 新旧视图 → 最小化更新

- **应用场景**：

  - **局部、轻量**：开关、计数器、TextField 文本内容等，仅限当前 View 使用的状态。

------

### 2. @Binding

- **定义**：在父–子 View 间建立双向引用，子 View 可以读写父 View 的 `@State`。

- **示例**：

  ```swift
  // 父 View
  struct ParentView: View {
      @State private var isOn = false
  
      var body: some View {
          ToggleView(isOn: $isOn)
      }
  }
  
  // 子 View
  struct ToggleView: View {
      @Binding var isOn: Bool
  
      var body: some View {
          Toggle("开关", isOn: $isOn)
              .padding()
      }
  }
  ```

- **数据流通**：

  1. 子 View 调用 `isOn.toggle()`
  2. 实际修改父 View 的 `@State isOn` → 触发 `@State` 流程
  3. 父 View 重算 `body`，通过 `$isOn` 传回最新值给子 View

- **应用场景**：

  - **组件化**：当你拆分 View，希望子组件既能读取又能修改父组件的状态时。

------

### 3. @StateObject

- **定义**：用于在 View **首次**创建时初始化并持有一个 `ObservableObject`，负责其生命周期。

- **示例**：

  ```swift
  final class TimerModel: ObservableObject {
      @Published var seconds = 0
      private var timer: Timer?
  
      init() {
          timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
              self.seconds += 1
          }
      }
  }
  
  struct TimerView: View {
      @StateObject private var model = TimerModel()
  
      var body: some View {
          Text("Time: \(model.seconds)s")
              .font(.largeTitle)
      }
  }
  ```

- **数据流通**：

  1. `model.seconds += 1` → `@Published` 发事件
  2. SwiftUI 捕获事件 → 标记 `TimerView` 失效
  3. 重算 `body` → 更新显示

- **应用场景**：

  - **View 自有的复杂状态**，如网络请求结果、定时器、音视频播放器等只由该 View 管理的对象。

------

### 4. @ObservedObject

- **定义**：用于订阅外部传入的 `ObservableObject`，监听其 `@Published` 属性。

- **示例**：

  ```swift
  final class Settings: ObservableObject {
      @Published var username: String = ""
  }
  
  struct ProfileView: View {
      @ObservedObject var settings: Settings
  
      var body: some View {
          VStack {
              TextField("用户名", text: $settings.username)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
              Text("Hello, \(settings.username)")
          }
          .padding()
      }
  }
  
  // 使用时由父 View 或环境传入
  struct Container: View {
      @StateObject private var settings = Settings()
      var body: some View { ProfileView(settings: settings) }
  }
  ```

- **数据流通**：

  1. 外部某处 `settings.username = "新名"` → `@Published` 发事件
  2. SwiftUI 标记 `ProfileView` 失效 → 重算 `body` → 更新界面

- **应用场景**：

  - **共享状态**：多个子 View 需要订阅同一个模型，但模型的生命周期由外部管理时。

------

### 5. @EnvironmentObject

- **定义**：在环境中全局注入并共享的 `ObservableObject`，可跨多层 View 访问。

- **示例**：

  ```swift
  @main
  struct MyApp: App {
      @StateObject private var userData = UserData()
  
      var body: some Scene {
          WindowGroup {
              ContentView()
                  .environmentObject(userData)
          }
      }
  }
  
  struct ContentView: View {
      var body: some View {
          VStack {
              ProfileView()      // 及其子 View 均能访问 userData
              DashboardView()
          }
      }
  }
  
  struct ProfileView: View {
      @EnvironmentObject var userData: UserData
      var body: some View { Text("User: \(userData.name)") }
  }
  ```

- **数据流通**：

  1. 任意层级调用 `userData.name = "新名"` → `@Published` 发事件
  2. 所有订阅该对象的 View 都失效 → 各自重算 `body` → 更新

- **应用场景**：

  - **跨模块共享**：用户设置、全局主题、购物车数据等需要在 App 多处访问的全局状态。

------

### 6. @Environment

- **定义**：读取系统或自定义的环境值（如配色方案、字体、布局方向等）。

- **示例**：

  ```swift
  struct ThemedView: View {
      @Environment(\.colorScheme) var colorScheme
      var body: some View {
          Text("当前模式：\(colorScheme == .dark ? "深色" : "浅色")")
              .padding()
      }
  }
  ```

- **数据流通**：

  1. 系统或父 View 修改环境值（如 Light ↔ Dark）
  2. 对应 `@Environment` 自动发事件
  3. 依赖该环境值的 View 失效 → 重算 `body` → 更新

- **应用场景**：

  - **响应系统变化**：自动适配深浅色模式、动态字体大小、本地化区域等。

------

## 9.3 完整数据流动流程

1. **修改状态**（`@State`、`@Published`、环境值…）
2. **Publisher 发事件**（Combine）
3. **SwiftUI 标记失效**（invalidate）
4. **重新执行 `body`**（body engine）
5. **Diff & 渲染**（最小化 UI 更新）

------

## 9.4 选用指南与实践

| 场景                                                    | 属性包装器           |
| ------------------------------------------------------- | -------------------- |
| **仅在当前 View 内简单变化**                            | `@State`             |
| **父–子组件需双向读写同一状态**                         | `@Binding`           |
| **View 首次创建并拥有需在 View 生命周期内持有复杂对象** | `@ObservableObject`  |
| **外部创建、由多个 View 订阅的 ObservableObject**       | `@ObservedObject`    |
| **跨多层级、全局共享的 ObservableObject**               | `@EnvironmentObject` |
| **读取系统或自定义环境配置**                            | `@Environment`       |

> **最佳实践**：
>
> 1. 明确“状态拥有者”（Owner）与“状态订阅者”（Subscriber）。
> 2. 保持状态最小化——不必要不要提升到全局，减少不必要的刷新。
> 3. 善用属性包装器组合（如 `@State` + `@Binding`），提高组件复用性和可测试性。
