cmake_minimum_required(VERSION 3.30)

project(MyApp VERSION 0.1.0 LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(AimcppProjectChecks)

option(MY_APP_BUILD_GUI "Build the Qt Quick application" ON)
option(MY_APP_BUILD_TESTS "Build tests" ON)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_library(my_app_core)
target_compile_features(my_app_core PUBLIC cxx_std_26)
target_sources(my_app_core
    PUBLIC
        FILE_SET CXX_MODULES
        FILES
            src/domain/app_domain.cppm
    PRIVATE
        src/domain/app_domain.cpp
)
set_property(TARGET my_app_core PROPERTY CXX_SCAN_FOR_MODULES ON)

if(MY_APP_BUILD_GUI)
    find_package(Qt6 6.6 REQUIRED COMPONENTS Quick Qml QuickControls2)

    set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/qml")

    set(my_app_qml_files
        ui/Main.qml
        ui/pages/HomePage.qml
        ui/components/PrimaryActionButton.qml
        ui/components/StatusPanel.qml
        ui/theme/Theme.qml
    )

    foreach(qmlFile IN LISTS my_app_qml_files)
        string(REGEX REPLACE "^ui/" "" qmlResourceAlias "${qmlFile}")
        set_source_files_properties(
            "${qmlFile}"
            PROPERTIES
                QT_RESOURCE_ALIAS "${qmlResourceAlias}"
        )
    endforeach()

    set_source_files_properties(
        ui/theme/Theme.qml
        PROPERTIES
            QT_QML_SINGLETON_TYPE TRUE
    )

    aimcpp_reject_final_qml_creatable_types(
        SOURCES
            src/presentation/app_view_model.hpp
    )

    if(QT_KNOWN_POLICY_QTP0004)
        qt_policy(SET QTP0004 NEW)
    endif()

    qt_standard_project_setup(REQUIRES 6.6)

    qt_add_executable(MyApp
        src/bootstrap/main.cpp
    )

    set_target_properties(MyApp
        PROPERTIES
            MACOSX_BUNDLE FALSE
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/bin"
    )

    target_compile_definitions(MyApp
        PRIVATE
            MY_APP_QT_QUICK_CONTROLS_STYLE=\"Basic\"
    )

    qt_add_qml_module(MyApp
        URI MyApp
        VERSION 1.0
        QML_FILES
            ${my_app_qml_files}
        SOURCES
            src/presentation/app_view_model.cpp
            src/presentation/app_view_model.hpp
    )

    target_include_directories(MyApp
        PRIVATE
            "${CMAKE_CURRENT_SOURCE_DIR}/src/presentation"
    )

    target_link_libraries(MyApp
        PRIVATE
            my_app_core
            Qt6::Quick
            Qt6::Qml
            Qt6::QuickControls2
    )
    target_compile_features(MyApp PRIVATE cxx_std_26)
    set_property(TARGET MyApp PROPERTY CXX_SCAN_FOR_MODULES ON)

    set(my_app_qmllint_strict_options --bare)
    if(Qt6_VERSION VERSION_GREATER_EQUAL 6.8)
        list(APPEND my_app_qmllint_strict_options --max-warnings 0)
    endif()

    add_custom_target(MyApp_qmllint_strict
        COMMAND Qt6::qmllint
            ${my_app_qmllint_strict_options}
            -I "${QT_QML_OUTPUT_DIRECTORY}"
            -I "${CMAKE_CURRENT_BINARY_DIR}"
            ${my_app_qml_files}
        DEPENDS MyApp
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        VERBATIM
    )
endif()

if(MY_APP_BUILD_TESTS)
    enable_testing()

    add_executable(my_app_tests tests/app_tests.cpp)
    target_link_libraries(my_app_tests PRIVATE my_app_core)
    target_compile_features(my_app_tests PRIVATE cxx_std_26)
    set_property(TARGET my_app_tests PROPERTY CXX_SCAN_FOR_MODULES ON)

    add_test(NAME app.behavior COMMAND my_app_tests)

    if(MY_APP_BUILD_GUI)
        add_test(NAME app.qml.smoke COMMAND MyApp --smoke-test)
        set_tests_properties(app.qml.smoke PROPERTIES
            ENVIRONMENT
                "QT_QPA_PLATFORM=offscreen;QT_QUICK_CONTROLS_STYLE=Basic;QT_FATAL_WARNINGS=1"
            TIMEOUT 30
        )
    endif()
endif()
