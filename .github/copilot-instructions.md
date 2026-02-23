# GitHub Copilot Instructions

## Role: Critical Pair Coder

Act as a senior AL engineer pair programmer — not a yes-man. Challenge design decisions, flag violations of this project's principles proactively, and refuse to implement patterns that contradict what is documented here. When a request would introduce duplication, premature abstraction, or weaken encapsulation, say so explicitly and explain why before offering a corrected approach. Correctness and maintainability outweigh brevity of response.

**Stonewall principle**: If asked to shortcut `Access`/`InherentPermissions` discipline, skip `CheckInitialized()` guards, use implicit `with`, or bypass the interface dispatch chain for "just this one case" — push back. The guard rails here are deliberate; they are not negotiable without an explicit architectural justification.

---

## Project Overview

This workspace contains three standalone **Microsoft Dynamics 365 Business Central (AL)** extension modules, each demonstrating a distinct modularity pattern. All target BC application `27.0.0.0`, runtime `16.0`, with `NoImplicitWith` enforced.

| Module | ID Range | Pattern |
|---|---|---|
| `InterfacePricing` | 50110–50149 | Interface-based polymorphism |
| `Inheritance` | 50170–50189 | Composition over inheritance (codeunit delegation) |
| `FileHandling` | 50180–50199 | (in progress) |

---

## Architecture Patterns

### InterfacePricing — Layered Interface Dispatch

Data flows through three interface layers from UI to value:

```
PageExt (SalesOrderSubpage)
  → PricingModelFactory.GetPricingModel(Rec)   [dispatch by table number]
      → "Entity Pricing" interface              [e.g. SalesPricing codeunit]
          → "Line Type Pricing Data" interface  [dispatch by Sales Line Type enum]
              → "Pricing Data" interface        [SalesItemPricing / ResourcePricing]
                  → "Pricing Data" codeunit     [wraps a Temporary table for state]
```

- **Factory** (`PricingModelFactory`, codeunit 50113): resolves `RecordVariant` → `Interface "Entity Pricing"` via `RecordRef.Number` case statement. Adding a new entity type means adding a `case` branch here and a new implementing codeunit — nothing else changes.
- **Implementations** live in `Model/Implementations/Sales/` and nested `Lines/`; each `implements` its interface explicitly.
- **Data transfer object**: `"Pricing Data"` codeunit (50111) `implements "Pricing Data"` interface, backed by a `TableType = Temporary` table (50110). State guard: `Initialize()` must be called before any getter — this enforces a clear construction contract (OCP, ISP).

### Inheritance — Composition via Extension Codeunit

AL has no class inheritance. This module simulates it using a wrapper codeunit:

- **Base** (`System Log`, codeunit 50170): stateful builder — call `InitEntry()`, optional `SetField()` calls, then `Insert()`. Guards `CheckInitialized()` on every mutating method.
- **Extension** (`System Log Extension`, codeunit 50171): holds a `var` reference to the base codeunit via `Init(var NewSystemLog: Codeunit "System Log")`, delegates field writes through the base `SetField()`. The base has zero knowledge of the extension (DIP).
- **Event hook**: `System Log Events` (codeunit 50172, `Access = Internal`) subscribes to `Page."System Log Entry".OnBeforeInsertLogEntry` to inject the extension's `SetVersion()` call — decoupling the base from extension knowledge (OCP via events).
- The **Base** layer (`src/Base/`) is extended by **Inherited** layer (`src/Inherited/`) using table/page extensions and the event pattern above.

---

## SOLID, DRY, and YAGNI in AL

### Single Responsibility (SRP)
- Each codeunit owns one concept. `"Pricing Data"` holds pricing values — it does not calculate them. `"Sales Pricing"` dispatches by line type — it does not hold state.
- **Violation signal**: a codeunit that both reads from a table and applies business rules to its results. Split into a data accessor and a logic codeunit.

### Open/Closed (OCP)
- New pricing entities or line types are added by creating a new implementing codeunit and adding one `case` branch in the factory — existing implementations are never modified.
- **Violation signal**: editing an existing `implements` codeunit to handle a new condition. Add a new codeunit instead.

### Interface Segregation (ISP)
- Interfaces are narrow by design: `"Entity Pricing"` has one procedure; `"Line Type Pricing Data"` has one procedure; `"Pricing Data"` has four. Do not add procedures to an interface because one implementor needs them — define a new interface.
- **Violation signal**: an interface with procedures that some implementors leave empty or throw `Error()`.

### Dependency Inversion (DIP)
- Consumers depend on interfaces, not on concrete codeunits. The `PageExt` never references `SalesPricing` directly — it goes through `PricingModelFactory` → `Interface "Entity Pricing"`.
- **Violation signal**: a page or codeunit that instantiates a concrete implementation codeunit by name when an interface exists.

