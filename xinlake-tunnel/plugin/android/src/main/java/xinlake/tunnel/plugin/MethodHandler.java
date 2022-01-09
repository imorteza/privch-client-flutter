package xinlake.tunnel.plugin;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.net.VpnService;
import android.os.IBinder;

import androidx.annotation.NonNull;
import androidx.core.util.Consumer;
import androidx.core.util.Pair;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import xinlake.tunnel.aidl.ITunnelEvent;
import xinlake.tunnel.aidl.ITunnelMethod;
import xinlake.tunnel.core.shadowsocks.SSService;

public class MethodHandler implements
    PluginRegistry.ActivityResultListener,
    MethodChannel.MethodCallHandler {
    private static final int ACTION_ESTABLISH_VPN = 1;

    // queue activity actions
    private int activityActionCode = 7039;
    private final HashMap<Integer, Pair<Integer, Consumer<Boolean>>> activityActions = new HashMap<>();

    private ActivityPluginBinding binding;
    private EventHandler eventHandler;

    private ITunnelMethod tunnelMethod;
    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            tunnelMethod = ITunnelMethod.Stub.asInterface(service);
            try {
                tunnelMethod.setListener(tunnelEvent);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            tunnelMethod = null;
        }
    };

    private final ITunnelEvent tunnelEvent = new ITunnelEvent.Stub() {
        @Override
        public void onMessage(String message) {
            binding.getActivity().runOnUiThread(() -> eventHandler.notifyMessage(message));
        }

        @Override
        public void onServerChanged(int serverId) {
            binding.getActivity().runOnUiThread(() -> eventHandler.notifyServerChanged(serverId));
        }

        @Override
        public void onStateChanged(int state) {
            binding.getActivity().runOnUiThread(() -> eventHandler.notifyStateChanged(state));
        }
    };

    public void attachedToActivity(ActivityPluginBinding binding, EventHandler eventHandler) {
        binding.addActivityResultListener(this);
        this.binding = binding;
        this.eventHandler = eventHandler;
    }
    public void detachedFromActivity() {
        binding.removeActivityResultListener(this);
    }

    private void startShadowsocks(MethodCall call, MethodChannel.Result result) {
        final Integer serverId;
        final Integer port;
        final String address;
        final String password;
        final String encrypt;

        // check parameters
        try {
            serverId = call.argument("serverId");
            port = call.argument("port");
            address = call.argument("address");
            password = call.argument("password");
            encrypt = call.argument("encrypt");
            if (serverId == null || port == null || address == null ||
                password == null || encrypt == null) {
                throw new Exception();
            }
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        // establish a VPN connection
        activityActions.put(++activityActionCode, new Pair<>(ACTION_ESTABLISH_VPN, prepared -> {
            if (prepared) {
                try {
                    tunnelMethod.startService(serverId, port, address, password, encrypt);
                } catch (Exception exception) {
                    exception.printStackTrace();
                }
            }

            result.success(null);
        }));

        final Activity activity = binding.getActivity();
        Intent intent = VpnService.prepare(activity.getApplicationContext());
        if (intent != null) {
            activity.startActivityForResult(intent, activityActionCode);
        } else {
            onActivityResult(activityActionCode, Activity.RESULT_OK, null);
        }
    }

    private void stopService(MethodChannel.Result result) {
        try {
            tunnelMethod.stopService();
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        result.success(null);
    }

    private void updateSettings(MethodCall call, MethodChannel.Result result) {
        final Integer proxyPort;
        final Integer dnsLocalPort;
        final String dnsRemoteAddress;

        // check parameters
        try {
            proxyPort = call.argument("proxyPort");
            dnsLocalPort = call.argument("dnsLocalPort");
            dnsRemoteAddress = call.argument("dnsRemoteAddress");
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        if (proxyPort != null) {
            try {
                tunnelMethod.setProxyPort(proxyPort);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        if (dnsLocalPort != null) {
            try {
                tunnelMethod.setDnsLocalPort(dnsLocalPort);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        if (dnsRemoteAddress != null) {
            try {
                tunnelMethod.setDnsRemoteAddress(dnsRemoteAddress);
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }

        // send result
        result.success(null);
    }

    private void bindService(MethodCall call, MethodChannel.Result result) {
        final Integer proxyPort;
        final Integer dnsLocalPort;
        final String dnsRemoteAddress;

        // check parameters
        try {
            proxyPort = call.argument("proxyPort");
            dnsLocalPort = call.argument("dnsLocalPort");
            dnsRemoteAddress = call.argument("dnsRemoteAddress");

            if (proxyPort == null || dnsLocalPort == null || dnsRemoteAddress == null) {
                throw new Exception();
            }
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        // bind the vpn service and send initial data
        final Activity activity = binding.getActivity();

        Intent intent = new Intent(activity.getApplicationContext(), SSService.class);
        intent.putExtra("proxyPort", proxyPort);
        intent.putExtra("dnsLocalPort", dnsLocalPort);
        intent.putExtra("dnsRemoteAddress", dnsRemoteAddress);

        activity.getApplicationContext().bindService(intent, serviceConnection,
            Context.BIND_AUTO_CREATE);
        result.success(null);
    }

    private void unbindService(MethodChannel.Result result) {
        final Context context = binding.getActivity().getApplicationContext();

        // unbind and stop service
        try {
            context.unbindService(serviceConnection);
            context.stopService(new Intent(context, SSService.class));
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        result.success(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "startShadowsocks":
                startShadowsocks(call, result);
                break;
            case "stopService":
                stopService(result);
                break;

            case "updateSettings":
                updateSettings(call, result);
                break;

            case "bindService":
                bindService(call, result);
                break;
            case "unbindService":
                unbindService(result);
                break;
            default:
                result.notImplemented();
        }
    }

    /**
     * @return true if the result has been handled.
     */
    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Pair<Integer, Consumer<Boolean>> action = activityActions.remove(requestCode);
        if (action != null) {
            assert action.first != null;
            assert action.second != null;

            if (action.first == ACTION_ESTABLISH_VPN) {
                // care about resultCode only
                boolean prepared = resultCode == Activity.RESULT_OK;
                action.second.accept(prepared);
            }

            return true;
        }

        return false;
    }
}
