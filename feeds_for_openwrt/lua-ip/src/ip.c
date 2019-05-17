#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <arpa/inet.h>
#include <lauxlib.h>

typedef struct {
	union {
		struct in_addr v4;
		struct in6_addr v6;
	} addr;
	int len;
	int bits;
	int family;
	bool exact;
} cidr_t;

static bool parse_mask(int family, const char *mask, int *bits)
{
	char *e;
	struct in_addr m;
	struct in6_addr m6;

	if (family == AF_INET && inet_pton(AF_INET, mask, &m)) {
		for (*bits = 0, m.s_addr = ntohl(m.s_addr); *bits < 32 && (m.s_addr << *bits) & 0x80000000; ++*bits);
	} else if (family == AF_INET6 && inet_pton(AF_INET6, mask, &m6)) {
		for (*bits = 0; *bits < 128 && (m6.s6_addr[*bits / 8] << (*bits % 8)) & 128; ++*bits);
	} else {
		*bits = strtoul(mask, &e, 10);

		if (e == mask || *e != 0 || *bits > ((family == AF_INET) ? 32 : 128))
			return false;
	}

	return true;
}

static bool parse_cidr(const char *dest, cidr_t *pp)
{
	char *p, buf[INET6_ADDRSTRLEN * 2 + 2];
	uint8_t bitlen = 0;

	strncpy(buf, dest, sizeof(buf) - 1);

	p = strchr(buf, '/');

	if (p)
		*p++ = 0;

	if (inet_pton(AF_INET, buf, &pp->addr.v4)) {
		bitlen = 32;
		pp->family = AF_INET;
		pp->len = sizeof(struct in_addr);
	} else if (inet_pton(AF_INET6, buf, &pp->addr.v6)) {
		bitlen = 128;
		pp->family = AF_INET6;
		pp->len = sizeof(struct in6_addr);
	} else
		return false;

	if (p) {
		if (!parse_mask(pp->family, p, &pp->bits))
			return false;
	} else {
		pp->bits = bitlen;
	}

	return true;
}

static int L_checkbits(lua_State *L, int index, cidr_t *p)
{
	int bits;

	if (lua_gettop(L) < index || lua_isnil(L, index)) {
		bits = p->bits;
	} else if (lua_type(L, index) == LUA_TNUMBER) {
		bits = lua_tointeger(L, index);

		if (bits < 0 || bits > ((p->family == AF_INET) ? 32 : 128))
			return luaL_error(L, "Invalid prefix size");
	} else if (lua_type(L, index) == LUA_TSTRING) {
		if (!parse_mask(p->family, lua_tostring(L, index), &bits))
			return luaL_error(L, "Invalid netmask format");
	} else {
		return luaL_error(L, "Invalid data type");
	}

	return bits;
}

static int _cidr_new(lua_State *L, int index, int family, bool mask)
{
	uint32_t n;
	const char *addr;
	cidr_t cidr = { }, *cidrp;

	if (lua_type(L, index) == LUA_TNUMBER) {
		n = htonl(lua_tointeger(L, index));

		if (family == AF_INET6) {
			cidr.family = AF_INET6;
			cidr.bits = 128;
			cidr.len = sizeof(cidr.addr.v6);
			cidr.addr.v6.s6_addr[12] = n;
			cidr.addr.v6.s6_addr[13] = (n >> 8);
			cidr.addr.v6.s6_addr[14] = (n >> 16);
			cidr.addr.v6.s6_addr[15] = (n >> 24);
		} else {
			cidr.family = AF_INET;
			cidr.bits = 32;
			cidr.len = sizeof(cidr.addr.v4);
			cidr.addr.v4.s_addr = n;
		}
	} else {
		addr = luaL_checkstring(L, index);

		if (!parse_cidr(addr, &cidr))
			return 0;

		if (family && cidr.family != family)
			return 0;

		if (mask)
			cidr.bits = L_checkbits(L, index + 1, &cidr);
	}

	if (!(cidrp = lua_newuserdata(L, sizeof(*cidrp))))
		return 0;

	*cidrp = cidr;
	luaL_getmetatable(L, "ip.cidr");
	lua_setmetatable(L, -2);
	return 1;
}

