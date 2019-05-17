#include <ev.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <net/if.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <netlink/msg.h>
#include <netlink/attr.h>
#include <linux/rtnetlink.h>

#include <linux/version.h>

static struct nl_sock *create_socket(int protocol, int groups)
{
	struct nl_sock *sock;

	sock = nl_socket_alloc();
	if (!sock)
		return NULL;

	if (groups)
		nl_join_groups(sock, groups);

	if (nl_connect(sock, protocol))
		return NULL;

	return sock;
}

static int dev_get_sysctl(const char *path, const char *device, char *buf, const size_t buf_sz)
{
	int fd = -1, ret = -1;
	char attr[256];

	snprintf(attr, sizeof(attr), path, device);

	fd = open(attr, O_RDONLY);
	if (fd < 0)
		goto out;

	ssize_t len = read(fd, buf, buf_sz - 1);
	if (len < 0)
		goto out;

	ret = buf[len] = 0;

out:
	if (fd >= 0)
		close(fd);

	return ret;
}

static int cb_rtnl_event(struct nl_msg *msg, void *arg)
{
	struct nlattr *tb[IFLA_MAX + 1];
	struct nlmsghdr *nlh = nlmsg_hdr(msg);
	char *ifname = NULL;
	int carrier_state = 0;
	uint32_t carrier_changes = 1;
	char buf[10];
	pid_t pid;
	
	if (nlh->nlmsg_type != RTM_NEWLINK)
		goto out;
	
	if (nlmsg_parse(nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX, NULL))
		goto out;

	if (tb[IFLA_IFNAME])
		ifname = nla_get_string(tb[IFLA_IFNAME]);
	else
		goto out;

#if LINUX_VERSION_CODE > KERNEL_VERSION(3,15,1)
	if (tb[IFLA_CARRIER_CHANGES] == NULL)
		carrier_changes = 0;
	else
		carrier_changes = nla_get_u32(tb[IFLA_CARRIER_CHANGES]);
#endif

	if (carrier_changes)  {
		if (!dev_get_sysctl("/sys/class/net/%s/carrier", ifname, buf, sizeof(buf)))
			carrier_state = strtoul(buf, NULL, 0);

		//printf("'%s' link %s\n", ifname, carrier_state ? "up" : "down");
		
		pid = fork();
		if (pid < 0) {
			perror("fork");
			return 0;
		} else if (pid == 0) {
			setenv("ACTION", carrier_state ? "up" : "down", 1);
			setenv("INTERFACE", ifname, 1);
			execl("/sbin/hotplug-call", "hotplug-call", "carrier", (char  *)NULL);
		}
		
		pid = wait(NULL);
		if (pid < 0)
			perror("wait");
	}

out:
	return 0;
}

static void read_cb(struct ev_loop *loop, ev_io *w, int revents)
{
	nl_recvmsgs_default((struct nl_sock *)(w->data));
}

int main(int argc, char **argv)
{
	struct nl_sock *sock;
	struct ev_loop *loop = EV_DEFAULT;
	ev_io watcher;
	
	sock = create_socket(NETLINK_ROUTE, 0);
	if (!sock)
		return -1;
	
	nl_socket_modify_cb(sock, NL_CB_VALID, NL_CB_CUSTOM, cb_rtnl_event, NULL);
	nl_socket_disable_seq_check(sock);
	nl_socket_add_membership(sock, RTNLGRP_LINK);
	
	watcher.data = sock;
	ev_io_init(&watcher, read_cb, nl_socket_get_fd(sock), EV_READ);
	ev_io_start(loop, &watcher);
		
	ev_run(loop, 0);
	return 0;
}
