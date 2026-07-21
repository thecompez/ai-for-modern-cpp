if(NOT DEFINED AIMCPP_SOURCE_DIR OR NOT DEFINED AIMCPP_TEST_BINARY_DIR)
    message(FATAL_ERROR "AIMCPP_SOURCE_DIR and AIMCPP_TEST_BINARY_DIR are required.")
endif()

include("${AIMCPP_SOURCE_DIR}/cmake/AimcppImportStd.cmake")

file(REMOVE_RECURSE "${AIMCPP_TEST_BINARY_DIR}")

set(metadataDirectory
    "${AIMCPP_TEST_BINARY_DIR}/lib/gcc/aarch64-linux-gnu/15"
)
set(moduleSourceDirectory
    "${AIMCPP_TEST_BINARY_DIR}/include/c++/15/bits"
)

file(MAKE_DIRECTORY "${metadataDirectory}" "${moduleSourceDirectory}")
file(WRITE "${moduleSourceDirectory}/std.cc" "export module std;\n")
file(WRITE "${moduleSourceDirectory}/std.compat.cc" "export module std.compat;\n")

set(brokenMetadataPath "${metadataDirectory}/libstdc++.modules.json")
file(WRITE "${brokenMetadataPath}" [=[
{
  "version": 1,
  "revision": 1,
  "modules": [
    {
      "logical-name": "std",
      "source-path": "../broken/path/std.cc",
      "is-std-library": true
    },
    {
      "logical-name": "std.compat",
      "source-path": "../broken/path/std.compat.cc",
      "is-std-library": true
    }
  ]
}
]=])

set(repairedMetadataPath "${AIMCPP_TEST_BINARY_DIR}/repaired.modules.json")

aimcpp_repair_gnu_stdlib_metadata(
    "${brokenMetadataPath}"
    "15"
    "${repairedMetadataPath}"
    selectedMetadataPath
)

if(NOT selectedMetadataPath STREQUAL repairedMetadataPath)
    message(FATAL_ERROR "Broken metadata was not replaced with repaired metadata.")
endif()

file(READ "${selectedMetadataPath}" repairedMetadata)

foreach(moduleIndex RANGE 0 1)
    string(JSON repairedSourcePath GET "${repairedMetadata}" modules ${moduleIndex} source-path)

    if(NOT IS_ABSOLUTE "${repairedSourcePath}" OR NOT EXISTS "${repairedSourcePath}")
        message(FATAL_ERROR
            "Repaired module source is not an existing absolute path: ${repairedSourcePath}"
        )
    endif()
endforeach()

message(STATUS "Broken GCC module metadata repair verified.")
