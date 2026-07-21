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
    failureVariable
)
    if(NOT EXISTS "${metadataPath}")
        string(CONCAT failureMessage
            "GCC reported libstdc++ module metadata that does not exist:\n"
            "  ${metadataPath}\n"
            "Install the matching libstdc++ development package for GCC ${compilerMajorVersion}."
        )
        set(${outputVariable} "" PARENT_SCOPE)
        set(${failureVariable} "${failureMessage}" PARENT_SCOPE)
        return()
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
        string(CONCAT failureMessage
            "Invalid libstdc++ module metadata:\n"
            "  ${canonicalMetadataPath}\n"
            "JSON error: ${metadataError}"
        )
        set(${outputVariable} "" PARENT_SCOPE)
        set(${failureVariable} "${failureMessage}" PARENT_SCOPE)
        return()
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
            string(CONCAT failureMessage
                "libstdc++ module metadata entry ${moduleIndex} has no valid source-path:\n"
                "  ${canonicalMetadataPath}\n"
                "JSON error: ${sourcePathError}"
            )
            set(${outputVariable} "" PARENT_SCOPE)
            set(${failureVariable} "${failureMessage}" PARENT_SCOPE)
            return()
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
            string(CONCAT failureMessage
                "libstdc++ module metadata points to a missing source:\n"
                "  metadata: ${canonicalMetadataPath}\n"
                "  source-path: ${sourcePath}\n"
                "The active GCC/libstdc++ package is incomplete or incompatible. "
                "Install matching GCC ${compilerMajorVersion} and libstdc++ development packages."
            )
            set(${outputVariable} "" PARENT_SCOPE)
            set(${failureVariable} "${failureMessage}" PARENT_SCOPE)
            return()
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

    set(${failureVariable} "" PARENT_SCOPE)
endfunction()

function(aimcpp_prepare_gnu_import_std outputVariable failureVariable)
    if(CMAKE_CXX_COMPILER)
        set(candidateCompiler "${CMAKE_CXX_COMPILER}")
    elseif(DEFINED ENV{CXX} AND NOT "$ENV{CXX}" STREQUAL "")
        set(candidateCompiler "$ENV{CXX}")
    else()
        find_program(candidateCompiler NAMES g++ c++)
    endif()

    if(NOT candidateCompiler)
        set(${outputVariable} "" PARENT_SCOPE)
        set(${failureVariable} "" PARENT_SCOPE)
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
        set(${failureVariable} "" PARENT_SCOPE)
        return()
    endif()

    if(CMAKE_VERSION VERSION_LESS "4.0.0")
        string(CONCAT failureMessage
            "GCC import std requires CMake 4.0 or newer.\n"
            "Active CMake: ${CMAKE_VERSION}\n"
            "Active compiler: ${candidateCompiler}\n"
            "CMake 3.30/3.31 supports Clang and MSVC import std, but not GCC/libstdc++.\n"
            "The project can use its standard-header compatibility mode instead."
        )
        set(${outputVariable} "" PARENT_SCOPE)
        set(${failureVariable} "${failureMessage}" PARENT_SCOPE)
        return()
    endif()

    execute_process(
        COMMAND "${candidateCompiler}" -dumpfullversion
        OUTPUT_VARIABLE compilerFullVersion
        ERROR_VARIABLE compilerFullVersionError
        RESULT_VARIABLE compilerFullVersionResult
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(compilerFullVersionResult OR NOT compilerFullVersion MATCHES "^([0-9]+)")
        string(CONCAT failureMessage
            "Could not determine the GCC version from ${candidateCompiler}: "
            "${compilerFullVersionError}"
        )
        set(${outputVariable} "" PARENT_SCOPE)
        set(${failureVariable} "${failureMessage}" PARENT_SCOPE)
        return()
    endif()

    set(compilerMajorVersion "${CMAKE_MATCH_1}")

    if(compilerMajorVersion VERSION_LESS "15")
        string(CONCAT failureMessage
            "GCC import std requires GCC 15 or newer.\n"
            "Active compiler: ${candidateCompiler}\n"
            "Active GCC version: ${compilerFullVersion}"
        )
        set(${outputVariable} "" PARENT_SCOPE)
        set(${failureVariable} "${failureMessage}" PARENT_SCOPE)
        return()
    endif()

    if(compilerMajorVersion VERSION_GREATER_EQUAL "16"
        AND CMAKE_VERSION VERSION_LESS "4.4.0"
    )
        string(CONCAT failureMessage
            "GCC ${compilerFullVersion} is newer than the GNU modules integration verified by "
            "CMake ${CMAKE_VERSION}.\n"
            "Observed failure: CMake 4.3 accepts GCC 16 metadata but its scanner does not "
            "recognize the GCC 16 std module interface.\n"
            "Use GCC 15.x with CMake 4.0-4.3, or use a CMake release that explicitly supports "
            "the active GCC major version."
        )
        set(${outputVariable} "" PARENT_SCOPE)
        set(${failureVariable} "${failureMessage}" PARENT_SCOPE)
        return()
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
            string(CONCAT failureMessage
                "GCC ${compilerFullVersion} could not locate libstdc++.modules.json.\n"
                "Compiler: ${candidateCompiler}\n"
                "Compiler error: ${metadataPathError}\n"
                "Install the matching libstdc++ development package."
            )
            set(${outputVariable} "" PARENT_SCOPE)
            set(${failureVariable} "${failureMessage}" PARENT_SCOPE)
            return()
        endif()
    endif()

    aimcpp_repair_gnu_stdlib_metadata(
        "${metadataPath}"
        "${compilerMajorVersion}"
        "${CMAKE_BINARY_DIR}/aimcpp-libstdc++.modules.json"
        preparedMetadataPath
        preparationFailure
    )

    set(${outputVariable} "${preparedMetadataPath}" PARENT_SCOPE)
    set(${failureVariable} "${preparationFailure}" PARENT_SCOPE)
endfunction()
