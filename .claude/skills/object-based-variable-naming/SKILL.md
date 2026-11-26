---
name: object-based-variable-naming
description: Enforces object-based variable naming conventions. Variables should use their corresponding class, Model, DTO, or object names as their base names. When naming conflicts occur, prepend meaningful contextual qualifiers while preserving the original object name at the end. Use when creating, modifying, reviewing, or refactoring variables.
---

# Object-Based Variable Naming Convention

## Objective

Always name variables based on their corresponding object, class, Model, or DTO names.

The variable name should clearly communicate which object it represents without requiring developers to inspect its type declaration.

**Primary principle:**

Use the object name as the variable name whenever possible.

When multiple variables represent objects of the same type, prepend a meaningful contextual qualifier and preserve the original object name at the end.

## 1. Standard Naming Rules

When there is no naming conflict, use the object's class name converted to camelCase.

**Preferred:**

```java
Record record = new Record();
User user = new User();
UserDto userDto = new UserDto();
OrderModel orderModel = new OrderModel();
ProductResponse productResponse = new ProductResponse();
```

**Avoid:**

```java
Record data = new Record();
User obj = new User();
UserDto dto = new UserDto();
OrderModel model = new OrderModel();
ProductResponse response = new ProductResponse();
```

Do not use generic variable names such as:
- data
- obj
- object
- dto
- model
- entity
- result
- item
- temp

Unless the name genuinely describes a different concept and is appropriate for the context.

## 2. Handling Naming Conflicts

When multiple variables have the same object type, prepend a meaningful contextual qualifier.

The variable name MUST end with the original object name.

**Example:**

```java
Record newRecord = new Record();
Record oldRecord = new Record();
```

Other examples:

```java
User currentUser = new User();
User previousUser = new User();

Order pendingOrder = new Order();
Order completedOrder = new Order();

UserDto requestUserDto = new UserDto();
UserDto responseUserDto = new UserDto();

OrderModel sourceOrderModel = new OrderModel();
OrderModel targetOrderModel = new OrderModel();
```

### Naming pattern

```text
[meaningfulQualifier][ObjectName]
```

Where:
- `meaningfulQualifier` describes the object's role, state, purpose, or origin.
- `ObjectName` is the original object's name converted to camelCase.
- The complete variable name must follow the project's naming conventions.

## 3. Choosing Meaningful Qualifiers

Choose qualifiers based on the actual purpose of the object.

Prefer the following contextual meanings:

| Context | Example |
|---|---|
| New object | `newRecord` |
| Existing object | `existingRecord` |
| Old object | `oldRecord` |
| Previous object | `previousRecord` |
| Current object | `currentRecord` |
| Original object | `originalRecord` |
| Updated object | `updatedRecord` |
| Source object | `sourceRecord` |
| Target object | `targetRecord` |
| Request object | `requestUserDto` |
| Response object | `responseUserDto` |
| Database object | `databaseUser` |
| Cached object | `cachedUser` |

Do not use arbitrary prefixes merely to make variable names different.

The qualifier must describe the actual role or meaning of the object.

## 4. Special Attention to Model and DTO Names

Model and DTO names must be preserved in variable names.

For example:

```java
UserDto userDto = new UserDto();
UserDto requestUserDto = new UserDto();
UserDto responseUserDto = new UserDto();

UserModel userModel = new UserModel();
UserModel sourceUserModel = new UserModel();
UserModel targetUserModel = new UserModel();
```

**Important:**

Never remove `Dto`, `Model`, `Entity`, `Request`, or `Response` from the variable name when these suffixes are part of the class name.

Avoid:

```java
UserDto user = new UserDto();
UserModel user = new UserModel();
```

Prefer:

```java
UserDto userDto = new UserDto();
UserModel userModel = new UserModel();
```

This makes the variable's type and purpose immediately recognizable.

## 5. Multiple Objects with Different Types

When objects have different types, use their respective object names without unnecessary qualifiers.

Preferred:

```java
User user = new User();
UserDto userDto = new UserDto();
UserModel userModel = new UserModel();
Order order = new Order();
OrderDto orderDto = new OrderDto();
```