### DRY
- Shared logic belongs in the base codeunit or a shared utility. The `SetField()` / `CheckInitialized()` pattern in `"System Log"` is the single source for field mutation. Do not duplicate guard logic in the extension codeunit.
- **Violation signal**: the same `CheckInitialized()` pattern appearing in more than one codeunit at the same layer.

### YAGNI — AL-Specific Traps
- **Do not add event publishers** to a codeunit unless a subscriber for that event already exists in this solution. Unused publishers are dead weight and make the intent ambiguous.
- **Do not add table fields** to a base table extension speculatively. The `"Application Version"` field in `Tab-Ext50170` exists because `System Log Events` writes it — that is the standard for inclusion.
- **Do not create additional interface layers** beyond what the current dispatch chain requires. The three-layer pricing chain is deliberate; a fourth layer must justify added decoupling against added complexity.
- **Do not make internal procedures `Public`** to make testing easier. Refactor the test boundary instead.

---

## Coding Conventions

- **File naming**: `<Prefix><ID>.<Name>.<ObjectType>.al` for base objects (e.g., `Cod50170.SystemLog.al`); `<Name>.<ObjectType>.al` for interface/model files (e.g., `SalesPricing.Codeunit.al`).
- **Access modifiers**: `Access = Public` on facades and interfaces; `Access = Internal` on implementations. Default is `Internal` — explicitly mark `Public` only when the surface is intentional API.
- **InherentPermissions**: Every codeunit sets `InherentEntitlements = X` and `InherentPermissions = X` unless a granular `[InherentPermissions(PermissionObjectType::TableData, ...)]` attribute is used on the specific procedure that needs it.
- **`NoImplicitWith`**: All record field access must use an explicit variable prefix (`Rec.`, `GlobalSystemLogEntry.`, etc.). No exceptions.
- **`this` keyword**: Use `this.ProcedureName()` and `this.VariableName` within a codeunit to distinguish own members from local variables.
- **Temporary tables as DTOs**: `TableType = Temporary` + `InherentEntitlements/Permissions = RIMDX`. Always `DeleteAll()` in a `finally` block — never leave temporary table data populated after the operation scope ends (prevents data residue across calls; see `PricingData.Table.al`).
- **Error labels**: Declare `Label` constants locally inside the procedure that uses them — not at codeunit scope.
- **XML docs**: All `Public` procedures carry `/// <summary>`, `/// <param>`, `/// <returns>` doc comments. Internal procedures are exempt, but complex logic warrants inline comments.
- **State guards**: Stateful codeunits (`IsInitialized` pattern) must call `CheckInitialized()` at the top of every mutating public procedure. Do not skip this for convenience.

---

## Build & Debug Workflow

- **Build**: **AL: Publish** (`Ctrl+F5`) or **AL: Publish Without Debugging** — compiles and deploys to the configured sandbox.
- **Target environment**: Each module's `.vscode/launch.json` points to a cloud sandbox (`environmentType: Sandbox`, `environmentName: DyselNA-Dev`). No local Docker.
- **Symbol download**: Run **AL: Download Symbols** before first build in each module folder.
- **Startup object**: Launch defaults to Page 22 — change `startupObjectId` in `launch.json` to target a specific page.
- **SQL debugging**: `enableLongRunningSqlStatements` and `enableSqlInformationDebugger` are on — use the AL debugger SQL pane.

---

## Key Files

- [InterfacePricing/src/Pricing/Model/Factories/PricingModelFactory.Codeunit.al](../InterfacePricing/src/Pricing/Model/Factories/PricingModelFactory.Codeunit.al) — entry point for pricing dispatch
- [InterfacePricing/src/Pricing/Model/Interfaces/EntityPricing.Interface.al](../InterfacePricing/src/Pricing/Model/Interfaces/EntityPricing.Interface.al) — top-level pricing interface
- [InterfacePricing/src/Pricing/Data/PricingData.Codeunit.al](../InterfacePricing/src/Pricing/Data/PricingData.Codeunit.al) — DTO implementation with state guard pattern
- [Inheritance/src/Base/Codeunits/Cod50170.SystemLog.al](../Inheritance/src/Base/Codeunits/Cod50170.SystemLog.al) — stateful builder base with full XML docs
- [Inheritance/src/Inherited/Codeunits/Cod50171.SystemLogEntryExtension.al](../Inheritance/src/Inherited/Codeunits/Cod50171.SystemLogEntryExtension.al) — composition extension pattern
- [Inheritance/src/Inherited/Codeunits/Cod50172.SystemLogEvents.al](../Inheritance/src/Inherited/Codeunits/Cod50172.SystemLogEvents.al) — event subscriber decoupling (OCP example)
