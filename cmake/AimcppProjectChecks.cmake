include_guard(GLOBAL)

function(aimcpp_reject_final_qml_creatable_types)
    cmake_parse_arguments(PARSE_ARGV 0 AIMCPP_CHECK "" "" "SOURCES")

    if(NOT AIMCPP_CHECK_SOURCES)
        message(FATAL_ERROR
            "aimcpp_reject_final_qml_creatable_types requires SOURCES"
        )
    endif()

    foreach(sourcePath IN LISTS AIMCPP_CHECK_SOURCES)
        if(IS_ABSOLUTE "${sourcePath}")
            set(absoluteSourcePath "${sourcePath}")
        else()
            set(absoluteSourcePath "${CMAKE_CURRENT_SOURCE_DIR}/${sourcePath}")
        endif()

        if(NOT EXISTS "${absoluteSourcePath}")
            message(FATAL_ERROR
                "Qt presentation preflight source does not exist: ${absoluteSourcePath}"
            )
        endif()

        file(STRINGS "${absoluteSourcePath}" sourceLines)
        set(className "")
        set(classDeclaration "")
        set(isCollectingDeclaration OFF)
        set(isFinalClass OFF)

        foreach(rawLine IN LISTS sourceLines)
            string(REGEX REPLACE "//.*$" "" sourceLine "${rawLine}")

            if(className STREQUAL "" AND
               sourceLine MATCHES "^[ \t]*(class|struct)[ \t]+([A-Za-z_][A-Za-z0-9_]*)")
                set(className "${CMAKE_MATCH_2}")
                set(classDeclaration "")
                set(isCollectingDeclaration ON)
            endif()

            if(isCollectingDeclaration)
                string(APPEND classDeclaration " ${sourceLine}")

                if(sourceLine MATCHES "[{]")
                    set(isCollectingDeclaration OFF)
                    if(classDeclaration MATCHES "(^|[ \t])final([ \t]|:|[{])")
                        set(isFinalClass ON)
                    else()
                        set(className "")
                    endif()
                elseif(sourceLine MATCHES ";")
                    set(className "")
                    set(classDeclaration "")
                    set(isCollectingDeclaration OFF)
                endif()
            endif()

            if(isFinalClass AND
               sourceLine MATCHES "(^|[^A-Za-z0-9_])QML_ELEMENT([^A-Za-z0-9_]|$)")
                message(FATAL_ERROR
                    "GUI-021: QML-creatable type '${className}' is declared final in "
                    "${absoluteSourcePath}. Qt generates a wrapper derived from types "
                    "marked QML_ELEMENT. Remove final, or use an explicitly verified "
                    "non-creatable registration and ownership strategy."
                )
            endif()

            if(isFinalClass AND sourceLine MATCHES "^[ \t]*};")
                set(className "")
                set(classDeclaration "")
                set(isFinalClass OFF)
            endif()
        endforeach()
    endforeach()
endfunction()
