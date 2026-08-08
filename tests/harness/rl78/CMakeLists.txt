add_library(harness_arch STATIC
    target.c
)
target_include_directories(harness_arch PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
)
set_property(TARGET harness_arch PROPERTY C_STANDARD 11)
