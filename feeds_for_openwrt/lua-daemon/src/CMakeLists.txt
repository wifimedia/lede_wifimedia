cmake_minimum_required(VERSION 2.6)

PROJECT(lua-daemon C)

SET(CMAKE_INSTALL_PREFIX /)

IF(NOT LUA_CFLAGS)
	FIND_PROGRAM(PKG_CONFIG pkg-config)
	IF(PKG_CONFIG)
		EXECUTE_PROCESS(
			COMMAND pkg-config --silence-errors --cflags lua5.1
			OUTPUT_VARIABLE LUA_CFLAGS
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
	ENDIF()
ENDIF()

IF(NOT LUA_LIB)
	FIND_PROGRAM(PKG_CONFIG pkg-config)
	IF(PKG_CONFIG)
		EXECUTE_PROCESS(
			COMMAND pkg-config --silence-errors --cflags lua5.1
			OUTPUT_VARIABLE LUA_LIB
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
	ENDIF()
ENDIF()

ADD_DEFINITIONS(-Os -Wall -Werror --std=gnu99 -g3 -I.. ${LUA_CFLAGS})

IF(NOT LUAPATH)
	EXECUTE_PROCESS(
		COMMAND  lua -e "for k in string.gmatch(package.cpath .. \";\", \"([^;]+)/..so;\") do if k:sub(1,1) == \"/\" then print(k) break end end"
		OUTPUT_VARIABLE LUAPATH
		RESULT_VARIABLE LUA_CHECK_RES
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	IF(NOT ${LUA_CHECK_RES} EQUAL 0 OR "${LUAPATH}" EQUAL "")
		MESSAGE(SEND_ERROR "Lua was not found on your system")
	ENDIF()
ENDIF()

ADD_LIBRARY(lua_daemon MODULE daemon.c)
SET_TARGET_PROPERTIES(lua_daemon PROPERTIES
	OUTPUT_NAME daemon
	PREFIX ""
)
TARGET_LINK_LIBRARIES(lua_daemon ${LUA_LIB})

INSTALL(TARGETS lua_daemon
	LIBRARY DESTINATION ${LUAPATH}
)
