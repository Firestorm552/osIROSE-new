set(BREAKPAD_EXCEPTION_HANDLER_INSTALL_DIR ${CMAKE_EXTERNAL_BINARY_DIR}/breakpad)

if(WIN32 AND NOT MINGW)
  if(DEBUG)
    set(CONFIGURATION_TYPE Debug)
  else()
    set(CONFIGURATION_TYPE Release)
  endif()
  
  ExternalProject_Add(
    breakpad
    GIT_SUBMODULES breakpad
    SOURCE_DIR ${CMAKE_THIRD_PARTY_DIR}/breakpad
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${PYTHON_EXECUTABLE} ../breakpad/src/tools/gyp/gyp ../breakpad/src/client/windows/breakpad_client.gyp
    BUILD_COMMAND msbuild <SOURCE_DIR>/src/client/windows/handler/exception_handler.vcxproj /nologo /t:rebuild /m:2 /property:Configuration=${CONFIGURATION_TYPE}
    INSTALL_COMMAND ""
  )
  ExternalProject_Add_Step(
    breakpad
    update_project_files
    DEPENDEES configure
    DEPENDERS build
    COMMAND vcupgrade <SOURCE_DIR>/src/client/windows/handler/exception_handler.vcproj
  )
  # Breakpad builds with /MT by default but we need /MD. This patch makes it build with /MD
  ExternalProject_Add_Step(
    breakpad
    patch_project_files
    DEPENDEES update_project_files
    DEPENDERS build
    WORKING_DIRECTORY <SOURCE_DIR>
    COMMAND cmake -DVCXPROJ_PATH=<SOURCE_DIR>/src/client/windows/handler/exception_handler.vcxproj -P ${CMAKE_SCRIPT_PATH}/breakpad_VS_patch.cmake
  )

  ExternalProject_Add(
    breakpad_s
    GIT_SUBMODULES breakpad
    SOURCE_DIR ${CMAKE_THIRD_PARTY_DIR}/breakpad
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${PYTHON_EXECUTABLE} ../breakpad_s/src/tools/gyp/gyp ../breakpad_s/src/client/windows/breakpad_client.gyp
    BUILD_COMMAND msbuild <SOURCE_DIR>/src/client/windows/handler/exception_handler.vcxproj /nologo /t:rebuild /m:2 /property:Configuration=${CONFIGURATION_TYPE}
    INSTALL_COMMAND ""
  )
  ExternalProject_Add_Step(
    breakpad_s
    update_project_files
    DEPENDEES configure
    DEPENDERS build
    COMMAND vcupgrade <SOURCE_DIR>/src/client/windows/handler/exception_handler.vcproj
  )
  
	ExternalProject_Get_Property(
	  breakpad_s
	  source_dir
	)
	set(BREAKPAD_EXCEPTION_HANDLER_INCLUDE_DIR_S ${source_dir}/src)  
	set(BREAKPAD_EXCEPTION_HANDLER_LIBRARY_DIR_S ${source_dir}/src/client/windows/handler/${CONFIGURATION_TYPE}/lib)
	set(BREAKPAD_EXCEPTION_HANDLER_LIBRARIES_S "${BREAKPAD_EXCEPTION_HANDLER_LIBRARY_DIR_S}/exception_handler.lib")	
  set_property(TARGET breakpad_s PROPERTY FOLDER "ThirdParty")
else()
  ExternalProject_Add(
    breakpad
    GIT_SUBMODULES breakpad
    SOURCE_DIR ${CMAKE_THIRD_PARTY_DIR}/breakpad
    CONFIGURE_COMMAND sh <SOURCE_DIR>/configure --enable-shared=no --enable-static=yes --prefix=${BREAKPAD_EXCEPTION_HANDLER_INSTALL_DIR}
  )
  
  ExternalProject_Add_Step(
    breakpad
    download-lss
    COMMAND rm -rf src/third_party/lss
    COMMAND git clone -q https://chromium.googlesource.com/linux-syscall-support src/third_party/lss
    WORKING_DIRECTORY <SOURCE_DIR>
    DEPENDEES download
    DEPENDERS configure
  )
endif()

ExternalProject_Get_Property(
  breakpad
  source_dir
)
set(BREAKPAD_EXCEPTION_HANDLER_INCLUDE_DIR ${source_dir}/src)

if(WIN32 AND NOT MINGW)
  set(BREAKPAD_EXCEPTION_HANDLER_LIBRARY_DIR ${source_dir}/src/client/windows/handler/${CONFIGURATION_TYPE}/lib)
  set(BREAKPAD_EXCEPTION_HANDLER_LIBRARIES "${BREAKPAD_EXCEPTION_HANDLER_LIBRARY_DIR}/exception_handler.lib")
else()
  set(BREAKPAD_EXCEPTION_HANDLER_LIBRARY_DIR ${BREAKPAD_EXCEPTION_HANDLER_INSTALL_DIR}/lib)
  set(BREAKPAD_EXCEPTION_HANDLER_LIBRARIES "${BREAKPAD_EXCEPTION_HANDLER_LIBRARY_DIR}/libbreakpad.a")
  if(NOT MINGW)
    set(BREAKPAD_EXCEPTION_HANDLER_LIBRARIES "${BREAKPAD_EXCEPTION_HANDLER_LIBRARIES};${BREAKPAD_EXCEPTION_HANDLER_LIBRARY_DIR}/libbreakpad_client.a")
  endif()
endif()

SET_PROPERTY(TARGET breakpad                PROPERTY FOLDER "ThirdParty")