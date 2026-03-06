---
name: 05-security-doxygen-comments
description: Write and review Doxygen-format comments directly in C/C++ code. Use when documenting public APIs, types, macros, and modules; fixing missing or inconsistent doc comments; organizing docs with groups/pages; and enforcing clear English comments compatible with Doxygen-based generators.
license: MIT
metadata:
  audience: coders
---

## Purpose

Use this skill to author Doxygen comments directly in C/C++ files.

- Focus on comment quality and consistency, not on any specific doc generation toolchain.
- Write all Doxygen comment text in English.
- Keep tags and formatting strictly Doxygen-standard.

## Supported Comment Forms

### Block comments

Use for most functions, classes, and file headers.

```c
/**
 * @brief Computes the checksum for a message buffer.
 * @param data Pointer to the input bytes.
 * @param size Number of bytes in data.
 * @return Computed checksum value.
 */
uint32_t checksum_compute(const uint8_t* data, size_t size);
```

### Triple-slash comments

Use for simple declarations.

```c
/// @brief Returns the absolute value of n.
/// @param n Input integer.
/// @return Absolute value of n.
int abs_value(int n);
```

### Inline member comments

Use for struct or enum members.

```c
struct Point {
    int x;  /**< X coordinate in pixels. */
    int y;  /**< Y coordinate in pixels. */
};

enum State {
    STATE_IDLE = 0,       /**< No task is running. */
    STATE_RUNNING = 1,    /**< Task is currently running. */
    STATE_FAILED = 2      /**< Task terminated with an error. */
};
```

### Placement rules

- Place the doc comment immediately above the declaration.
- Do not insert a blank line between comment and declaration.
- Keep comment style consistent within a file.

## Doxygen Tag Reference (Strict Standard)

Use only mainstream Doxygen tags listed below.

### Core tags

- `@brief`: One-line summary.
- `@details`: Extended description.
- `@param name`: Parameter description.
- `@return`: Return value description.
- `@retval value`: Meaning of specific return values.
- `@tparam name`: Template parameter description.

### Structure and navigation tags

- `@file`: File-level documentation.
- `@class`: Class documentation target.
- `@struct`: Struct documentation target.
- `@enum`: Enum documentation target.
- `@typedef`: Typedef or using alias target.
- `@namespace`: Namespace documentation target.

### Organization tags

- `@defgroup`: Define a documentation group.
- `@ingroup`: Add an item to an existing group.
- `@addtogroup`: Extend an existing group block.
- `@page`: Define a standalone page.
- `@subpage`: Link to a child page.
- `@section`: Create a section within a page.

### Quality and note tags

- `@note`: Important behavior details.
- `@warning`: Risky or dangerous behavior.
- `@attention`: Operational attention point.
- `@deprecated`: Deprecation notice and replacement.
- `@since`: Version or release when introduced.
- `@see`: Related symbols or pages.
- `@ref`: Cross-reference to a symbol or page.

### Example tags

- `@code` and `@endcode`: Inline code example block.
- `@example`: Link to or declare example usage.
- `@snippet`: Include code snippet from an external file.

### Reuse tag

- `@copydoc`: Reuse documentation from another symbol.

### Exclusion rule

- Do not use custom or tool-specific tags outside standard Doxygen usage.

## Advanced Patterns

### Cross-reference related symbols

Use `@ref` inside descriptions and `@see` for related APIs.

```cpp
/**
 * @brief Searches for a key in sorted storage.
 * @param storage Sorted storage object.
 * @param key Key to find.
 * @return Iterator to the matching entry or @ref Storage::end().
 * @see Storage::sort
 */
Storage::iterator storage_find(Storage& storage, const Key& key);
```

### Organize API by groups

Use `@defgroup` and `@ingroup` to create module-level navigation.

```c
/** @defgroup uart_api UART API
 *  @brief UART configuration and transfer functions.
 *  @{
 */

/**
 * @brief Initializes the UART peripheral.
 * @ingroup uart_api
 * @param cfg UART configuration.
 * @return 0 on success, negative error code on failure.
 */
int uart_init(const uart_config_t* cfg);

/** @} */
```

### Build conceptual pages

