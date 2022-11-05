cmake_minimum_required (VERSION 3.10)

set (BUILD_WRITERS ON)
set (BUILD_READERS ON)

set (ZXING_CORE_DEFINES)
if (WINRT)
    set (ZXING_CORE_DEFINES ${ZXING_CORE_DEFINES}
        -DWINRT
    )
endif()

set (ZXING_CORE_LOCAL_DEFINES
    $<$<BOOL:${BUILD_READERS}>:-DZXING_BUILD_READERS>
    $<$<BOOL:${BUILD_WRITERS}>:-DZXING_BUILD_WRITERS>
    $<$<BOOL:${BUILD_UNIT_TESTS}>:-DZXING_BUILD_FOR_TEST>
    -DZX_USE_UTF8 # silence deprecation warning in Result.h
)
if (MSVC)
    set (ZXING_CORE_LOCAL_DEFINES ${ZXING_CORE_LOCAL_DEFINES}
        -D_SCL_SECURE_NO_WARNINGS
        -D_CRT_SECURE_NO_WARNINGS
        -D_CRT_NONSTDC_NO_WARNINGS
        -DNOMINMAX
    )
else()
    set (ZXING_CORE_LOCAL_DEFINES ${ZXING_CORE_LOCAL_DEFINES}
        -Wall -Wextra -Wno-missing-braces -Werror=undef -Werror=return-type)
endif()


################# Source files
set (zxing-core lib-zxing)

set (COMMON_FILES
    ${zxing-core}/BarcodeFormat.h
    ${zxing-core}/BarcodeFormat.cpp
    ${zxing-core}/BitArray.h
    ${zxing-core}/BitArray.cpp
    ${zxing-core}/BitHacks.h
    ${zxing-core}/BitMatrix.h
    ${zxing-core}/BitMatrix.cpp
    ${zxing-core}/BitMatrixCursor.h
    ${zxing-core}/BitMatrixIO.h
    ${zxing-core}/BitMatrixIO.cpp
    ${zxing-core}/ByteArray.h
    ${zxing-core}/ByteMatrix.h
    ${zxing-core}/CharacterSet.h
    ${zxing-core}/CharacterSet.cpp
    ${zxing-core}/CharacterSetECI.h
    ${zxing-core}/ConcentricFinder.h
    ${zxing-core}/ConcentricFinder.cpp
    ${zxing-core}/CustomData.h
    ${zxing-core}/ECI.h
    ${zxing-core}/ECI.cpp
    ${zxing-core}/Flags.h
    ${zxing-core}/Generator.h
    ${zxing-core}/GenericGF.h
    ${zxing-core}/GenericGF.cpp
    ${zxing-core}/GenericGFPoly.h
    ${zxing-core}/GenericGFPoly.cpp
    ${zxing-core}/GTIN.h
    ${zxing-core}/GTIN.cpp
    ${zxing-core}/LogMatrix.h
    ${zxing-core}/Matrix.h
    ${zxing-core}/Pattern.h
    ${zxing-core}/Point.h
    ${zxing-core}/Quadrilateral.h
    ${zxing-core}/RegressionLine.h
    ${zxing-core}/Scope.h
    ${zxing-core}/TextUtfEncoding.h
    ${zxing-core}/TextUtfEncoding.cpp
    ${zxing-core}/TritMatrix.h
    ${zxing-core}/ZXAlgorithms.h
    ${zxing-core}/ZXBigInteger.h
    ${zxing-core}/ZXBigInteger.cpp
    ${zxing-core}/ZXConfig.h
    ${zxing-core}/ZXNullable.h
    ${zxing-core}/ZXTestSupport.h
)
if (BUILD_READERS)
    set (COMMON_FILES ${COMMON_FILES}
        ${zxing-core}/BinaryBitmap.h
        ${zxing-core}/BinaryBitmap.cpp
        ${zxing-core}/BitSource.h
        ${zxing-core}/BitSource.cpp
        ${zxing-core}/Content.h
        ${zxing-core}/Content.cpp
        ${zxing-core}/DecodeHints.h
        ${zxing-core}/DecodeHints.cpp
        ${zxing-core}/DecodeStatus.h
        ${zxing-core}/DecodeStatus.cpp
        ${zxing-core}/DecoderResult.h
        ${zxing-core}/DetectorResult.h
        ${zxing-core}/Error.h
        ${zxing-core}/GlobalHistogramBinarizer.h
        ${zxing-core}/GlobalHistogramBinarizer.cpp
        ${zxing-core}/GridSampler.h
        ${zxing-core}/GridSampler.cpp
        ${zxing-core}/GS1.h
        ${zxing-core}/GS1.cpp
        ${zxing-core}/HybridBinarizer.h
        ${zxing-core}/HybridBinarizer.cpp
        ${zxing-core}/ImageView.h
        ${zxing-core}/MultiFormatReader.h
        ${zxing-core}/MultiFormatReader.cpp
        ${zxing-core}/PerspectiveTransform.h
        ${zxing-core}/PerspectiveTransform.cpp
        ${zxing-core}/Reader.h
        ${zxing-core}/ReadBarcode.h
        ${zxing-core}/ReadBarcode.cpp
        ${zxing-core}/ReedSolomonDecoder.h
        ${zxing-core}/ReedSolomonDecoder.cpp
        ${zxing-core}/Result.h
        ${zxing-core}/Result.cpp
        ${zxing-core}/ResultPoint.h
        ${zxing-core}/ResultPoint.cpp
        ${zxing-core}/TextDecoder.h
        ${zxing-core}/TextDecoder.cpp
        ${zxing-core}/ThresholdBinarizer.h
        ${zxing-core}/WhiteRectDetector.h
        ${zxing-core}/WhiteRectDetector.cpp
    )
