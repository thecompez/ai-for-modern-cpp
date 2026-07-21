include_guard(GLOBAL)

function(
    _aimcpp_find_gnu_module_source
    metadataDirectory
    compilerMajorVersion
    sourceFileName
    outputVariable
)
    set(searchRoots "${metadataDirectory}")
    set(currentDirectory "${metadataDirectory}")

    foreach(_parentIndex RANGE 0 6)
        list(APPEND searchRoots "${currentDirectory}")
        get_filename_component(currentDirectory "${currentDirectory}/.." ABSOLUTE)
    endforeach()

    set(candidatePaths)

    foreach(searchRoot IN LISTS searchRoots)
        list(APPEND candidatePaths
            "${searchRoot}/include/c++/${compilerMajorVersion}/bits/${sourceFileName}"
        )
    endforeach()

    if(UNIX)
        list(APPEND candidatePaths
            "/usr/include/c++/${compilerMajorVersion}/bits/${sourceFileName}"
            "/usr/local/include/c++/${compilerMajorVersion}/bits/${sourceFileName}"
        )
    endif()

    foreach(candidatePath IN LISTS candidatePaths)
        if(EXISTS "${candidatePath}")
            file(REAL_PATH "${candidatePath}" resolvedCandidatePath)
            set(${outputVariable} "${resolvedCandidatePath}" PARENT_SCOPE)
            return()
        endif()
    endforeach()

    set(${outputVariable} "" PARENT_SCOPE)
endfunction()

function(
    aimcpp_repair_gnu_stdlib_metadata
    metadataPath
    compilerMajorVersion
    repairedMetadataPath
    outputVariable
)
    if(NOT EXISTS "${metadataPath}")
        message(FATAL_ERROR
            "GCC reported libstdc++ module metadata that does not exist:\n"
            "  ${metadataPath}\n"
            "Install the matching libstdc++ development package for GCC ${compilerMajorVersion}."
        )
    endif()

    file(REAL_PATH "${metadataPath}" canonicalMetadataPath)
    get_filename_component(metadataDirectory "${canonicalMetadataPath}" DIRECTORY)
    file(READ "${canonicalMetadataPath}" metadataJson)

    string(
        JSON moduleCount
        ERROR_VARIABLE metadataError
        LENGTH "${metadataJson}" modules
    )

    if(NOT metadataError STREQUAL "NOTFOUND" OR moduleCount EQUAL 0)
        message(FATAL_ERROR
            "Invalid libstdc++ module metadata:\n"
            "  ${canonicalMetadataPath}\n"
            "JSON error: ${metadataError}"
        )
    endif()

    set(requiresRepair OFF)
    math(EXPR lastModuleIndex "${moduleCount} - 1")

    foreach(moduleIndex RANGE 0 ${lastModuleIndex})
        string(
            JSON sourcePath
            ERROR_VARIABLE sourcePathError
            GET "${metadataJson}" modules ${moduleIndex} source-path
        )

        if(NOT sourcePathError STREQUAL "NOTFOUND")
            message(FATAL_ERROR
                "libstdc++ module metadata entry ${moduleIndex} has no valid source-path:\n"
                "  ${canonicalMetadataPath}\n"
                "JSON error: ${sourcePathError}"
            )
        endif()

        if(IS_ABSOLUTE "${sourcePath}")
            set(candidateSourcePath "${sourcePath}")
        else()
            set(candidateSourcePath "${metadataDirectory}/${sourcePath}")
        endif()

        if(EXISTS "${candidateSourcePath}")
            file(REAL_PATH "${candidateSourcePath}" resolvedSourcePath)
        else()
            get_filename_component(sourceFileName "${sourcePath}" NAME)
            _aimcpp_find_gnu_module_source(
                "${metadataDirectory}"
                "${compilerMajorVersion}"
                "${sourceFileName}"
                resolvedSourcePath
            )
        endif()

        if(NOT resolvedSourcePath)
            message(FATAL_ERROR
                "libstdc++ module metadata points to a missing source:\n"
                "  metadata: ${canonicalMetadataPath}\n"
                "  source-path: ${sourcePath}\n"
                "The active GCC/libstdc++ package is incomplete or incompatible. "
                "Install matching GCC ${compilerMajorVersion} and libstdc++ development packages."
            )
        endif()

        if(NOT sourcePath STREQUAL resolvedSourcePath)
            string(
                JSON metadataJson
                SET "${metadataJson}"
                modules ${moduleIndex} source-path
                "\"${resolvedSourcePath}\""
            )
            set(requiresRepair ON)
        endif()
    endforeach()

    if(requiresRepair)
        get_filename_component(repairedMetadataDirectory "${repairedMetadataPath}" DIRECTORY)
        file(MAKE_DIRECTORY "${repairedMetadataDirectory}")
        file(WRITE "${repairedMetadataPath}" "${metadataJson}\n")
        set(${outputVariable} "${repairedMetadataPath}" PARENT_SCOPE)
    else()
        set(${outputVariable} "${canonicalMetadataPath}" PARENT_SCOPE)
    endif()
