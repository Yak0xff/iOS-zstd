# iOS-zstd
iOS-Zstandard - Fast real-time compression algorithm http://www.zstd.net



This is the [Zstandard](http://www.zstd.net) compression algorithm in iOS used.

The project is the static libary build project for Dictionary compression.  

### Demo

The Demo folder is the usage code in iOS. It's the category `NSData` to support compress and decompress.

### warning

In the compress and decompress method, should use the preset dictionary. The preset dictionary should use follow step generate:


Dictionary compression How To :

1) Create the dictionary

```
zstd --train FullPathToTrainingSet/* -o dictionaryName
```

2) Compress with dictionary

```
zstd FILE -D dictionaryName
```

3) Decompress with dictionary

```
zstd --decompress FILE.zst -D dictionaryName
```


The `NSData+zstdSimple` use the `preset.zdict` preset dictionary file name, you can use your likes.



### Usage

1. Compress the data

``` objc
+ (NSData *)dataByZSTDSimpleCompressing:(NSData *)aData
```

2. Decompress the data

``` objc
+ (NSData *)dataByZSTDSimpleDeCompressing:(NSData *)aData
```
