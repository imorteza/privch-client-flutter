package xinlake.tunnel.aidl;
import xinlake.tunnel.aidl.ITunnelEvent;

// ITunnelMethod.aidl
// int, long, boolean, float, double, String

interface ITunnelMethod {
    void addListener(in String key, in ITunnelEvent listener);
    void removeListener(in String key);
    int getState();

    void setSocksPort(in int port);
    void setDnsLocalPort(in int port);
    void setDnsRemoteAddress(in String address);

    boolean startService(in int id, in int port, in String address, in String password, in String encrypt);
    void stopService();
    boolean toggleService();
}