static cidr_t *L_checkcidr (lua_State *L, int index, cidr_t *p)
{
	if (lua_type(L, index) == LUA_TUSERDATA)
		return luaL_checkudata(L, index, "ip.cidr");

	if (_cidr_new(L, index, p ? p->family : 0, false))
		return lua_touserdata(L, -1);

	luaL_error(L, "Invalid operand");
	return NULL;
}

static int cidr_new(lua_State *L)
{
	return _cidr_new(L, 1, 0, true);
}

static int cidr_ipv4(lua_State *L)
{
	return _cidr_new(L, 1, AF_INET, true);
}

static int cidr_ipv6(lua_State *L)
{
	return _cidr_new(L, 1, AF_INET6, true);
}

static int cidr_is4(lua_State *L)
{
	cidr_t *p = L_checkcidr(L, 1, NULL);

	lua_pushboolean(L, p->family == AF_INET);
	return 1;
}

static int cidr_is4rfc1918(lua_State *L)
{
	cidr_t *p = L_checkcidr(L, 1, NULL);
	uint32_t a = htonl(p->addr.v4.s_addr);

	lua_pushboolean(L, (p->family == AF_INET &&
	                    ((a >= 0x0A000000 && a <= 0x0AFFFFFF) ||
	                     (a >= 0xAC100000 && a <= 0xAC1FFFFF) ||
	                     (a >= 0xC0A80000 && a <= 0xC0A8FFFF))));

	return 1;
}

static int cidr_is4linklocal(lua_State *L)
{
	cidr_t *p = L_checkcidr(L, 1, NULL);
	uint32_t a = htonl(p->addr.v4.s_addr);

	lua_pushboolean(L, (p->family == AF_INET &&
	                    a >= 0xA9FE0000 &&
	                    a <= 0xA9FEFFFF));

	return 1;
}

static bool _is_mapped4(cidr_t *p)
{
	return (p->family == AF_INET6 &&
	        p->addr.v6.s6_addr[0] == 0 &&
	        p->addr.v6.s6_addr[1] == 0 &&
	        p->addr.v6.s6_addr[2] == 0 &&
	        p->addr.v6.s6_addr[3] == 0 &&
	        p->addr.v6.s6_addr[4] == 0 &&
	        p->addr.v6.s6_addr[5] == 0 &&
	        p->addr.v6.s6_addr[6] == 0 &&
	        p->addr.v6.s6_addr[7] == 0 &&
	        p->addr.v6.s6_addr[8] == 0 &&
	        p->addr.v6.s6_addr[9] == 0 &&
	        p->addr.v6.s6_addr[10] == 0xFF &&
	        p->addr.v6.s6_addr[11] == 0xFF);
}

static int cidr_is6mapped4(lua_State *L)
{
	cidr_t *p = L_checkcidr(L, 1, NULL);

	lua_pushboolean(L, _is_mapped4(p));
	return 1;
}

static int cidr_is6(lua_State *L)
{
	cidr_t *p = L_checkcidr(L, 1, NULL);

	lua_pushboolean(L, p->family == AF_INET6);
	return 1;
}

static int cidr_is6linklocal(lua_State *L)
{
	cidr_t *p = L_checkcidr(L, 1, NULL);

	lua_pushboolean(L, (p->family == AF_INET6 &&
	                    p->addr.v6.s6_addr[0] == 0xFE &&
	                    p->addr.v6.s6_addr[1] >= 0x80 &&
	                    p->addr.v6.s6_addr[1] <= 0xBF));

	return 1;
}

static int _cidr_cmp(lua_State *L)
{
	cidr_t *a = L_checkcidr(L, 1, NULL);
	cidr_t *b = L_checkcidr(L, 2, NULL);

	if (a->family != b->family)
		return (a->family - b->family);

	return memcmp(&a->addr.v6, &b->addr.v6, a->len);
}