endfunction()

function(aimcpp_prepare_gnu_import_std outputVariable)
    if(CMAKE_CXX_COMPILER)
        set(candidateCompiler "${CMAKE_CXX_COMPILER}")
    elseif(DEFINED ENV{CXX} AND NOT "$ENV{CXX}" STREQUAL "")
        set(candidateCompiler "$ENV{CXX}")
    else()
        find_program(candidateCompiler NAMES g++ c++)
    endif()

    if(NOT candidateCompiler)
        set(${outputVariable} "" PARENT_SCOPE)
        return()
    endif()

    execute_process(
        COMMAND "${candidateCompiler}" --version
        OUTPUT_VARIABLE compilerVersionText
        ERROR_VARIABLE compilerVersionError
        RESULT_VARIABLE compilerVersionResult
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(compilerVersionResult OR NOT compilerVersionText MATCHES "(g\\+\\+|GCC|Free Software Foundation)")
        set(${outputVariable} "" PARENT_SCOPE)
        return()
    endif()

    if(CMAKE_VERSION VERSION_LESS "4.0.0")
        message(FATAL_ERROR
            "GCC import std requires CMake 4.0 or newer.\n"
            "Active CMake: ${CMAKE_VERSION}\n"
            "Active compiler: ${candidateCompiler}\n"
            "CMake 3.30/3.31 supports Clang and MSVC import std, but not GCC/libstdc++.\n"
            "Install CMake 4.x, remove the old build directory, and configure again with Ninja."
        )
    endif()

    execute_process(
        COMMAND "${candidateCompiler}" -dumpfullversion
        OUTPUT_VARIABLE compilerFullVersion
        ERROR_VARIABLE compilerFullVersionError
        RESULT_VARIABLE compilerFullVersionResult
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(compilerFullVersionResult OR NOT compilerFullVersion MATCHES "^([0-9]+)")
        message(FATAL_ERROR
            "Could not determine the GCC version from ${candidateCompiler}: "
            "${compilerFullVersionError}"
        )
    endif()

    set(compilerMajorVersion "${CMAKE_MATCH_1}")

    if(compilerMajorVersion VERSION_LESS "15")
        message(FATAL_ERROR
            "GCC import std requires GCC 15 or newer.\n"
            "Active compiler: ${candidateCompiler}\n"
            "Active GCC version: ${compilerFullVersion}"
        )
    endif()

    if(compilerMajorVersion VERSION_GREATER_EQUAL "16"
        AND CMAKE_VERSION VERSION_LESS "4.4.0"
    )
        message(FATAL_ERROR
            "GCC ${compilerFullVersion} is newer than the GNU modules integration verified by "
            "CMake ${CMAKE_VERSION}.\n"
            "Observed failure: CMake 4.3 accepts GCC 16 metadata but its scanner does not "
            "recognize the GCC 16 std module interface.\n"
            "Use GCC 15.x with CMake 4.0-4.3, or use a CMake release that explicitly supports "
            "the active GCC major version."
        )
    endif()

    if(CMAKE_CXX_STDLIB_MODULES_JSON)
        set(metadataPath "${CMAKE_CXX_STDLIB_MODULES_JSON}")
    else()
        execute_process(
            COMMAND "${candidateCompiler}" -print-file-name=libstdc++.modules.json
            OUTPUT_VARIABLE metadataPath
            ERROR_VARIABLE metadataPathError
            RESULT_VARIABLE metadataPathResult
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        if(metadataPathResult OR metadataPath STREQUAL "libstdc++.modules.json")
            message(FATAL_ERROR
                "GCC ${compilerFullVersion} could not locate libstdc++.modules.json.\n"
                "Compiler: ${candidateCompiler}\n"
                "Compiler error: ${metadataPathError}\n"
                "Install the matching libstdc++ development package."
            )
        endif()
    endif()

    aimcpp_repair_gnu_stdlib_metadata(
        "${metadataPath}"
        "${compilerMajorVersion}"
        "${CMAKE_BINARY_DIR}/aimcpp-libstdc++.modules.json"
        preparedMetadataPath
    )

    set(${outputVariable} "${preparedMetadataPath}" PARENT_SCOPE)
endfunction()
