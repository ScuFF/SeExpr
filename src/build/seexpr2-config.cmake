@PACKAGE_INIT@

# LLVM is exposed by public expression headers, even for shared consumers.
# Resolve the dependency in the consumer's environment, without recording a
# particular workspace's SDK location in this package.
if(@SEEXPR_ENABLE_LLVM_BACKEND@)
    include(CMakeFindDependencyMacro)
    find_dependency(LLVM CONFIG)
endif()

include("${CMAKE_CURRENT_LIST_DIR}/@PROJECT_NAME@-exports.cmake")

if(@SEEXPR_ENABLE_LLVM_BACKEND@)
    foreach(engine @seexpr_static_engine@ @seexpr_shared_engine@)
        set_property(TARGET @PROJECT_NAME@::${engine} APPEND PROPERTY
            INTERFACE_INCLUDE_DIRECTORIES "${LLVM_INCLUDE_DIRS}")
    endforeach()
endif()

set(@PROJECT_NAME@_FOUND TRUE)
