import Foundation
import ObjectiveC.runtime

final class ClassRuntimePrinter {
    @discardableResult
    static func printInfo(for className: String) -> String {
        guard let cls = resolveClass(named: className) else {
            let message = "ClassRuntimePrinter: class '\(className)' not found."
            print(message)
            return message
        }

        let resolvedName = NSStringFromClass(cls)
        let superclassName = class_getSuperclass(cls).map { NSStringFromClass($0) } ?? "(none)"
        var sections: [String] = [
            "=== Runtime Introspection ===",
            "Input Class Name: \(className)",
            "Resolved Class: \(resolvedName)",
            "Superclass: \(superclassName)",
            "Instance Size: \(class_getInstanceSize(cls)) bytes"
        ]

        sections.append(section(title: "Ivars", lines: ivarLines(for: cls)))
        sections.append(section(title: "Properties", lines: propertyLines(for: cls)))
        sections.append(section(title: "Protocols", lines: protocolLines(for: cls)))
        sections.append(section(title: "Instance Methods (Selectors)", lines: methodLines(for: cls, classMethods: false)))
        sections.append(section(title: "Class Methods (Selectors)", lines: methodLines(for: cls, classMethods: true)))

        let report = sections.joined(separator: "\n\n")
        print(report)
        return report
    }

    private static func resolveClass(named className: String) -> AnyClass? {
        if let cls = NSClassFromString(className) {
            return cls
        }

        if let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
           let cls = NSClassFromString("\(bundleName).\(className)") {
            return cls
        }

        let suffix = ".\(className)"
        var classCount: UInt32 = 0
        guard let classList = objc_copyClassList(&classCount) else { return nil }
        defer { free(UnsafeMutableRawPointer(classList)) }

        for i in 0 ..< Int(classCount) {
            let candidateClass: AnyClass = classList[i]
            let candidateName = NSStringFromClass(candidateClass)
            if candidateName == className || candidateName.hasSuffix(suffix) {
                return candidateClass
            }
        }

        return nil
    }

    private static func section(title: String, lines: [String]) -> String {
        guard !lines.isEmpty else {
            return "[\(title)]\n(none)"
        }
        return "[\(title)]\n" + lines.joined(separator: "\n")
    }

    private static func ivarLines(for cls: AnyClass) -> [String] {
        var count: UInt32 = 0
        guard let ivars = class_copyIvarList(cls, &count) else { return [] }
        defer { free(ivars) }

        return (0 ..< Int(count)).map { index in
            let ivar = ivars[index]
            let name = ivar_getName(ivar).map { String(cString: $0) } ?? "<unnamed>"
            let type = ivar_getTypeEncoding(ivar).map { String(cString: $0) } ?? "?"
            let offset = ivar_getOffset(ivar)
            return "- \(name) : \(type) (offset: \(offset))"
        }
    }

    private static func propertyLines(for cls: AnyClass) -> [String] {
        var count: UInt32 = 0
        guard let properties = class_copyPropertyList(cls, &count) else { return [] }
        defer { free(properties) }

        return (0 ..< Int(count)).map { index in
            let property = properties[index]
            let name = String(cString: property_getName(property))
            let attributes = property_getAttributes(property).map { String(cString: $0) } ?? "?"
            return "- \(name) [\(attributes)]"
        }
    }

    private static func protocolLines(for cls: AnyClass) -> [String] {
        var count: UInt32 = 0
        guard let protocols = class_copyProtocolList(cls, &count) else { return [] }
        defer { free(UnsafeMutableRawPointer(protocols)) }

        return (0 ..< Int(count)).map { index in
            let proto = protocols[index]
            return "- \(String(cString: protocol_getName(proto)))"
        }
    }

    private static func methodLines(for cls: AnyClass, classMethods: Bool) -> [String] {
        let targetClass: AnyClass
        if classMethods {
            guard let metaClass = object_getClass(cls) else { return [] }
            targetClass = metaClass
        } else {
            targetClass = cls
        }

        var count: UInt32 = 0
        guard let methods = class_copyMethodList(targetClass, &count) else { return [] }
        defer { free(methods) }

        return (0 ..< Int(count)).map { index in
            let method = methods[index]
            let selectorName = NSStringFromSelector(method_getName(method))
            let encoding = method_getTypeEncoding(method).map { String(cString: $0) } ?? "?"
            return "- \(selectorName)  [\(encoding)]"
        }.sorted()
    }
}
