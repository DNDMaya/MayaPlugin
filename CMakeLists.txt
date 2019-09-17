# Проверили минимальную необходимую версию Cmake:
    cmake_minimum_required(VERSION 3.5)

# Настроили проек: 
    project(Form)

# Добавили путь поиска модулей:
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/modules)

# Добавили внешний модуль maya_moc.cmake:
    include("maya_moc")

# Включили исходную диррикторию для обработки  
    set(CMAKE_INCLUDE_CURRENT_DIR ON)

# Выбрали конфигурации сборки проекта:
    SET(CMAKE_CONFIGURATION_TYPES "Release")

# Сохранили в переменную исходники:
    set(SOURCE_FILES test.cpp test.h test.ui)

# Нашли внешний модуль MayaQt.cmake:
    find_package(MayaQt REQUIRED)

# Создали необходимую библиотеку из исходников:
    add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES})

# Подключили внешние библиотеки через интерфейс модуля:
    target_link_libraries(${PROJECT_NAME} PRIVATE MayaQt::MayaQt)

# Подключили папку с необходимыми заголовками через интерфейс модуля:
    target_include_directories(${PROJECT_NAME} PRIVATE MayaQt::MayaQt)

# Добавили необходимые параметры для плагина MAYA:
    MAYA_PLUGIN(${PROJECT_NAME})