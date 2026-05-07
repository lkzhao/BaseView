# BaseView

Some small helper UIView classes

## Obfuscated private strings

Readable private API keys live in `PrivateStrings/ObfuscatedStrings.swift`, which is outside the SwiftPM target and is not compiled into the library.

After editing that file, regenerate the checked-in runtime data:

```sh
swift scripts/generate-obfuscated-strings.swift
```

To verify the generated file is current:

```sh
swift scripts/generate-obfuscated-strings.swift --check
```