endif()
if (BUILD_WRITERS)
    set (COMMON_FILES ${COMMON_FILES}
        ${zxing-core}/ByteMatrix.h
        ${zxing-core}/ReedSolomonEncoder.h
        ${zxing-core}/ReedSolomonEncoder.cpp
        ${zxing-core}/TextEncoder.h
        ${zxing-core}/TextEncoder.cpp
        ${zxing-core}/MultiFormatWriter.h
        ${zxing-core}/MultiFormatWriter.cpp
    )
endif()

# define subset of public headers that get distributed with the binaries
set (PUBLIC_HEADERS
    ${zxing-core}/BarcodeFormat.h
    ${zxing-core}/BitHacks.h
    ${zxing-core}/ByteArray.h
    ${zxing-core}/CharacterSet.h
    ${zxing-core}/CharacterSetECI.h # deprecated
    ${zxing-core}/Flags.h
    ${zxing-core}/GTIN.h
    ${zxing-core}/TextUtfEncoding.h
    ${zxing-core}/ZXAlgorithms.h
    ${zxing-core}/ZXConfig.h
)
if (BUILD_READERS)
    set (PUBLIC_HEADERS ${PUBLIC_HEADERS}
        ${zxing-core}/Content.h
        ${zxing-core}/DecodeHints.h
        ${zxing-core}/DecodeStatus.h
        ${zxing-core}/Error.h
        ${zxing-core}/ImageView.h
        ${zxing-core}/Point.h
        ${zxing-core}/Quadrilateral.h
        ${zxing-core}/ReadBarcode.h
        ${zxing-core}/Result.h
        ${zxing-core}/StructuredAppend.h
    )
endif()
if (BUILD_WRITERS)
    set (PUBLIC_HEADERS ${PUBLIC_HEADERS}
        ${zxing-core}/BitMatrix.h
        ${zxing-core}/BitMatrixIO.h
        ${zxing-core}/Matrix.h
        ${zxing-core}/MultiFormatWriter.h
    )
endif()
# end of public header set

set (AZTEC_FILES
)
if (BUILD_READERS)
    set (AZTEC_FILES ${AZTEC_FILES}
        ${zxing-core}/aztec/AZDecoder.h
        ${zxing-core}/aztec/AZDecoder.cpp
        ${zxing-core}/aztec/AZDetector.h
        ${zxing-core}/aztec/AZDetector.cpp
        ${zxing-core}/aztec/AZDetectorResult.h
        ${zxing-core}/aztec/AZReader.h
        ${zxing-core}/aztec/AZReader.cpp
    )
endif()
if (BUILD_WRITERS)
    set (AZTEC_FILES ${AZTEC_FILES}
        ${zxing-core}/aztec/AZEncodingState.h
        ${zxing-core}/aztec/AZEncoder.h
        ${zxing-core}/aztec/AZEncoder.cpp
        ${zxing-core}/aztec/AZHighLevelEncoder.h
        ${zxing-core}/aztec/AZHighLevelEncoder.cpp
        ${zxing-core}/aztec/AZToken.h
        ${zxing-core}/aztec/AZToken.cpp
        ${zxing-core}/aztec/AZWriter.h
        ${zxing-core}/aztec/AZWriter.cpp
    )
endif()