static int cidr_lower(lua_State *L)
{
	lua_pushboolean(L, _cidr_cmp(L) < 0);
	return 1;
}

static int cidr_higher(lua_State *L)
{
	lua_pushboolean(L, _cidr_cmp(L) > 0);
	return 1;
}

static int cidr_equal(lua_State *L)
{
	lua_pushboolean(L, _cidr_cmp(L) == 0);
	return 1;
}

static int cidr_lower_equal(lua_State *L)
{
	lua_pushboolean(L, _cidr_cmp(L) <= 0);
	return 1;
}

static int cidr_prefix(lua_State *L)
{
	cidr_t *p = L_checkcidr(L, 1, NULL);
	int bits = L_checkbits(L, 2, p);

	p->bits = bits;
	lua_pushinteger(L, p->bits);
	return 1;
}

static void _apply_mask(cidr_t *p, int bits, bool inv)
{
	uint8_t b, i;

	if (bits <= 0) {
		memset(&p->addr.v6, inv * 0xFF, p->len);
	} else if (p->family == AF_INET && bits <= 32) {
		if (inv)
			p->addr.v4.s_addr |= ntohl((1 << (32 - bits)) - 1);
		else
			p->addr.v4.s_addr &= ntohl(~((1 << (32 - bits)) - 1));
	} else if (p->family == AF_INET6 && bits <= 128) {
		for (i = 0; i < sizeof(p->addr.v6.s6_addr); i++) {
			b = (bits > 8) ? 8 : bits;
			if (inv)
				p->addr.v6.s6_addr[i] |= ~((uint8_t)(0xFF << (8 - b)));
			else
				p->addr.v6.s6_addr[i] &= (uint8_t)(0xFF << (8 - b));
			bits -= b;
		}
	}
}

static int cidr_network(lua_State *L)
{
	cidr_t *p1 = L_checkcidr(L, 1, NULL), *p2;
	int bits = L_checkbits(L, 2, p1);

	if (!(p2 = lua_newuserdata(L, sizeof(*p2))))
		return 0;

	*p2 = *p1;
	p2->bits = (p1->family == AF_INET) ? 32 : 128;
	_apply_mask(p2, bits, false);

	luaL_getmetatable(L, "ip.cidr");
	lua_setmetatable(L, -2);
	return 1;
}

static int cidr_host(lua_State *L)
{
	cidr_t *p1 = L_checkcidr(L, 1, NULL);
	cidr_t *p2 = lua_newuserdata(L, sizeof(*p2));

	if (!p2)
		return 0;

	*p2 = *p1;
	p2->bits = (p1->family == AF_INET) ? 32 : 128;

	luaL_getmetatable(L, "ip.cidr");
	lua_setmetatable(L, -2);
	return 1;
}

static int cidr_mask(lua_State *L)
{
	cidr_t *p1 = L_checkcidr(L, 1, NULL), *p2;
	int bits = L_checkbits(L, 2, p1);

	if (!(p2 = lua_newuserdata(L, sizeof(*p2))))
		return 0;

	p2->bits = (p1->family == AF_INET) ? 32 : 128;
	p2->family = p1->family;

	memset(&p2->addr.v6.s6_addr, 0xFF, sizeof(p2->addr.v6.s6_addr));
	_apply_mask(p2, bits, false);

	luaL_getmetatable(L, "ip.cidr");
	lua_setmetatable(L, -2);
	return 1;
}

static int cidr_broadcast(lua_State *L)
{
	cidr_t *p1 = L_checkcidr(L, 1, NULL);
	cidr_t *p2;
	int bits = L_checkbits(L, 2, p1);

	if (p1->family == AF_INET6)
		return 0;

	if (!(p2 = lua_newuserdata(L, sizeof(*p2))))
		return 0;

	*p2 = *p1;
	p2->bits = (p1->family == AF_INET) ? 32 : 128;
	_apply_mask(p2, bits, true);

	luaL_getmetatable(L, "ip.cidr");
	lua_setmetatable(L, -2);
	return 1;
}

