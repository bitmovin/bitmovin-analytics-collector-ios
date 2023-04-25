//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
//

#if !defined(IVS_EXTERN)
#   if __cplusplus
#       define IVS_EXTERN extern "C"
#   else
#       define IVS_EXTERN extern
#   endif
#endif

#if !defined(IVS_VISIBLE)
#   define IVS_VISIBLE __attribute__((visibility("default")))
#endif

#if !defined(IVS_EXPORT)
#   define IVS_EXPORT IVS_EXTERN IVS_VISIBLE
#endif

#if !defined(IVS_INIT_UNAVAILABLE)
#  define IVS_INIT_UNAVAILABLE \
- (instancetype)init __attribute__((unavailable("Do not create instances of this class directly"))); \
+ (instancetype)new __attribute__((unavailable("Do not create instances of this class directly")));
#endif