set (DATAMATRIX_FILES
    ${zxing-core}/datamatrix/DMBitLayout.h
    ${zxing-core}/datamatrix/DMBitLayout.cpp
    ${zxing-core}/datamatrix/DMVersion.h
    ${zxing-core}/datamatrix/DMVersion.cpp
)
if (BUILD_READERS)
    set (DATAMATRIX_FILES ${DATAMATRIX_FILES}
        ${zxing-core}/datamatrix/DMDataBlock.h
        ${zxing-core}/datamatrix/DMDataBlock.cpp
        ${zxing-core}/datamatrix/DMDecoder.h
        ${zxing-core}/datamatrix/DMDecoder.cpp
        ${zxing-core}/datamatrix/DMDetector.h
        ${zxing-core}/datamatrix/DMDetector.cpp
        ${zxing-core}/datamatrix/DMReader.h
        ${zxing-core}/datamatrix/DMReader.cpp
    )
endif()
if (BUILD_WRITERS)
    set (DATAMATRIX_FILES ${DATAMATRIX_FILES}
        ${zxing-core}/datamatrix/DMECEncoder.h
        ${zxing-core}/datamatrix/DMECEncoder.cpp
        ${zxing-core}/datamatrix/DMEncoderContext.h
        ${zxing-core}/datamatrix/DMHighLevelEncoder.h
        ${zxing-core}/datamatrix/DMHighLevelEncoder.cpp
        ${zxing-core}/datamatrix/DMSymbolInfo.h
        ${zxing-core}/datamatrix/DMSymbolInfo.cpp
        ${zxing-core}/datamatrix/DMSymbolShape.h
        ${zxing-core}/datamatrix/DMWriter.h
        ${zxing-core}/datamatrix/DMWriter.cpp
    )
endif()


set (MAXICODE_FILES
)
if (BUILD_READERS)
    set (MAXICODE_FILES ${MAXICODE_FILES}
        ${zxing-core}/maxicode/MCBitMatrixParser.h
        ${zxing-core}/maxicode/MCBitMatrixParser.cpp
        ${zxing-core}/maxicode/MCDecoder.h
        ${zxing-core}/maxicode/MCDecoder.cpp
        ${zxing-core}/maxicode/MCReader.h
        ${zxing-core}/maxicode/MCReader.cpp
    )
endif()


set (ONED_FILES
    ${zxing-core}/oned/ODUPCEANCommon.h
    ${zxing-core}/oned/ODUPCEANCommon.cpp
    ${zxing-core}/oned/ODCode128Patterns.h
    ${zxing-core}/oned/ODCode128Patterns.cpp
)
if (BUILD_READERS)
    set (ONED_FILES ${ONED_FILES}
        ${zxing-core}/oned/ODCodabarReader.h
        ${zxing-core}/oned/ODCodabarReader.cpp
        ${zxing-core}/oned/ODCode39Reader.h
        ${zxing-core}/oned/ODCode39Reader.cpp
        ${zxing-core}/oned/ODCode93Reader.h
        ${zxing-core}/oned/ODCode93Reader.cpp
        ${zxing-core}/oned/ODCode128Reader.h
        ${zxing-core}/oned/ODCode128Reader.cpp
        ${zxing-core}/oned/ODDataBarCommon.h
        ${zxing-core}/oned/ODDataBarCommon.cpp
        ${zxing-core}/oned/ODDataBarReader.h
        ${zxing-core}/oned/ODDataBarReader.cpp
        ${zxing-core}/oned/ODDataBarExpandedBitDecoder.h
        ${zxing-core}/oned/ODDataBarExpandedBitDecoder.cpp
        ${zxing-core}/oned/ODDataBarExpandedReader.h
        ${zxing-core}/oned/ODDataBarExpandedReader.cpp
        ${zxing-core}/oned/ODITFReader.h
        ${zxing-core}/oned/ODITFReader.cpp
        ${zxing-core}/oned/ODMultiUPCEANReader.h
        ${zxing-core}/oned/ODMultiUPCEANReader.cpp
        ${zxing-core}/oned/ODReader.h
        ${zxing-core}/oned/ODReader.cpp
        ${zxing-core}/oned/ODRowReader.h
        ${zxing-core}/oned/ODRowReader.cpp
    )
