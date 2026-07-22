cmake_minimum_required(VERSION 3.30)

if(NOT DEFINED AIMCPP_SOURCE_DIR OR NOT DEFINED AIMCPP_BINARY_DIR)
    message(FATAL_ERROR "AIMCPP_SOURCE_DIR and AIMCPP_BINARY_DIR are required")
endif()

include("${AIMCPP_SOURCE_DIR}/cmake/AimcppProjectChecks.cmake")

if(DEFINED AIMCPP_CHECK_SOURCE)
    aimcpp_reject_final_qml_creatable_types(SOURCES "${AIMCPP_CHECK_SOURCE}")
    return()
endif()

set(testDirectory "${AIMCPP_BINARY_DIR}/project-checks-test")
file(MAKE_DIRECTORY "${testDirectory}")

set(validSource "${testDirectory}/valid_view_model.hpp")
file(WRITE "${validSource}" [=[
class ForwardDeclared;

class AppViewModel : public QObject {
    Q_OBJECT
    QML_ELEMENT
};
]=])

aimcpp_reject_final_qml_creatable_types(SOURCES "${validSource}")

set(invalidSource "${testDirectory}/invalid_view_model.hpp")
file(WRITE "${invalidSource}" [=[
class AppViewModel final
    : public QObject {
    Q_OBJECT
    QML_ELEMENT
};
]=])

execute_process(
    COMMAND
        "${CMAKE_COMMAND}"
        "-DAIMCPP_SOURCE_DIR=${AIMCPP_SOURCE_DIR}"
        "-DAIMCPP_BINARY_DIR=${AIMCPP_BINARY_DIR}"
        "-DAIMCPP_CHECK_SOURCE=${invalidSource}"
        -P
        "${CMAKE_CURRENT_LIST_FILE}"
    RESULT_VARIABLE childResult
    OUTPUT_VARIABLE childOutput
    ERROR_VARIABLE childError
)

set(childLog "${childOutput}${childError}")
if(childResult EQUAL 0)
    message(FATAL_ERROR "The invalid QML_ELEMENT final fixture was accepted")
endif()

foreach(expectedText IN ITEMS GUI-021 AppViewModel QML_ELEMENT)
    string(FIND "${childLog}" "${expectedText}" textPosition)
    if(textPosition EQUAL -1)
        message(FATAL_ERROR
            "Project preflight failure omitted '${expectedText}': ${childLog}"
        )
    endif()
endforeach()
