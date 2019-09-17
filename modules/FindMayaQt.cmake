# Copyright 2019 Daniil Kostiuk
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#[=====================================================================================================[.rst:
FindMayaQt
----------

Finds the MayaQt library.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``MayaQt:MayaQt``
  The MayaQt library

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``MayaQt_FOUND``
  True if the system has the Foo library.
``MayaQt_INCLUDE_DIR``
  Include directories needed to use Foo.
``MayaQt_LIBRARIES``
  Libraries needed to link to Foo.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``MAYA_INST_VERSION``
  Maya installed version.

``MAYA_INSTALL_BASE_PATH``
  Another MAYA installation location.

#]=====================================================================================================]

# Установили версию MAYA, если не определена:
    if(NOT DEFINED MAYA_INST_VERSION)
        set(MAYA_INST_VERSION 2019 CACHE STRING "Maya installed version")
    endif()

# Установили общие определения компиляции и суфикс имени библиотеки:
    set(MAYA_COMPILE_DEFINITIONS "REQUIRE_IOSTREAM;_BOOL") #
    set(MAYA_INSTALL_BASE_SUFFIX "")

    if(CMAKE_SYSTEM_NAME STREQUAL "Windows")

# Установили свойства для системы Windows:
        set(MAYA_INSTALL_BASE_DEFAULT "C:/Program Files/Autodesk")
        set(MAYA_COMPILE_DEFINITIONS "${MAYA_COMPILE_DEFINITIONS};NT_PLUGIN")
        set(MAYA_PLUGIN_EXTENSION ".mll")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")

# Установили свойства для системы MACOS:
        set(MAYA_INSTALL_BASE_DEFAULT /Applications/Autodesk)
        set(MAYA_COMPILE_DEFINITIONS "${MAYA_COMPILE_DEFINITIONS};OSMac_")
        set(MAYA_PLUGIN_EXTENSION ".bundle")
    elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")

# Установили свойства для системы Linux:
        set(MAYA_COMPILE_DEFINITIONS "${MAYA_COMPILE_DEFINITIONS};LINUX")
        set(MAYA_INSTALL_BASE_DEFAULT /usr/autodesk)
        if(MAYA_VERSION LESS 2016)
            set(MAYA_INSTALL_BASE_SUFFIX -x64)
        endif()
        set(MAYA_PLUGIN_EXTENSION ".so")
    endif()

# Установили путь до директории MAYA:
    set(MAYA_INSTALL_BASE_PATH ${MAYA_INSTALL_BASE_DEFAULT} CACHE STRING
        "Root path containing your maya installations, e.g. /usr/autodesk or /Applications/Autodesk/")
    set(MAYA_LOCATION ${MAYA_INSTALL_BASE_PATH}/maya${MAYA_INST_VERSION}${MAYA_INSTALL_BASE_SUFFIX})

# Нашли полный путь до директории с заголовочными файлами MAYA:
    find_path(MayaQt_INCLUDE_DIR 
        NAMES
            maya/MFn.h
        PATHS
            ${MAYA_LOCATION}
            $ENV{MAYA_LOCATION}
        PATH_SUFFIXES
            "include/"
            "devkit/include/")

# Нашли полный путь до директории с заголовочными файлами QT:
    find_path(QT_INCLUDE_DIR
        NAMES 
            QtCore
        PATHS
            ${MAYA_LOCATION}
            $ENV{MAYA_LOCATION}
        PATH_SUFFIXES
            "include/qt"
            "devkit/include/"
        NO_DEFAULT_PATH)

# Нашли полный путь до LIB библиотеки OpenMaya: 
    find_library(MayaQt_LIBRARY
        NAMES 
            OpenMaya
        PATHS
            ${MAYA_LOCATION}
            $ENV{MAYA_LOCATION}
        PATH_SUFFIXES
            "lib/"
            "Maya.app/Contents/MacOS/"
        NO_DEFAULT_PATH)

# Проверили работоспособность модуля:
    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(MayaQt
    FOUND_VAR MayaQt_FOUND
    REQUIRED_VARS
        MayaQt_LIBRARY
        MayaQt_INCLUDE_DIR)

# Создали интерфейс модуля MayaQt::MayaQt: 
    if(MayaQt_FOUND AND NOT TARGET MayaQt:MayaQt)
        add_library(MayaQt::MayaQt UNKNOWN IMPORTED)

        set_target_properties(MayaQt::MayaQt PROPERTIES
        IMPORTED_LOCATION "${MayaQt_LIBRARY}"
        INTERFACE_COMPILE_DEFINITIONS "${MAYA_COMPILE_DEFINITIONS}"
        INTERFACE_INCLUDE_DIRECTORIES  "${QT_INCLUDE_DIR};${MayaQt_INCLUDE_DIR}")

        if ((CMAKE_SYSTEM_NAME STREQUAL "Darwin") AND (${CMAKE_CXX_COMPILER_ID} MATCHES "Clang") AND (MAYA_INST_VERSION LESS 2017))
            set_target_properties(MayaQt::MayaQt PROPERTIES
            INTERFACE_COMPILE_OPTIONS "-std=c++0x;-stdlib=libstdc++")
        endif ()
    endif()

# Добавили другие библиотеки в основной модуль MayaQt::MayaQt: 
    set(_MAYA_LIBRARIES Qt5Core Qt5Widgets Qt5Gui Qt5UiTools OpenMaya OpenMayaAnim OpenMayaFX OpenMayaRender OpenMayaUI Foundation clew)
    foreach(MAYA_LIB ${_MAYA_LIBRARIES})
        find_library(MayaQt_${MAYA_LIB}_LIBRARY
            NAMES 
                ${MAYA_LIB}
            PATHS
                ${MAYA_LOCATION}
                $ENV{MAYA_LOCATION}
            PATH_SUFFIXES
                "lib/"
                "Maya.app/Contents/MacOS/"
            NO_DEFAULT_PATH)

        mark_as_advanced(MayaQt_${MAYA_LIB}_LIBRARY)

        if (MayaQt_${MAYA_LIB}_LIBRARY)
            add_library(MayaQt::${MAYA_LIB} UNKNOWN IMPORTED)
            set_target_properties(MayaQt::${MAYA_LIB} PROPERTIES
                IMPORTED_LOCATION "${MayaQt_${MAYA_LIB}_LIBRARY}")
            set_property(TARGET MayaQt::MayaQt APPEND PROPERTY
                INTERFACE_LINK_LIBRARIES "MayaQt::${MAYA_LIB}")
            list(APPEND MayaQt_LIBRARIES ${MayaQt_${MAYA_LIB}_LIBRARY})
        endif()
    endforeach()

# Запретили неявное переназначение переменных модуля:
    mark_as_advanced(MayaQt_INCLUDE_DIR MayaQt_LIBRARY)

# Создали функцию для назначения свойст цели сборки:
    function(MAYA_PLUGIN _target)
        if (WIN32)
            set_target_properties(${_target} PROPERTIES
                LINK_FLAGS "/export:initializePlugin /export:uninitializePlugin")
        endif()
        set_target_properties(${_target} PROPERTIES
            PREFIX ""
            SUFFIX ${MAYA_PLUGIN_EXTENSION})
    endfunction()

