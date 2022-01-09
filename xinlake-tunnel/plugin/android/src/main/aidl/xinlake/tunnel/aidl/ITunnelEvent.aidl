package xinlake.tunnel.aidl;

// ITunnelEvent.aidl
// int, long, boolean, float, double, String

interface ITunnelEvent {
    void onMessage(in String message);
    void onServerChanged(in int serverId);
    void onStateChanged(in int state);
}
