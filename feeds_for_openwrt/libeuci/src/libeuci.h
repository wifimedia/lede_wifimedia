#ifndef LIBEUCI_H
#define LIBEUCI_H

#include <uci.h>

int euci_get(struct uci_context *ctx, const char *config, const char *section, const char *type, const char *option, char *out, int olen);

#endif