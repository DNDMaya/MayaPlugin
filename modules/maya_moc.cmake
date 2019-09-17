# Установили версию Qt
    set(QT_VERSION_MAJOR 5)

# Установка дирриктории поиска приложений MOC, UIC, RCC
    if(WIN32)
        set(QT_BIN_PATH "C:/Program Files/Autodesk/Maya2019/bin/")
    endif()

# Переопределяем MOC 
find_program(QT_MOC_EXECUTABLE moc.exe PATH ${QT_BIN_PATH})
add_executable(Qt5::moc IMPORTED)
set_target_properties(Qt5::moc PROPERTIES IMPORTED_LOCATION ${QT_MOC_EXECUTABLE})
set(CMAKE_AUTOMOC TRUE)

# Переопределяем UIC
find_program(QT_UIC_EXECUTABLE uic.exe PATH ${QT_BIN_PATH})
add_executable(Qt5::uic IMPORTED)
set_target_properties(Qt5::uic PROPERTIES IMPORTED_LOCATION ${QT_UIC_EXECUTABLE})
set(CMAKE_AUTOUIC TRUE)

# Переопределяем RCC
find_program(QT_RCC_EXECUTABLE rcc.exe PATH ${QT_BIN_PATH})
add_executable(Qt5::rcc IMPORTED)
set_target_properties(Qt5::rcc PROPERTIES IMPORTED_LOCATION ${QT_RCC_EXECUTABLE})
set(CMAKE_AUTORCC TRUE)