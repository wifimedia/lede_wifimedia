#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <lauxlib.h>

static int daemonize(lua_State *L)
{
	int nochdir = lua_toboolean(L, 1);
	int noclose = lua_toboolean(L, 2);

	int ret = daemon(nochdir, noclose);
	if (ret < 0) {
		lua_pushstring(L, strerror(errno));
		return 1;
	}
    return 0;
}

static const luaL_Reg R[] =
{
    {"daemonize", daemonize},
    {NULL, NULL}
};

#if LUA_VERSION_NUM==501
/* Adapted from Lua 5.2 */
void luaL_setfuncs (lua_State *L, const luaL_Reg *l, int nup) {
  luaL_checkstack(L, nup+1, "too many upvalues");
  for (; l->name != NULL; l++) {  /* fill the table with given functions */
    int i;
    lua_pushstring(L, l->name);
    for (i = 0; i < nup; i++)  /* copy upvalues to the top */
      lua_pushvalue(L, -(nup+1));
    lua_pushcclosure(L, l->func, nup);  /* closure with those upvalues */
    lua_settable(L, -(nup + 3));
  }
  lua_pop(L, nup);  /* remove upvalues */
}
#endif

int luaopen_daemon(lua_State *L)
{
	lua_newtable(L);
	luaL_setfuncs(L, R, 0);
    return 1;
}