endif()
if (BUILD_WRITERS)
    set (ONED_FILES ${ONED_FILES}
        ${zxing-core}/oned/ODCodabarWriter.h
        ${zxing-core}/oned/ODCodabarWriter.cpp
        ${zxing-core}/oned/ODCode39Writer.h
        ${zxing-core}/oned/ODCode39Writer.cpp
        ${zxing-core}/oned/ODCode93Writer.h
        ${zxing-core}/oned/ODCode93Writer.cpp
        ${zxing-core}/oned/ODCode128Writer.h
        ${zxing-core}/oned/ODCode128Writer.cpp
        ${zxing-core}/oned/ODEAN8Writer.h
        ${zxing-core}/oned/ODEAN8Writer.cpp
        ${zxing-core}/oned/ODEAN13Writer.h
        ${zxing-core}/oned/ODEAN13Writer.cpp
        ${zxing-core}/oned/ODITFWriter.h
        ${zxing-core}/oned/ODITFWriter.cpp
        ${zxing-core}/oned/ODUPCEWriter.h
        ${zxing-core}/oned/ODUPCEWriter.cpp
        ${zxing-core}/oned/ODUPCAWriter.h
        ${zxing-core}/oned/ODUPCAWriter.cpp
        ${zxing-core}/oned/ODWriterHelper.h
        ${zxing-core}/oned/ODWriterHelper.cpp
    )
endif()


set (PDF417_FILES
)
if (BUILD_READERS)
    set (PDF417_FILES ${PDF417_FILES}
        ${zxing-core}/pdf417/PDFBarcodeMetadata.h
        ${zxing-core}/pdf417/PDFBarcodeValue.h
        ${zxing-core}/pdf417/PDFBarcodeValue.cpp
        ${zxing-core}/pdf417/PDFBoundingBox.h
        ${zxing-core}/pdf417/PDFBoundingBox.cpp
        ${zxing-core}/pdf417/PDFCodeword.h
        ${zxing-core}/pdf417/PDFCodewordDecoder.h
        ${zxing-core}/pdf417/PDFCodewordDecoder.cpp
        ${zxing-core}/pdf417/PDFDecodedBitStreamParser.h
        ${zxing-core}/pdf417/PDFDecodedBitStreamParser.cpp
        ${zxing-core}/pdf417/PDFDecoderResultExtra.h
        ${zxing-core}/pdf417/PDFDetectionResult.h
        ${zxing-core}/pdf417/PDFDetectionResult.cpp
        ${zxing-core}/pdf417/PDFDetectionResultColumn.h
        ${zxing-core}/pdf417/PDFDetectionResultColumn.cpp
        ${zxing-core}/pdf417/PDFDetector.h
        ${zxing-core}/pdf417/PDFDetector.cpp
        ${zxing-core}/pdf417/PDFModulusGF.h
        ${zxing-core}/pdf417/PDFModulusGF.cpp
        ${zxing-core}/pdf417/PDFModulusPoly.h
        ${zxing-core}/pdf417/PDFModulusPoly.cpp
        ${zxing-core}/pdf417/PDFReader.h
        ${zxing-core}/pdf417/PDFReader.cpp
        ${zxing-core}/pdf417/PDFScanningDecoder.h
        ${zxing-core}/pdf417/PDFScanningDecoder.cpp
    )
endif()
if (BUILD_WRITERS)
    set (PDF417_FILES ${PDF417_FILES}
        ${zxing-core}/pdf417/PDFCompaction.h
        ${zxing-core}/pdf417/PDFEncoder.h
        ${zxing-core}/pdf417/PDFEncoder.cpp
        ${zxing-core}/pdf417/PDFHighLevelEncoder.h
        ${zxing-core}/pdf417/PDFHighLevelEncoder.cpp
        ${zxing-core}/pdf417/PDFWriter.h
        ${zxing-core}/pdf417/PDFWriter.cpp
    )
endif()


set (QRCODE_FILES
    ${zxing-core}/qrcode/QRCodecMode.h
    ${zxing-core}/qrcode/QRCodecMode.cpp
    ${zxing-core}/qrcode/QRErrorCorrectionLevel.h
    ${zxing-core}/qrcode/QRErrorCorrectionLevel.cpp
    ${zxing-core}/qrcode/QRVersion.h
    ${zxing-core}/qrcode/QRVersion.cpp
)
if (BUILD_READERS)
    set (QRCODE_FILES ${QRCODE_FILES}
        ${zxing-core}/qrcode/QRBitMatrixParser.h
        ${zxing-core}/qrcode/QRBitMatrixParser.cpp
        ${zxing-core}/qrcode/QRDataBlock.h
        ${zxing-core}/qrcode/QRDataBlock.cpp
        ${zxing-core}/qrcode/QRDataMask.h
        ${zxing-core}/qrcode/QRDecoder.h
        ${zxing-core}/qrcode/QRDecoder.cpp
        ${zxing-core}/qrcode/QRDetector.h
        ${zxing-core}/qrcode/QRDetector.cpp
        ${zxing-core}/qrcode/QRECB.h
        ${zxing-core}/qrcode/QRFormatInformation.h
        ${zxing-core}/qrcode/QRFormatInformation.cpp
        ${zxing-core}/qrcode/QRReader.h
        ${zxing-core}/qrcode/QRReader.cpp
    )