Use `@page`, `@section`, and `@subpage` for architecture or workflow docs.

```c
/**
 * @page transport_overview Transport Layer Overview
 * @brief Message framing, retry logic, and timeout policy.
 *
 * @section retry_policy Retry Policy
 * Retries occur for transient link failures up to three attempts.
 *
 * @subpage transport_examples
 */
```

### Reuse docs with copydoc

Use `@copydoc` to avoid duplication while adding variant-specific notes.

```cpp
/**
 * @brief Sends a request packet.
 * @param request Request packet to send.
 * @return True on success.
 */
bool send_request(const Request& request);

/**
 * @copydoc send_request(const Request&)
 * @note This overload applies a default timeout.
 */
bool send_request(const Request& request, Timeout timeout = Timeout::Default);
```

## AI Agent Rules

### What to document

- Document all public functions, methods, classes, structs, enums, typedefs, namespaces, and public macros.
- Document public struct fields and enum values with inline comments when useful for API consumers.
- Add file-level docs for public headers.

### Required minimum tags by entity

- Function or method: `@brief`, one `@param` per parameter, and `@return` for non-void.
- Template function or class: function/class minimum tags plus one `@tparam` per template parameter.
- Struct, class, enum, typedef, namespace: at least `@brief`.
- Function-like macro: `@brief` and `@param` for each macro argument when semantics are non-trivial.
- Public header: `@file` and `@brief`.

### Consistency rules

1. Write all Doxygen comment text in English.
2. Start `@brief` with an imperative or present-tense verb.
3. Keep `@brief` to one sentence.
4. Keep parameter names in `@param` exactly equal to signature names.
5. Do not leave empty tags.
6. Use `@retval` when return codes have distinct meanings.
7. Prefer `@ref` and `@see` for cross-links instead of plain text references.
8. Keep comments adjacent to declarations with no blank separator line.
9. Avoid documenting internal-only symbols unless explicitly requested.

## Ready-to-Use Templates

### Function template

```c
/**
 * @brief Parses a frame from the input buffer.
 * @param input Pointer to input bytes.
 * @param length Number of bytes available in input.
 * @param out_frame Destination frame object.
 * @return Number of bytes consumed, or negative error code.
 */
int frame_parse(const uint8_t* input, size_t length, frame_t* out_frame);
```

### Template function template

```cpp
/**
 * @brief Converts a value to a bounded string form.
 * @tparam T Input value type.
 * @param value Value to convert.
 * @param max_chars Maximum output length.
 * @return Converted string.
 */
template <typename T>
std::string to_bounded_string(const T& value, std::size_t max_chars);
```

### Template class template

```cpp
/**
 * @brief Stores key-value pairs with fixed capacity.
 * @tparam Key Key type.
 * @tparam Value Value type.
 */
template <typename Key, typename Value>
class FixedMap;
```

### Struct, enum, and member template

```c
/**
 * @brief Represents a rectangular region.
 */
struct Rect {
    int x;      /**< Left position in pixels. */
    int y;      /**< Top position in pixels. */
    int width;  /**< Width in pixels. */
    int height; /**< Height in pixels. */
};

/**
 * @brief Result code for parser operations.
 */
enum ParseResult {
    PARSE_OK = 0,            /**< Parsing completed successfully. */
    PARSE_BAD_FORMAT = 1,    /**< Input format is invalid. */
    PARSE_BUFFER_TOO_SMALL   /**< Output buffer is too small. */
};
```

### File header template

```c
/**
 * @file protocol_parser.h
 * @brief Public API for protocol frame parsing.
 * @details Defines parser configuration, result codes, and parsing entry points.
 * @since 1.0.0
 */
```

## Review Checklist

- [ ] Every public API entity has documentation.
- [ ] All comment text is English.
- [ ] Every non-void function has `@return`.
- [ ] Every parameter and template parameter is documented.
- [ ] `@param` names exactly match declaration names.
- [ ] Comment placement is directly above declarations with no blank separator line.
- [ ] Cross-references use valid `@ref` or `@see` targets.
- [ ] Only standard Doxygen tags are used.
- [ ] No tooling-specific command, config, or CI guidance is included.
