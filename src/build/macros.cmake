# Parser generation never updates the source checkout. The checked-in payload
# remains the fallback for developer machines without Bison/Flex.
set(SEEXPR_PARSER_RENAME_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/rename-parser.cmake")
macro(BuildParserScanner FLEX_L_PREFIX BISON_Y_PREFIX PARSER_PREFIX GENERATED_CPPS PREGENERATED_PREFIX)
    find_program(BISON_EXE bison)
    find_program(FLEX_EXE flex)
    if(NOT BISON_EXE OR NOT FLEX_EXE)
        set(${GENERATED_CPPS}
            "${PREGENERATED_ROOT}/${PREGENERATED_PREFIX}/generated/${BISON_Y_PREFIX}.cpp"
            "${PREGENERATED_ROOT}/${PREGENERATED_PREFIX}/generated/${FLEX_L_PREFIX}.cpp")
    else()
        set(parser_directory "${CMAKE_CURRENT_BINARY_DIR}")
        add_custom_command(OUTPUT "${parser_directory}/${FLEX_L_PREFIX}In.cpp"
            COMMAND "${FLEX_EXE}" "-o${FLEX_L_PREFIX}In.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/${FLEX_L_PREFIX}.l"
            WORKING_DIRECTORY "${parser_directory}"
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${FLEX_L_PREFIX}.l" "${FLEX_EXE}" VERBATIM)
        add_custom_command(OUTPUT "${parser_directory}/y.tab.c" "${parser_directory}/y.tab.h"
            COMMAND "${BISON_EXE}" --defines --verbose --fixed-output-files
                -p "${PARSER_PREFIX}" "${CMAKE_CURRENT_SOURCE_DIR}/${BISON_Y_PREFIX}.y"
            WORKING_DIRECTORY "${parser_directory}"
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${BISON_Y_PREFIX}.y" "${BISON_EXE}" VERBATIM)
        foreach(parser_pair "${FLEX_L_PREFIX}In.cpp|${FLEX_L_PREFIX}.cpp"
                "y.tab.h|${BISON_Y_PREFIX}.tab.h" "y.tab.c|${BISON_Y_PREFIX}.cpp")
            string(REPLACE "|" ";" parser_pair "${parser_pair}")
            list(GET parser_pair 0 parser_input)
            list(GET parser_pair 1 parser_output)
            add_custom_command(OUTPUT "${parser_directory}/${parser_output}"
                COMMAND "${CMAKE_COMMAND}" "-Dinput=${parser_directory}/${parser_input}"
                    "-Doutput=${parser_directory}/${parser_output}" "-Dprefix=${PARSER_PREFIX}"
                    "-Dheader=${BISON_Y_PREFIX}.tab.h"
                    -P "${SEEXPR_PARSER_RENAME_SCRIPT}"
                DEPENDS "${parser_directory}/${parser_input}" "${SEEXPR_PARSER_RENAME_SCRIPT}"
                VERBATIM)
        endforeach()
        # The scanner and parser include the renamed header. Declare the edge
        # before either is compiled, including with parallel build executors.
        set_source_files_properties("${parser_directory}/${FLEX_L_PREFIX}.cpp"
            "${parser_directory}/${BISON_Y_PREFIX}.cpp" PROPERTIES
            OBJECT_DEPENDS "${parser_directory}/${BISON_Y_PREFIX}.tab.h")
        include_directories("${parser_directory}")
        set(${GENERATED_CPPS} "${parser_directory}/${FLEX_L_PREFIX}.cpp"
            "${parser_directory}/${BISON_Y_PREFIX}.cpp")
    endif()
endmacro()