endif()
if (BUILD_WRITERS)
    set (QRCODE_FILES ${QRCODE_FILES}
        ${zxing-core}/qrcode/QREncoder.h
        ${zxing-core}/qrcode/QREncoder.cpp
        ${zxing-core}/qrcode/QREncodeResult.h
        ${zxing-core}/qrcode/QRMaskUtil.h
        ${zxing-core}/qrcode/QRMaskUtil.cpp
        ${zxing-core}/qrcode/QRMatrixUtil.h
        ${zxing-core}/qrcode/QRMatrixUtil.cpp
        ${zxing-core}/qrcode/QRWriter.h
        ${zxing-core}/qrcode/QRWriter.cpp
    )
endif()


set (TEXT_CODEC_FILES
    ${zxing-core}/textcodec/Big5MapTable.h
    ${zxing-core}/textcodec/Big5MapTable.cpp
    ${zxing-core}/textcodec/KRHangulMapping.h
    ${zxing-core}/textcodec/KRHangulMapping.cpp
)
if (BUILD_READERS)
    set (TEXT_CODEC_FILES ${TEXT_CODEC_FILES}
        ${zxing-core}/textcodec/Big5TextDecoder.h
        ${zxing-core}/textcodec/Big5TextDecoder.cpp
        ${zxing-core}/textcodec/GBTextDecoder.h
        ${zxing-core}/textcodec/GBTextDecoder.cpp
        ${zxing-core}/textcodec/JPTextDecoder.h
        ${zxing-core}/textcodec/JPTextDecoder.cpp
        ${zxing-core}/textcodec/KRTextDecoder.h
        ${zxing-core}/textcodec/KRTextDecoder.cpp
    )
endif()
if (BUILD_WRITERS)
    set (TEXT_CODEC_FILES ${TEXT_CODEC_FILES}
        ${zxing-core}/textcodec/Big5TextEncoder.h
        ${zxing-core}/textcodec/Big5TextEncoder.cpp
        ${zxing-core}/textcodec/GBTextEncoder.h
        ${zxing-core}/textcodec/GBTextEncoder.cpp
        ${zxing-core}/textcodec/JPTextEncoder.h
        ${zxing-core}/textcodec/JPTextEncoder.cpp
        ${zxing-core}/textcodec/KRTextEncoder.h
        ${zxing-core}/textcodec/KRTextEncoder.cpp
    )
endif()

source_group (Sources FILES ${COMMON_FILES})
source_group (Sources\\aztec FILES ${AZTEC_FILES})
source_group (Sources\\datamatrix FILES ${DATAMATRIX_FILES})
source_group (Sources\\maxicode FILES ${MAXICODE_FILES})
source_group (Sources\\oned FILES ${ONED_FILES})
source_group (Sources\\pdf417 FILES ${PDF417_FILES})
source_group (Sources\\qrcode FILES ${QRCODE_FILES})
source_group (Sources\\textcodec FILES ${TEXT_CODEC_FILES})

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

add_library (ZXing
    ${COMMON_FILES}
    ${AZTEC_FILES}
    ${DATAMATRIX_FILES}
    ${MAXICODE_FILES}
    ${ONED_FILES}
    ${PDF417_FILES}
    ${QRCODE_FILES}
    ${TEXT_CODEC_FILES}
)

target_include_directories (ZXing
    PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/${zxing-core}>"
    INTERFACE "$<INSTALL_INTERFACE:include>"
)

target_compile_options (ZXing
    PUBLIC ${ZXING_CORE_DEFINES}
    PRIVATE ${ZXING_CORE_LOCAL_DEFINES}
)

include (CheckCXXCompilerFlag)

CHECK_CXX_COMPILER_FLAG ("-ffloat-store" COMPILER_NEEDS_FLOAT_STORE)
if (COMPILER_NEEDS_FLOAT_STORE)
    target_compile_options(ZXing PRIVATE
        -ffloat-store   # same floating point precision in all optimization levels
    )
endif()

# the lib needs a c++-17 compiler but can be used with a c++-11 compiler (see examples)
target_compile_features(ZXing PRIVATE cxx_std_17 INTERFACE cxx_std_11)

target_link_libraries (ZXing PRIVATE Threads::Threads)
