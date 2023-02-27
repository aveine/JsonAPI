# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2023-02-27
### Features
#### Changed
- Use new concurrency (async/await) capabilities instead of callback function.

## [1.3.0] - 2022-02-28
### Features
#### Added
- Nested attribute handling

## [1.2.0] - 2022-02-03
### Features
#### Added
- Possibility to override the equality check between two Resources

## [1.1.0] - 2022-01-18
### Features
#### Added
- Can now use Swift types for Resource's attributes
### Codebase
#### Added
- [Runtime library](https://github.com/wickwirew/Runtime) to set attributes by reflection
- `Equatable` to JSON:API structs to compare them

## [1.0.4] - 2021-09-09
### Codebase
#### Fixed
- Exclude Info.plist in sources to avoid warning for SPM

## [1.0.3] - 2021-09-06
### Features
#### Fixed
- Resources that doesn't directly inherit from base `Resource` class can now be correctly deserialized within includes.

## [1.0.2] - 2021-03-17
### Codebase
#### Added
- Possibility to install the library with the Swift Package Manager

## [1.0.1] - 2021-02-07
### Codebase
#### Fixed
- Fix Podfile

## [1.0.0] - 2020-05-06
### Feature
#### Added
- Swift representation of JSON:API objects
- `Resource` open class to transform a model to a JSON:API resource
- Network abilities to discuss with a JSON:API server