static int cidr_mapped4(lua_State *L)
{
	cidr_t *p1 = L_checkcidr(L, 1, NULL);
	cidr_t *p2;

	if (!_is_mapped4(p1))
		return 0;

	if (!(p2 = lua_newuserdata(L, sizeof(*p2))))
		return 0;

	p2->family = AF_INET;
	p2->bits = (p1->bits > 32) ? 32 : p1->bits;
	memcpy(&p2->addr.v4, p1->addr.v6.s6_addr + 12, sizeof(p2->addr.v4));

	luaL_getmetatable(L, "ip.cidr");
	lua_setmetatable(L, -2);
	return 1;
}

static int cidr_contains(lua_State *L)
{
	cidr_t *p1 = L_checkcidr(L, 1, NULL);
	cidr_t *p2 = L_checkcidr(L, 2, NULL);
	cidr_t a = *p1, b = *p2;
	bool rv = false;

	if (p1->family == p2->family && p1->bits <= p2->bits) {
		_apply_mask(&a, p1->bits, false);
		_apply_mask(&b, p1->bits, false);

		rv = !memcmp(&a.addr.v6, &b.addr.v6, a.len);
	}

	lua_pushboolean(L, rv);
	return 1;
}

#define S6_BYTE(a, i) \
	(a)->addr.v6.s6_addr[sizeof((a)->addr.v6.s6_addr) - (i) - 1]

static int _cidr_add_sub(lua_State *L, bool add)
{
	cidr_t *p1 = L_checkcidr(L, 1, NULL);
	cidr_t *p2 = L_checkcidr(L, 2, p1);
	cidr_t r = *p1;
	bool inplace = lua_isboolean(L, 3) ? lua_toboolean(L, 3) : false;
	bool ok = true;
	uint8_t i, carry;
	uint32_t a, b;

	if (p1->family == p2->family) {
		if (p1->family == AF_INET6) {
			for (i = 0, carry = 0; i < sizeof(r.addr.v6.s6_addr); i++) {
				if (add) {
					S6_BYTE(&r, i) = S6_BYTE(p1, i) + S6_BYTE(p2, i) + carry;
					carry = (S6_BYTE(p1, i) + S6_BYTE(p2, i) + carry) / 256;
				} else {
					S6_BYTE(&r, i) = (S6_BYTE(p1, i) - S6_BYTE(p2, i) - carry);
					carry = (S6_BYTE(p1, i) < (S6_BYTE(p2, i) + carry));
				}
			}

			/* would over/underflow */
			if (carry) {
				memset(&r.addr.v6, add * 0xFF, sizeof(r.addr.v6));
				ok = false;
			}
		} else {
			a = ntohl(p1->addr.v4.s_addr);
			b = ntohl(p2->addr.v4.s_addr);

			/* would over/underflow */
			if ((add && (UINT_MAX - a) < b) || (!add && a < b)) {
				r.addr.v4.s_addr = add * 0xFFFFFFFF;
				ok = false;
			} else {
				r.addr.v4.s_addr = add ? htonl(a + b) : htonl(a - b);
			}
		}
	} else {
		ok = false;
	}

	if (inplace) {
		*p1 = r;
		lua_pushboolean(L, ok);
		return 1;
	}

	if (!(p1 = lua_newuserdata(L, sizeof(*p1))))
		return 0;

	*p1 = r;

	luaL_getmetatable(L, "ip.cidr");
	lua_setmetatable(L, -2);
	return 1;
}

static int cidr_add(lua_State *L)
{
	return _cidr_add_sub(L, true);
}

static int cidr_sub(lua_State *L)
{
	return _cidr_add_sub(L, false);
}

