//
//  NSData+zstdSimple.m
//  xz_test
//
//  Created by Robin on 8/5/16.
//  Copyright © 2016 TendCloud. All rights reserved.
//

#import "NSData+zstdSimple.h"

#import <sys/stat.h>
#import "zstd.h"

@implementation NSData (zstdSimple)


static void* malloc_orDie(size_t size)
{
    void* const buff = malloc(size);
    if (buff) return buff;
    /* error */
    perror("malloc");
    exit(3);
}



static off_t fsize_orDie(const char *filename)
{
    struct stat st;
    if (stat(filename, &st) == 0) return st.st_size;
    /* error */
    perror(filename);
    exit(1);
}

static FILE* fopen_orDie(const char *filename, const char *instruction)
{
    FILE* const inFile = fopen(filename, instruction);
    if (inFile) return inFile;
    /* error */
    perror(filename);
    exit(2);
}



static void* loadFile_orDie(const char* fileName, size_t* size)
{
    off_t const buffSize = fsize_orDie(fileName);
    FILE* const inFile = fopen_orDie(fileName, "rb");
    void* const buffer = malloc_orDie(buffSize);
    size_t const readSize = fread(buffer, 1, buffSize, inFile);
    if (readSize != (size_t)buffSize) {
        fprintf(stderr, "fread: %s : %s \n", fileName, strerror(errno));
        exit(4);
    }
    fclose(inFile);
    *size = buffSize;
    return buffer;
}


/* createDict() :
 `dictFileName` is supposed to have been created using `zstd --train` */
static ZSTD_CDict* createCDict_orDie(const char* dictFileName)
{
    size_t dictSize;
    void* const dictBuffer = loadFile_orDie(dictFileName, &dictSize);
    ZSTD_CDict* const cdict = ZSTD_createCDict(dictBuffer, dictSize, 18);
    if (!cdict) {
        fprintf(stderr, "ZSTD_createCDict error \n");
        exit(7);
    }
    free(dictBuffer);
    return cdict;
}


/* createDict() :
 `dictFileName` is supposed to have been created using `zstd --train` */
static ZSTD_DDict* createDict_orDie(const char* dictFileName)
{
    size_t dictSize;
    printf("loading dictionary %s \n", dictFileName);
    void* const dictBuffer = loadFile_orDie(dictFileName, &dictSize);
    ZSTD_DDict* const ddict = ZSTD_createDDict(dictBuffer, dictSize);
    if (ddict==NULL) { fprintf(stderr, "ZSTD_createDDict error \n"); exit(5); }
    free(dictBuffer);
    return ddict;
}


+ (NSData *)dataByZSTDSimpleCompressing:(NSData *)aData{
    size_t fSize = [aData length];
    size_t const cBufferSize = ZSTD_compressBound(fSize);
    void *const cBuff = malloc_orDie(cBufferSize);
    
    
    ZSTD_CCtx* const cctx = ZSTD_createCCtx();
    
    NSString *PATH = [[NSBundle mainBundle] pathForResource:@"preset" ofType:@"zdict"];
    ZSTD_CDict* const dictPtr = createCDict_orDie([PATH UTF8String]);
    
    size_t const cSize = ZSTD_compress_usingCDict(cctx, cBuff, cBufferSize, [aData bytes], fSize, dictPtr);
    
    if (ZSTD_isError(cSize)) {
        fprintf(stderr, "error compressing  %s \n", ZSTD_getErrorName(cSize));
        exit(7);
    }
    
    NSMutableData *result = [NSMutableData dataWithBytes:cBuff length:cSize];
    
    free(cBuff);
    ZSTD_freeCCtx(cctx);
    ZSTD_freeCDict(dictPtr);
    
    return [NSData dataWithData:result];
}


+ (NSData *)dataByZSTDSimpleDeCompressing:(NSData *)aData{
    size_t cSize = [aData length];
    const void* cBuff = [aData bytes];
    unsigned long long const rSize = ZSTD_getDecompressedSize(cBuff, cSize);
    if (rSize==0) {
        fprintf(stderr, "original size unknown \n");
        exit(6);
    }
    void* const rBuff = malloc_orDie(rSize);
    
    
    ZSTD_DCtx* const dctx = ZSTD_createDCtx();
    
    NSString *PATH = [[NSBundle mainBundle] pathForResource:@"preset" ofType:@"zdict"];
    ZSTD_DDict* const ddict = createDict_orDie([PATH UTF8String]);
    
    size_t const dSize = ZSTD_decompress_usingDDict(dctx, rBuff, rSize, cBuff, cSize, ddict);
    
    if (dSize != rSize) {
        fprintf(stderr, "error decoding: %s \n", ZSTD_getErrorName(dSize));
        exit(7);
    }
    
    /* success */
    printf("success: %6u -> %7u \n", (unsigned)cSize, (unsigned)rSize);
    
    NSMutableData *result = [NSMutableData dataWithBytes:rBuff length:rSize];
    
    ZSTD_freeDCtx(dctx);
    free(rBuff);
    
    return [NSData dataWithData:result];
}




@end


