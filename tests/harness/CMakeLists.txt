# Common instruction-test harness; arch glue via add_subdirectory(<arch>).
set(HARNESS_ARCH_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_ACTUAL_ARCH}")
if(NOT EXISTS "${HARNESS_ARCH_DIR}/CMakeLists.txt")
    return()
endif()

add_subdirectory(${TARGET_ACTUAL_ARCH})

add_executable(tlib-harness
    main.c
    harness.c
    elf.c
)
target_include_directories(tlib-harness PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/arch/${TARGET_ACTUAL_ARCH}
)
target_link_libraries(tlib-harness PRIVATE tlib harness_arch)
set_property(TARGET tlib-harness PROPERTY C_STANDARD 11)
set_target_properties(tlib-harness PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
