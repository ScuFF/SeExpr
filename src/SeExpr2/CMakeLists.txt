# Copyright Disney Enterprises, Inc.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License
# and the following modification to it: Section 6 Trademarks.
# deleted and replaced with:
#
# 6. Trademarks. This License does not grant permission to use the
# trade names, trademarks, service marks, or product names of the
# Licensor and its affiliates, except as required for reproducing
# the content of the NOTICE file.
#
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

# Source files for llvm supported library and interpreter library
file(GLOB io_cpp "*.cpp")
file(GLOB to_remove "ExprLLVMCodeGeneration.cpp")
list(REMOVE_ITEM io_cpp ${to_remove})

set_source_files_properties("ExprBuiltins.cpp" PROPERTIES COMPILE_DEFINITIONS "__STDC_LIMIT_MACROS")

# Uncomment below to print debug messages / performance stats
#add_definitions(-DSEEXPR_DEBUG)
#add_definitions(-DSEEXPR_PERFORMANCE)

# Allow flex/bison to find the current directory
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

# Generate into the build tree when tools are available; otherwise use the
# checked-in parser payload. Core and UI share the same generation rules.
BuildParserScanner(ExprParserLex ExprParser SeExpr2 parser_cpp SeExpr)


## Make the SeExpr library with and without LLVM support
file(GLOB llvm_cpp "*.cpp")
# Preserve the established SeExpr2 target: static on Windows, shared elsewhere.
add_library(${seexpr_static_engine} STATIC ${io_cpp} ${core_cpp} ${parser_cpp} ${llvm_cpp})
add_library(${seexpr_shared_engine} SHARED ${io_cpp} ${core_cpp} ${parser_cpp} ${llvm_cpp})
target_compile_definitions(${seexpr_static_engine} PUBLIC SEEXPR2_STATIC_DEFINE)
set_target_properties(${seexpr_shared_engine} PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
seexpr_set_runtime_output(${seexpr_shared_engine})
if (NOT WIN32)
    set_target_properties(${seexpr_static_engine} PROPERTIES POSITION_INDEPENDENT_CODE ON)
    target_link_libraries(${seexpr_static_engine} "dl" "pthread")
    target_link_libraries(${seexpr_shared_engine} PRIVATE "dl" "pthread")
endif()

foreach(linkage STATIC SHARED)
    if(linkage STREQUAL STATIC)
        set(engine ${seexpr_static_engine})
    else()
        set(engine ${seexpr_shared_engine})
    endif()
    set_target_properties(${engine} PROPERTIES
        VERSION ${seexpr2_VERSION} SOVERSION ${seexpr2_MAJOR_VERSION}
        INTERFACE_SeExpr2_MAJOR_VERSION ${seexpr2_MAJOR_VERSION}
        INTERFACE_SeExpr2_LINKAGE ${linkage})
    set_property(TARGET ${engine} APPEND PROPERTY
        COMPATIBLE_INTERFACE_STRING SeExpr2_MAJOR_VERSION SeExpr2_LINKAGE)
    target_include_directories(${engine} PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
endforeach()

generate_export_header(${seexpr_shared_engine} BASE_NAME SeExpr2 EXPORT_FILE_NAME seexpr2_export.h)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/seexpr2_export.h"
        COMPONENT devel DESTINATION ${INCLUDE_DIR})

install(TARGETS ${seexpr_static_engine} EXPORT ${PROJECT_NAME}
        DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(TARGETS ${seexpr_shared_engine} EXPORT ${PROJECT_NAME}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR})

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
        COMPONENT devel DESTINATION ${INCLUDE_DIR}
        FILES_MATCHING PATTERN "*.h")

configure_file("ExprConfig.h.in" "ExprConfig.h")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/ExprConfig.h"
        COMPONENT devel DESTINATION ${INCLUDE_DIR})

include_directories(${CMAKE_CURRENT_BINARY_DIR})

if (ENABLE_LLVM_BACKEND)
    # Public expression headers include LLVM headers. Propagate them to
    # build-tree consumers; the installed package discovers its own LLVM.
    foreach(engine ${seexpr_static_engine} ${seexpr_shared_engine})
        target_include_directories(${engine} INTERFACE "$<BUILD_INTERFACE:${LLVM_INCLUDE_DIR}>")
    endforeach()
    # LLVM stays private to the shared engine; applications link only its API.
    target_link_libraries(${seexpr_shared_engine} PRIVATE ${LLVM_LIB})
    if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        # PRIVATE controls CMake usage requirements, not ELF symbol exports.
        # A graphics driver/plugin may load a different LLVM into this process.
        # Keep statically linked archive symbols local to this shared engine.
        target_link_options(${seexpr_shared_engine} PRIVATE "LINKER:--exclude-libs,ALL")
        set_target_properties(${seexpr_shared_engine} PROPERTIES VISIBILITY_INLINES_HIDDEN YES)
        # Debug builds also emit non-inline LLVM template instantiations in
        # SeExpr objects. Archive exclusion/inline visibility cannot hide those.
        # Localize the LLVM namespace while retaining the existing SeExpr API.
        set(llvm_export_map "${PROJECT_SOURCE_DIR}/src/build/llvm-private.map")
        target_link_options(${seexpr_shared_engine} PRIVATE "LINKER:--version-script=${llvm_export_map}")
        set_property(TARGET ${seexpr_shared_engine} APPEND PROPERTY LINK_DEPENDS "${llvm_export_map}")
        # Public headers expose LLVM types, but shared consumers do not
        # link LLVM Support. Suppress its header-only link probe for consumers;
        # the engine itself retains LLVM's ABI checks against its private SDK.
        target_compile_definitions(${seexpr_shared_engine} INTERFACE LLVM_DISABLE_ABI_BREAKING_CHECKS_ENFORCING=1)
    endif()
    if (NOT WIN32)
        target_link_libraries(${seexpr_static_engine} ${LLVM_LIB} "dl" "pthread")
    else ()
        target_link_libraries(${seexpr_static_engine} ${LLVM_LIB})
    endif ()
endif()
