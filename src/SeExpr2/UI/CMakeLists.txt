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

if (EXISTS "/usr/share/apps/cmake/modules")
    # Needed for some versions of CMake, which only look in version-specific module path
    list(APPEND CMAKE_MODULE_PATH "/usr/share/apps/cmake/modules")
endif()

# Other package dependencies...
find_package(OpenGL)

if (Qt5_FOUND OR QT4_FOUND)

    BuildParserScanner(ExprSpecParserLex ExprSpecParser ExprSpec
                       editor_parser_cpp ui)

    set(EDITOR_MOC_HDRS ExprBrowser.h ExprColorCurve.h
        ExprColorSwatch.h ExprControlCollection.h
        ExprControl.h ExprCurve.h ExprDialog.h ExprEditor.h
        ExprFileDialog.h ExprGrapher2d.h ExprPopupDoc.h
        ExprShortEdit.h ExprDeepWater.h)

    set(EDITOR_CPPS ExprFileDialog.cpp ExprControl.cpp
        ExprEditor.cpp ExprMain.cpp ExprShortEdit.cpp
        ExprCurve.cpp  ExprColorCurve.cpp ExprColorSwatch.cpp
        EditableExpression.cpp ExprPopupDoc.cpp
        ExprCompletionModel.cpp ExprDialog.cpp
        ExprControlCollection.cpp ExprGrapher2d.cpp ExprBrowser.cpp
        BasicExpression.cpp ExprDeepWater.cpp)

    if (ENABLE_QT5)
        qt5_wrap_cpp(EDITOR_MOC_SRCS ${EDITOR_MOC_HDRS})
    else()
        qt4_wrap_cpp(EDITOR_MOC_SRCS ${EDITOR_MOC_HDRS})
    endif()

    set(ANIMLIB_SRCS "")
    if (DEFINED ANIMLIB_DIR)
        set(CE_MOC_HDRS CE/CECurveListUI.h CE/CEDragHandlers.h CE/CEGraphCurve.h
            CE/CEGraphKey.h CE/CEGraphSeg.h CE/CEGraphUI.h CE/CEMainUI.h
            CE/CESegEditUI.h CE/CETool.h)

        set(CE_CPPS CE/CECurveListUI.cpp CE/CEDragHandlers.cpp CE/CEGraphCurve.cpp
            CE/CEGraphKey.cpp CE/CEGraphSeg.cpp CE/CEGraphUI.cpp CE/CEMainUI.cpp
            CE/CESegEditUI.cpp CE/CETool.cpp)

        if (ENABLE_QT5)
            qt5_wrap_cpp(CE_MOC_SRCS ${CE_MOC_HDRS})
        else()
            qt4_wrap_cpp(CE_MOC_SRCS ${CE_MOC_HDRS})
        endif()
        set(ANIMLIB_SRCS "${CE_CPPS} ${CE_MOC_SRCS}")
    endif()

    if (WIN32)
        add_library(SeExpr2Editor ${EDITOR_CPPS} ${EDITOR_MOC_SRCS}
                    ${ANIMLIB_SRCS}
                    ${editor_parser_cpp})
        generate_export_header(SeExpr2Editor
                               BASE_NAME SeExpr2Editor
                               EXPORT_MACRO_NAME SeExpr2Editor
                               EXPORT_FILE_NAME SeExpr2Editor_Export.h
                               STATIC_DEFINE SeExpr2Editor_BUILT_AS_STATIC )
    else()
        add_library(SeExpr2Editor SHARED ${EDITOR_CPPS} ${EDITOR_MOC_SRCS}
                    ${ANIMLIB_SRCS}
                    ${editor_parser_cpp})
    endif()

    set_property(TARGET SeExpr2Editor PROPERTY VERSION ${seexpr2_VERSION})
    set_property(TARGET SeExpr2Editor PROPERTY SOVERSION 3)
    set_property(TARGET SeExpr2Editor PROPERTY
                 INTERFACE_SeExpr2Editor_MAJOR_VERSION ${seexpr2_MAJOR_VERSION})
    set_property(TARGET SeExpr2Editor APPEND PROPERTY
                 COMPATIBLE_INTERFACE_STRING ${seexpr2_MAJOR_VERSION})

    include_directories(${CMAKE_CURRENT_BINARY_DIR}/../SeExpr2)
    include_directories(${CMAKE_CURRENT_BINARY_DIR}/..)
    include_directories(${CMAKE_CURRENT_SOURCE_DIR})
    target_link_libraries(SeExpr2Editor SeExpr2)

    if (ENABLE_QT5)
        target_link_libraries(SeExpr2Editor Qt5::Core)
        target_link_libraries(SeExpr2Editor Qt5::Gui)
        target_link_libraries(SeExpr2Editor Qt5::Widgets)
        target_link_libraries(SeExpr2Editor Qt5::OpenGL)
    else()
        target_link_libraries(SeExpr2Editor ${QT_QTCORE_LIBRARY})
        target_link_libraries(SeExpr2Editor ${QT_QTGUI_LIBRARY})
        target_link_libraries(SeExpr2Editor ${QT_QTOPENGL_LIBRARY})
    endif()
    target_link_libraries(SeExpr2Editor ${OPENGL_LIBRARY})
    target_link_libraries(SeExpr2Editor ${GLUT_LIBRARY})

    if (DEFINED ANIMLIB_DIR)
        include_directories(${CMAKE_CURRENT_SOURCE_DIR}/CE)
        target_link_libraries(SeExpr2Editor animlib)
    endif()

    if (DEFINED DERR_DIR)
        target_link_libraries(SeExpr2Editor DErr)
    endif()

    if (DEFINED DMSG_DIR)
        target_link_libraries(SeExpr2Editor DMsg)
    endif()

    if (DEFINED QDGUI_DIR)
        target_link_libraries(SeExpr2Editor qdcolorwidgets)
    endif()

    if (WIN32)
        target_link_libraries(SeExpr2Editor opengl32)
    endif()

    ## Install library and includes
    install(TARGETS SeExpr2Editor
            EXPORT ${PROJECT_NAME}
            DESTINATION ${CMAKE_INSTALL_LIBDIR})

    # The editor object code must match its engine's data import definitions.
    # The alternate editor library uses the other engine linkage, without
    # mixing both engines in a single executable or Python module.
    if(WIN32)
        set(alternate_editor ${seexpr_shared_editor})
        set(alternate_engine ${seexpr_shared_engine})
    else()
        set(alternate_editor ${seexpr_static_editor})
        set(alternate_engine ${seexpr_static_engine})
    endif()
    get_target_property(editor_sources SeExpr2Editor SOURCES)
    get_target_property(editor_type SeExpr2Editor TYPE)
    if(editor_type STREQUAL "STATIC_LIBRARY")
        add_library(${alternate_editor} STATIC ${editor_sources})
    else()
        add_library(${alternate_editor} SHARED ${editor_sources})
    endif()
    get_target_property(editor_libraries SeExpr2Editor LINK_LIBRARIES)
    list(TRANSFORM editor_libraries REPLACE "^SeExpr2$" "${alternate_engine}")
    target_link_libraries(${alternate_editor} ${editor_libraries})
    install(TARGETS ${alternate_editor} EXPORT ${PROJECT_NAME}
            DESTINATION ${CMAKE_INSTALL_LIBDIR})

    seexpr_set_runtime_output(SeExpr2Editor)
    seexpr_set_runtime_output(${alternate_editor})

    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/
            DESTINATION ${INCLUDE_DIR}/UI
            FILES_MATCHING PATTERN "*.h")

    option(USE_QT_PYTHON "Build Qt Python bindings" ${USE_PYTHON})
    if(USE_PYTHON AND USE_QT_PYTHON)
        if (NOT ENABLE_QT5)
            message(FATAL_ERROR "Modern Qt Python bindings require Qt5/PyQt5")
        endif()

        set(UI_BINDING_GENERATOR "${PROJECT_SOURCE_DIR}/src/build/generate_ui_bindings.py")
        execute_process(
            COMMAND "${PYTHON_EXECUTABLE}" "${UI_BINDING_GENERATOR}" --check
            RESULT_VARIABLE UI_BINDING_CHECK
            OUTPUT_VARIABLE PYQT_BINDINGS_DIR
            ERROR_VARIABLE UI_BINDING_ERROR
            OUTPUT_STRIP_TRAILING_WHITESPACE)
        if (NOT UI_BINDING_CHECK EQUAL 0)
            message(FATAL_ERROR "Cannot generate Qt Python bindings: ${UI_BINDING_ERROR}")
        endif()

        set(UI_SIP_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/sip")
        set(UI_SIP_GENERATED_DIR "${UI_SIP_BUILD_DIR}/generated")
        set(UI_SIP_CPP "${UI_SIP_GENERATED_DIR}/expreditor2/sipexpreditor2part0.cpp")
        file(GLOB_RECURSE PYQT_BINDING_INPUTS "${PYQT_BINDINGS_DIR}/*.sip" "${PYQT_BINDINGS_DIR}/*.toml")
        add_custom_command(
            OUTPUT "${UI_SIP_CPP}" "${UI_SIP_GENERATED_DIR}/expreditor2/sipAPIexpreditor2.h" "${UI_SIP_GENERATED_DIR}/sip.h"
            COMMAND "${PYTHON_EXECUTABLE}" "${UI_BINDING_GENERATOR}"
                    --sip-file "${CMAKE_CURRENT_SOURCE_DIR}/SeExpr2Editor.sip"
                    --build-dir "${UI_SIP_BUILD_DIR}"
            DEPENDS "${UI_BINDING_GENERATOR}" SeExpr2Editor.sip ${PYQT_BINDING_INPUTS}
            COMMENT "Generating Qt editor bindings with SIP 6"
            VERBATIM)

        add_library(expreditor2 MODULE "${UI_SIP_CPP}")
        target_compile_features(expreditor2 PRIVATE cxx_std_17)
        target_include_directories(expreditor2 PRIVATE
            "${UI_SIP_GENERATED_DIR}" "${PYTHON_INCLUDE_DIRS}")
        target_link_libraries(expreditor2
            Qt5::Core Qt5::Gui Qt5::Widgets Qt5::OpenGL ${PYTHON_LIBRARIES})
        seexpr_link_engine(expreditor2 EDITOR)
        set_target_properties(expreditor2 PROPERTIES PREFIX "")
        if (WIN32)
            set_target_properties(expreditor2 PROPERTIES SUFFIX ".pyd")
        elseif(APPLE)
            set_target_properties(expreditor2 PROPERTIES SUFFIX ".so")
        endif()

        set(CMAKE_INSTALL_PYTHON "${CMAKE_INSTALL_LIBDIR}/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages/SeExpr2"
            CACHE STRING "Relative install directory for the Qt Python bindings")
        install(TARGETS expreditor2 DESTINATION "${CMAKE_INSTALL_PYTHON}")
        install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/__init__.py"
                DESTINATION "${CMAKE_INSTALL_PYTHON}")
        if (BUILD_TESTS)
            add_test(NAME qtPythonBindings
                COMMAND "${PYTHON_EXECUTABLE}" "${PROJECT_SOURCE_DIR}/src/tests/qtPythonBindings.py"
                        --module-dir "$<TARGET_FILE_DIR:expreditor2>")
        endif()
    endif()
endif()
