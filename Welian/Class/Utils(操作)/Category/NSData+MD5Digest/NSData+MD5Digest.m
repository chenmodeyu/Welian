//
//  NSData+MD5Digest.m
//  NSData+MD5Digest
//
//  Created by Francis Chong on 12年6月5日.
//

#import "NSData+MD5Digest.h"
#import <CommonCrypto/CommonDigest.h>
#import<CommonCrypto/CommonCrypto.h>

@implementation NSData (MD5)

+(NSData *)MD5Digest:(NSData *)input {
    unsigned char result[CC_MD5_DIGEST_LENGTH];

    CC_MD5(input.bytes, input.length, result);
    return [[NSData alloc] initWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

-(NSData *)MD5Digest {
    return [NSData MD5Digest:self];
}

+(NSString *)MD5HexDigest:(NSData *)input {
    unsigned char result[CC_MD5_DIGEST_LENGTH];

    CC_MD5(input.bytes, input.length, result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

-(NSString *)MD5HexDigest {
    return [NSData MD5HexDigest:self];
}

//解密
- (NSString *)DESdecrypt
{
    NSData *data = [[NSData alloc] initWithBase64EncodedData:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    return [[NSString alloc] initWithData:[self DESDecrypt:data WithKey:KDESkey] encoding:NSUTF8StringEncoding];
}


- (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

@end