static int cidr_minhost(lua_State *L)
{
	cidr_t *p = L_checkcidr(L, 1, NULL);
	cidr_t r = *p;
	uint8_t i, rest, carry;

	_apply_mask(&r, r.bits, false);

	if (r.family == AF_INET6 && r.bits < 128) {
		r.bits = 128;

		for (i = 0, carry = 1; i < sizeof(r.addr.v6.s6_addr); i++) {
			rest = (S6_BYTE(&r, i) + carry) > 255;
			S6_BYTE(&r, i) += carry;
			carry = rest;
		}
	} else if (r.family == AF_INET && r.bits < 32) {
		r.bits = 32;
		r.addr.v4.s_addr = htonl(ntohl(r.addr.v4.s_addr) + 1);
	}

	if (!(p = lua_newuserdata(L, sizeof(*p))))
		return 0;

	*p = r;

	luaL_getmetatable(L, "ip.cidr");
	lua_setmetatable(L, -2);
	return 1;
}

static int cidr_maxhost(lua_State *L)
{
	cidr_t *p = L_checkcidr(L, 1, NULL);
	cidr_t r = *p;

	_apply_mask(&r, r.bits, true);

	if (r.family == AF_INET && r.bits < 32) {
		r.bits = 32;
		r.addr.v4.s_addr = htonl(ntohl(r.addr.v4.s_addr) - 1);
	} else if (r.family == AF_INET6) {
		r.bits = 128;
	}

	if (!(p = lua_newuserdata(L, sizeof(*p))))
		return 0;

	*p = r;

	luaL_getmetatable(L, "ip.cidr");
	lua_setmetatable(L, -2);
	return 1;
}

static int cidr_tostring (lua_State *L)
{
	char buf[INET6_ADDRSTRLEN];
	cidr_t *p = L_checkcidr(L, 1, NULL);

	if ((p->family == AF_INET && p->bits < 32) || (p->family == AF_INET6 && p->bits < 128)) {
		lua_pushfstring(L, "%s/%d", inet_ntop(p->family, &p->addr.v6, buf, sizeof(buf)), p->bits);
	} else {
		lua_pushstring(L, inet_ntop(p->family, &p->addr.v6, buf, sizeof(buf)));
	}

	return 1;
}

static int cidr_gc (lua_State *L)
{
	return 0;
}

static const luaL_reg ip_methods[] = {
	{ "new",	cidr_new	},
	{ "IPv4",	cidr_ipv4	},
	{ "IPv6",	cidr_ipv6	},
	{NULL,		NULL}
};

static const luaL_reg ip_cidr_methods[] = {
	{ "is4",			cidr_is4},
	{ "is4rfc1918",		cidr_is4rfc1918	  },
	{ "is4linklocal",	cidr_is4linklocal },
	{ "is6",			cidr_is6          },
	{ "is6linklocal",	cidr_is6linklocal },
	{ "is6mapped4",		cidr_is6mapped4   },
	{ "lower",			cidr_lower        },
	{ "higher",			cidr_higher       },
	{ "equal",			cidr_equal        },
	{ "prefix",			cidr_prefix       },
	{ "network",		cidr_network      },
	{ "host",			cidr_host         },
	{ "mask",			cidr_mask         },
	{ "broadcast",		cidr_broadcast    },
	{ "mapped4",		cidr_mapped4      },
	{ "contains",       cidr_contains     },
	{ "add",			cidr_add          },
	{ "sub",			cidr_sub          },
	{ "minhost",		cidr_minhost      },
	{ "maxhost",		cidr_maxhost      },
	{ "string",			cidr_tostring     },
	
	{ "__lt",			cidr_lower        },
	{ "__le",			cidr_lower_equal  },
	{ "__eq",			cidr_equal        },
	{ "__add",			cidr_add          },
	{ "__sub",			cidr_sub          },
	{ "__tostring",		cidr_tostring     },
	{ "__gc",			cidr_gc           },
	{NULL,		NULL}
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

int luaopen_ip(lua_State *L)
{
	lua_newtable(L);
	luaL_setfuncs(L, ip_methods, 0);
	
	luaL_newmetatable(L, "ip.cidr");
	luaL_setfuncs(L, ip_cidr_methods, 0);
	
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	lua_pop(L, 1);
	
	return 1;
}
