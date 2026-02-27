---
name: golang
description: Go programming language fundamentals, best practices, and development workflows for HashiCorp projects
---

# Go (Golang) Development

This skill covers Go programming language fundamentals, best practices, and development workflows. Go is the primary language for most HashiCorp products including Terraform, Vault, Consul, Nomad, and more.

## When to Use This Skill

Use this skill when you need to:
- Learn Go language basics
- Understand Go syntax and idioms
- Debug Go code or error messages
- Write Go code following HashiCorp conventions
- Work on HashiCorp products (most are written in Go)
- Understand differences between Go and other languages

## Installation & Setup

### Install Go

**macOS (Homebrew):**
```bash
brew install go
```

**Linux/Manual:**
Download from [https://go.dev/dl/](https://go.dev/dl/)

**Verify Installation:**
```bash
go version
```

### Set Up Workspace

Go modules (default since Go 1.11) don't require a specific workspace structure, but you'll need:

```bash
# View Go environment
go env

# Key environment variables
export GOPATH=$HOME/go           # Go workspace (default)
export PATH=$PATH:$GOPATH/bin    # Add Go binaries to PATH
```

### Create a New Project

```bash
mkdir myproject
cd myproject
go mod init github.com/username/myproject
```

## Core Concepts

### Packages

Every Go program is made up of packages. Programs start running in package `main`.

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
```

### Imports

Group imports into a parenthesized, "factored" import statement:

```go
import (
    "fmt"
    "math"
)
```

### Exported Names

A name is exported (public) if it begins with a capital letter:
- `math.Pi` ✓ (exported)
- `math.pi` ✗ (not exported)

Find available exports in package documentation:
- **fmt package**: https://pkg.go.dev/fmt
- **math package**: https://pkg.go.dev/math

## Variables and Constants

### Variable Declaration

```go
// Using var keyword
var name string = "Alice"
var age int = 30

// Type inference
var city = "New York"

// Multiple variables
var x, y int = 1, 2
var p, q, z = true, false, "cool!"

// Short declaration (inside functions only)
name := "Alice"
age := 30
```

### Short Declaration (`:=`) Rules

**Rule 1**: Only works inside functions
```go
// Outside function - illegal
illegal := 42

// Must use var keyword
var legal = 42

func foo() {
    alsoLegal := 42  // Works in function scope
}
```

**Rule 2**: Cannot redeclare in same scope
```go
legal := 42
legal := 42  // Error: no new variables
```

**Rule 3**: Multi-variable declarations
```go
foo, bar := 42, 314
jazz, bazz := 22, 7
```

**Rule 4**: Redeclaration (if one variable is new)
```go
foo, bar := someFunc()
foo, jazz := someFunc()  // OK - jazz is new
baz, foo := someFunc()   // OK - baz is new
```

**Rule 5**: Can redeclare in nested scope
```go
var foo int = 34

func some() {
    foo := 42   // Different foo, scoped to function
    foo = 314   // Assign to local foo
}
```

**Rule 6**: Can declare in statement blocks
```go
foo := 42
if foo := someFunc(); foo == 314 {
    // foo is scoped to this if block
}
// foo is still 42 here
```

### Constants

```go
const Pi = 3.14
const (
    StatusOK = 200
    StatusNotFound = 404
)
```

**Key Differences: `var` vs `const`**

| Feature | `var` | `const` |
| --- | --- | --- |
| Mutability | Mutable | Immutable |
| Initialization | Optional, can be initialized later | Required at declaration |
| Compile-time | Values may not be known at compile time | Values must be known at compile time |
| Default Value | Assigned zero value if not initialized | N/A |
| Addressable | Has a memory address | No memory address |

### Zero Values

Variables declared without an explicit initial value get their **zero value**:
- `0` for numeric types
- `false` for boolean
- `""` (empty string) for strings

```go
var i int       // 0
var f float64   // 0.0
var b bool      // false
var s string    // ""
```

## Basic Types

```go
bool

string

int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr

byte     // alias for uint8
rune     // alias for int32 (Unicode code point)

float32 float64

complex64 complex128
```

**Tip**: Use `int` unless you have a specific reason to use a sized or unsigned type.

### Type Conversions

Type conversions must be explicit:

```go
var x, y int = 3, 4
var f float64 = math.Sqrt(float64(x*x + y*y))  // Must convert to float64

// General pattern
int(x)
float64(y)
string(rune)
```

### Type Inference

When declaring without specifying type, the type is inferred:

```go
i := 42           // int
f := 3.142        // float64
g := 0.867 + 0.5i // complex128
```

## Functions

### Basic Function

```go
func add(x int, y int) int {
    return x + y
}

// Consecutive parameters of same type
func add(x, y int) int {
    return x + y
}
```

### Multiple Return Values

```go
func swap(x, y string) (string, string) {
    return y, x
}

a, b := swap("hello", "world")
```

### Named Return Values

```go
func split(sum int) (x, y int) {
    x = sum * 4 / 9
    y = sum - x
    return  // "naked" return
}
```

**Note**: Naked returns should only be used in short functions for readability.

## Printing and Formatting

### Three Ways to Print

**`fmt.Print()`** - Print without formatting:
```go
fmt.Print("Hello", " ", "World\n")
```

**`fmt.Println()`** - Print with newline:
```go
fmt.Println("Hello", "World")  // Adds spaces and newline
```

**`fmt.Printf()`** - Print with formatting:
```go
name := "Alice"
age := 30
fmt.Printf("%s is %d years old\n", name, age)
```

### Common Format Verbs

```go
%v    // default format
%T    // type of value
%t    // boolean
%d    // decimal integer
%f    // floating point
%s    // string
%p    // pointer
```

Example:
```go
fmt.Printf("Now you have %g problems.\n", math.Sqrt(7))
// %g for floating-point, removes trailing zeros
```

## Common Commands

### Development

```bash
# Run a Go file
go run main.go

# Build an executable
go build

# Build and install
go install

# Format code (important!)
go fmt ./...

# Run tests
go test ./...

# Run specific test
go test -run TestName

# Get dependencies
go get package-name

# Update dependencies
go get -u ./...

# Tidy modules (clean up)
go mod tidy
```

### Code Quality

```bash
# Lint code (requires golangci-lint)
golangci-lint run

# Vet code (built-in)
go vet ./...

# Check for race conditions
go test -race ./...
```

## Common Workflows

### Workflow 1: Starting a New Go Project

1. **Create directory and initialize module:**
   ```bash
   mkdir myproject
   cd myproject
   go mod init github.com/username/myproject
   ```

2. **Create main.go:**
   ```go
   package main

   import "fmt"

   func main() {
       fmt.Println("Hello, World!")
   }
   ```

3. **Run the program:**
   ```bash
   go run main.go
   ```

4. **Build executable:**
   ```bash
   go build
   ./myproject
   ```

### Workflow 2: Adding Dependencies

1. **Import the package in code:**
   ```go
   import "github.com/some/package"
   ```

2. **Download dependency:**
   ```bash
   go get github.com/some/package
   ```

3. **Clean up dependencies:**
   ```bash
   go mod tidy
   ```

### Workflow 3: Testing

1. **Create test file (e.g., `main_test.go`):**
   ```go
   package main

   import "testing"

   func TestAdd(t *testing.T) {
       result := add(2, 3)
       if result != 5 {
           t.Errorf("add(2, 3) = %d; want 5", result)
       }
   }
   ```

2. **Run tests:**
   ```bash
   go test ./...
   ```

3. **Run with coverage:**
   ```bash
   go test -cover ./...
   ```

## Best Practices for HashiCorp Development

### Code Formatting
- **Always run `go fmt`** before committing
- Use `gofmt` or `goimports` in your editor
- Follow [Effective Go](https://go.dev/doc/effective_go) guidelines

### Error Handling
```go
// Good: Explicit error handling
result, err := someFunction()
if err != nil {
    return fmt.Errorf("failed to do something: %w", err)
}

// Use %w to wrap errors (Go 1.13+)
```

### Naming Conventions
- **Exported**: `PublicFunction`, `PublicVar` (starts with capital)
- **Unexported**: `privateFunction`, `privateVar` (starts with lowercase)
- **Interfaces**: `Reader`, `Writer` (often -er suffix)
- **Acronyms**: `HTTPServer` not `HttpServer`, `ID` not `Id`

### Project Structure (Common Pattern)
```
myproject/
├── cmd/                  # Command-line applications
│   └── myapp/
│       └── main.go
├── internal/             # Private application code
│   ├── server/
│   └── database/
├── pkg/                  # Public libraries
│   └── api/
├── go.mod
└── go.sum
```

### Testing
- Test files end with `_test.go`
- Place tests in same package or `_test` package
- Use table-driven tests for multiple cases
- Run `go test -race` to detect race conditions

## Troubleshooting

### Issue 1: "undefined: X"

**Symptoms:**
- Error: `undefined: SomeFunction`

**Cause:**
- Name is not exported (doesn't start with capital letter)
- Package not imported

**Solution:**
```go
// Check if name starts with capital letter
fmt.Println()  // ✓ Exported
fmt.println()  // ✗ Not exported

// Ensure package is imported
import "fmt"
```

### Issue 2: "cannot use := outside function"

**Symptoms:**
- Error when using `:=` at package level

**Cause:**
- Short declaration only works inside functions

**Solution:**
```go
// Wrong - outside function
message := "Hello"  // Error

// Correct - use var
var message = "Hello"

// Or inside function
func main() {
    message := "Hello"  // OK
}
```

### Issue 3: Type Mismatch

**Symptoms:**
- Error: `cannot use X (type int) as type float64`

**Cause:**
- Go requires explicit type conversion

**Solution:**
```go
var x int = 10
var y float64 = float64(x)  // Explicit conversion
```

### Issue 4: Import Cycle

**Symptoms:**
- Error: `import cycle not allowed`

**Cause:**
- Package A imports B, and B imports A

**Solution:**
- Refactor to break the cycle
- Move shared code to a third package
- Use interfaces to decouple dependencies

## HashiCorp-Specific Tips

### Most HashiCorp Products Use Go
- **Terraform Core**: Go
- **Vault**: Go
- **Consul**: Go
- **Nomad**: Go
- **Boundary**: Go
- **Waypoint**: Go

### Common HashiCorp Libraries
- `hashicorp/go-plugin` - Plugin system
- `hashicorp/go-hclog` - Logging
- `hashicorp/hcl` - HashiCorp Configuration Language
- `mitchellh/cli` - CLI framework

### Development Environment
Most HashiCorp projects use:
- Go modules for dependency management
- Makefiles for build tasks
- GitHub Actions or CircleCI for CI/CD

## Additional Resources

- **Official Go Tour**: https://go.dev/tour/
- **Effective Go**: https://go.dev/doc/effective_go
- **Go by Example**: https://gobyexample.com
- **Go Package Documentation**: https://pkg.go.dev
- **HashiCorp Go Style Guide**: Check individual project repositories
- **Internal Confluence**: https://hashicorp.atlassian.net/wiki/spaces/~562491899/pages/3824451752/Practice

## Summary

**Most Common Commands:**
```bash
# Development
go run main.go                 # Run program
go build                       # Build executable
go test ./...                  # Run tests
go fmt ./...                   # Format code
go mod tidy                    # Clean dependencies

# Quality
go vet ./...                   # Check for issues
go test -race ./...            # Check for race conditions
golangci-lint run              # Lint code
```

**Quick Reference:**
```go
// Variables
var name string = "value"      // Explicit type
var name = "value"             // Type inference
name := "value"                // Short declaration (functions only)

// Constants
const Pi = 3.14

// Functions
func add(x, y int) int {
    return x + y
}

// Multiple returns
func swap(x, y string) (string, string) {
    return y, x
}

// Printing
fmt.Println("Hello")                    // With newline
fmt.Printf("%s is %d\n", name, age)     // With formatting
```

**Remember:**
- `:=` only works inside functions; use `var` at package level
- Exported names start with capital letters
- Type conversions must be explicit
- Always handle errors explicitly
- Run `go fmt` before committing
- Use `int` unless you need a specific size
