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

# Default discovery exposes editors when their dependencies are available.
# COMPONENTS Editor makes that dependency mandatory. Engine-only consumers can
# use COMPONENTS Engine without requiring or probing for Qt.
set(@PROJECT_NAME@_Engine_FOUND TRUE)
set(@PROJECT_NAME@_Editor_FOUND FALSE)
if("Editor" IN_LIST @PROJECT_NAME@_FIND_COMPONENTS OR NOT @PROJECT_NAME@_FIND_COMPONENTS)
    if("@SEEXPR_PACKAGE_EDITOR_QT@" STREQUAL "Qt5")
        find_package(Qt5 QUIET COMPONENTS Core Gui Widgets OpenGL)
        set(@PROJECT_NAME@_Editor_FOUND "${Qt5_FOUND}")
    elseif("@SEEXPR_PACKAGE_EDITOR_QT@" STREQUAL "Qt4")
        find_package(Qt4 QUIET COMPONENTS QtCore QtGui QtOpenGL)
        set(@PROJECT_NAME@_Editor_FOUND "${QT4_FOUND}")
    endif()
    if(@PROJECT_NAME@_Editor_FOUND)
        include("${CMAKE_CURRENT_LIST_DIR}/@PROJECT_NAME@-editor-exports.cmake")
    endif()
endif()
set(@PROJECT_NAME@_FOUND TRUE)
check_required_components(@PROJECT_NAME@)
