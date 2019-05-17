#include "libeuci.h"
#include <string.h>
 
int euci_get(struct uci_context *ctx, const char *config, const char *section, const char *type, const char *option, char *out, int olen)
{
	int ret = -1;
	struct uci_package *p;
	struct uci_ptr ptr = {
		.package = config,
		.section = section,
		.option  = option
	};
	
	if (!ctx || !config || !option || !out)
		return -1;
	
	if (!section && !type)
		return -1;
	
	if (uci_load(ctx, ptr.package, &p) || !p)
		return -1;
	
	if (!section) {
		struct uci_section *s;
		struct uci_element *e;
		
		uci_foreach_element(&p->sections, e) {
			s = uci_to_section(e);

			if (strcmp(s->type, type))
				continue;

			ptr.section = e->name;
			uci_lookup_ptr(ctx, &ptr, NULL, true);
			break;
		}
	}
	
	memset(out, 0, olen);
	
	uci_lookup_ptr(ctx, &ptr, NULL, true);
	if (ptr.o && ptr.o->type == UCI_TYPE_STRING) {
		strncpy(out, ptr.o->v.string, olen);
		ret = 0;
	}
		
	uci_unload(ctx, p);
	
	return ret;
}
