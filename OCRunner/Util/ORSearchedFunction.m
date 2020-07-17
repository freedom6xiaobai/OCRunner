//
//  ORSearchedFunction.m
//  OCRunner
//
//  Created by Jiang on 2020/6/9.
//  Copyright © 2020 SilverFruity. All rights reserved.
//

#import "ORSearchedFunction.h"
#import "SymbolSearch.h"
#import "RunnerClasses.h"
#import "MFStack.h"
#import "MFValue.h"
#import "ORTypeVarPair+TypeEncode.h"
#import "ORCoreImp.h"
#import "ORHandleTypeEncode.h"
#import "ORStructDeclare.h"
@implementation ORSearchedFunction
- (ORFuncVariable *)funVar{
    return (ORFuncVariable *)self.funPair.var;
}
+ (instancetype)functionWithName:(NSString *)name{
    ORSearchedFunction *function = [ORSearchedFunction new];
    function.name = name;
    return function;
}
+ (NSDictionary *)functionTableForNames:(NSArray *)names{
    struct FunctionSearch searches[names.count];
    NSMutableDictionary *table = [NSMutableDictionary dictionary];
    for (int i = 0; i < names.count; i++) {
        NSString *name = names[i];
        ORSearchedFunction *result = [ORSearchedFunction functionWithName:name];
        searches[i].name = result.name.UTF8String;
        searches[i].pointer = &result->_pointer;
        table[name] = result;
    }
    search_symbols(searches, names.count);
    return table;
}
- (nullable MFValue *)execute:(nonnull MFScopeChain *)scope {
    NSArray <MFValue *>*args = [[MFStack argsStack] pop];
    NSString *typeName = self.funPair.type.name;
    ORTypeVarPair *registerPair = [[ORTypeSymbolTable shareInstance] typePairForTypeName:typeName];
    const char *typeEncode = self.funPair.typeEncode;
    if (registerPair) {
        if (registerPair.type.type == TypeStruct) {
            ORStructDeclare *declare = [[ORStructDeclareTable shareInstance] getStructDeclareWithName:typeName];
            typeEncode = declare.typeEncoding;
        }else{
            typeEncode = registerPair.typeEncode;
        }
    }
    MFValue *returnValue = [MFValue defaultValueWithTypeEncoding:typeEncode];
    if (!self.funVar.isMultiArgs) {
        invoke_functionPointer(self.pointer, args, returnValue);
        //多参数
    }else{
        invoke_functionPointer(self.pointer, args, returnValue, self.funVar.pairs.count);
    }
    return returnValue;
}

@end