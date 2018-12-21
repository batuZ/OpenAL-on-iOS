
//#import <UIKit/UIKit.h>
#import <MSSupport/MS_User.h>
#import <MSSupport/MS_Sound.h>
//! Project version number for MSSupport.
FOUNDATION_EXPORT double MSSupportVersionNumber;

//! Project version string for MSSupport.
FOUNDATION_EXPORT const unsigned char MSSupportVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MSSupport/PublicHeader.h>

// 学学怎么写注释
// https://blog.csdn.net/cga6741011/article/details/50555333

// framework 编译方法
//https://www.jianshu.com/p/ef3d5b7e7006?utm_campaign=hugo&utm_medium=reader_share&utm_content=note&utm_source=qq


/*
 
 # 设置目标文件夹和finalframework产品。
 # 如果工程名称和Framework的Target名称不一样的话，要自定义FMKNAME
 # 例如: FMK_NAME = "MyFramework"
 FMK_NAME=${PROJECT_NAME}
 # 输出路径，  SRCROOT 是工程根目录
 INSTALL_DIR=${SRCROOT}/Products/${FMK_NAME}.framework
 # Working dir will be deleted after theframework creation.
 WRK_DIR=build
 DEVICE_DIR=${WRK_DIR}/Release-iphoneos/${FMK_NAME}.framework
 SIMULATOR_DIR=${WRK_DIR}/Release-iphonesimulator/${FMK_NAME}.framework
 # -configuration ${CONFIGURATION}
 # Clean and Building both architectures.
 xcodebuild -configuration "Release" -target "${FMK_NAME}" -sdk iphoneos clean build
 xcodebuild -configuration "Release" -target "${FMK_NAME}" -sdk iphonesimulator clean build
 # Cleaning the oldest.
 if[ -d "${INSTALL_DIR}" ]
 then
 rm -rf "${INSTALL_DIR}"
 fi
 mkdir -p "${INSTALL_DIR}"
 cp -R "${DEVICE_DIR}/" "${INSTALL_DIR}/"
 # Uses the Lipo Tool to merge both binaryfiles (i386 + armv6/armv7) into one Universal final product.
 lipo -create "${DEVICE_DIR}/${FMK_NAME}" "${SIMULATOR_DIR}/${FMK_NAME}" -output "${INSTALL_DIR}/${FMK_NAME}"
 rm -r "${WRK_DIR}"
 open "${INSTALL_DIR}"

 
 
 */
