package xinlake.tunnel.core.shadowsocks;

import xinlake.tunnel.aidl.ITunnelEvent;
import xinlake.tunnel.aidl.ITunnelMethod;
import xinlake.tunnel.core.TunnelCore;

/**
 * 2021-11
 */
public class ServiceBinder extends ITunnelMethod.Stub {
    final private SSService service;

    public ServiceBinder(SSService service) {
        this.service = service;
    }

    @Override
    public void setListener(ITunnelEvent listener) {
        service.setListener(listener);
    }

    @Override
    public void setProxyPort(int port) {
        TunnelCore.instance().proxyPort = port;
    }

    @Override
    public void setDnsLocalPort(int port) {
        TunnelCore.instance().dnsLocalPort = port;
    }

    @Override
    public void setDnsRemoteAddress(String address) {
        TunnelCore.instance().dnsRemoteAddress = address;
    }

    @Override
    public boolean startService(int serverId,
                                int port, String address, String password, String encrypt) {
        return service.startService(serverId, port, address, password, encrypt);
    }

    @Override
    public void stopService() {
        service.stopRunner();
    }
}