Avoid unnecessary prefixes:

```java
User currentUser = new User();
UserDto currentUserDto = new UserDto();
UserModel currentUserModel = new UserModel();
Order currentOrder = new Order();
OrderDto currentOrderDto = new OrderDto();
```

Only introduce qualifiers when they provide meaningful context or resolve an actual naming conflict.

## 6. Collections and Lists

For collections, preserve the object name and use its plural form when appropriate.

Preferred:

```java
List<User> users = new ArrayList<>();
List<UserDto> userDtos = new ArrayList<>();
List<OrderModel> orderModels = new ArrayList<>();
```

When multiple collections contain the same object type, add meaningful qualifiers:

```java
List<User> activeUsers = new ArrayList<>();
List<User> inactiveUsers = new ArrayList<>();

List<OrderDto> requestOrderDtos = new ArrayList<>();
List<OrderDto> responseOrderDtos = new ArrayList<>();
```

## 7. Apply Consistently Across the Codebase

Apply this convention whenever:

- Declaring local variables.
- Declaring method parameters.
- Declaring class fields.
- Creating new Model or DTO instances.
- Assigning objects returned from methods.
- Receiving objects from database queries.
- Mapping between DTOs and Models.
- Creating temporary objects.
- Refactoring existing variable declarations.

Examples:

```java
UserDto requestUserDto = getRequestUserDto();

UserModel userModel = userMapper.toModel(requestUserDto);

UserModel existingUserModel = userRepository.findById(userModel.getId());

UserDto responseUserDto = userMapper.toDto(existingUserModel);
```

## 8. Conflict Resolution Priority

When choosing a variable name, follow this priority:

1. Identify the actual object or class name.
2. Convert the object name to the appropriate variable naming convention.
3. Check whether another variable already uses the same name within the relevant scope.
4. If there is no conflict, use the object name directly.
5. If there is a conflict, prepend a meaningful qualifier.
6. Ensure the variable name ends with the original object name.
7. Check that the qualifier describes the object's actual purpose.

## 9. Important Restrictions

- Do not rename classes or change object types just to satisfy this naming convention.
- Do not introduce meaningless prefixes or suffixes.
- Do not abbreviate Model or DTO names.
- Do not use generic names when the actual object name is available.
- Do not add qualifiers when there is no naming conflict or meaningful contextual reason.
- Preserve existing project naming conventions and language-specific casing.
- Do not sacrifice readability to follow the rule mechanically.
- If a meaningful variable name cannot be determined, use the closest descriptive name that preserves the object name.

## 10. Final Expected Behavior

Whenever generating or modifying code, Claude Code MUST prioritize object-based variable naming.

**Example A: No conflict**

```java
Record record = new Record();
UserDto userDto = new UserDto();
OrderModel orderModel = new OrderModel();
```

**Example B: Naming conflict**

```java
Record newRecord = new Record();
Record oldRecord = new Record();

UserDto requestUserDto = new UserDto();
UserDto responseUserDto = new UserDto();
```

**Example C: Multiple objects with different purposes**

```java
UserModel sourceUserModel = new UserModel();
UserModel targetUserModel = new UserModel();

OrderDto requestOrderDto = new OrderDto();
OrderDto responseOrderDto = new OrderDto();

List<User> activeUsers = new ArrayList<>();
List<User> inactiveUsers = new ArrayList<>();
```

**Final rule:**

Always use the original object name as the foundation of the variable name. When a conflict exists, prepend a meaningful qualifier rather than replacing or abbreviating the object name.

The object name must remain recognizable and appear at the end of the variable name.

## Dart / Flutter notes for this project

- Class names with a trailing underscore keep their base name: `Record_ record`, `List<Record_> records`.
- Private fields keep the leading underscore: `_recordFormModel`, `_transactionCategories`.
- Widget fields and constructor parameters are variables too: a field of type `TransactionCategory` is `transactionCategory`, not `category`.
- Lambda parameters follow the same rule: `.where((transactionCategory) => ...)`, not `(c) => ...`.
- Loop indexes and primitive values (`int index`, `double amount`, `String keyword`) are not objects and keep descriptive names.
