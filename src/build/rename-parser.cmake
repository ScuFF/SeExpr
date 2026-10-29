# Preserve the legacy symbol-prefix transformation without shell pipelines or
# writes to the source checkout. All arguments/output paths come from CMake.
cmake_minimum_required(VERSION 3.16)
foreach(argument input output prefix header)
    if(NOT DEFINED ${argument} OR "${${argument}}" STREQUAL "")
        message(FATAL_ERROR "Missing parser transformation argument: ${argument}")
    endif()
endforeach()
file(READ "${input}" content)
string(REPLACE "yy" "${prefix}" content "${content}")
string(REPLACE "YY" "${prefix}YY" content "${content}")
# Recent Bison emits an include of its raw header; use the transformed header
# so token/type names agree with the prefixed parser and scanner.
string(REPLACE "\"y.tab.h\"" "\"${header}\"" content "${content}")
file(WRITE "${output}" "${content}")
