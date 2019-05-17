#include "libeuci.h"

int main(int argc, char **argv)
{
	int ret = -1;
	char out[128] = "";
	struct uci_context *ctx;
	
	ctx = uci_alloc_context();
	if (!ctx)
		return -1;
	
	ret = euci_get(ctx, "dhcp", NULL, "dnsmasq", "leasefile", out, sizeof(out));
	if (!ret)
		printf("dhcp.@dnsmasq[0].leasefile = %s\n", out);
	
	ret = euci_get(ctx, "dhcp", "lan", NULL, "start", out, sizeof(out));
	if (!ret)
		printf("dhcp.lan.start = %s\n", out);
	
	uci_free_context(ctx);
	
	return 0;
}
