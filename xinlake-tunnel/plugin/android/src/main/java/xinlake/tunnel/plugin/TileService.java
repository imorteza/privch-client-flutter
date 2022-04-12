package xinlake.tunnel.plugin;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.service.quicksettings.Tile;
import android.widget.Toast;

import xinlake.tunnel.aidl.ITunnelEvent;
import xinlake.tunnel.aidl.ITunnelMethod;
import xinlake.tunnel.core.TunnelCore;
import xinlake.tunnel.core.shadowsocks.SSService;

/**
 * [onStartListening] will not be called on XiaoMi 6 (Android 9),
 * thus, the service must be bound in [onTileAdded] on such devices
 *
 * @author Xinlake Liu
 */

public class TileService extends android.service.quicksettings.TileService {
    // service
    private ITunnelMethod tunnelMethod;
    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onBindingDied(ComponentName name) {
            try {
                tunnelMethod.removeListener("tile");
            } catch (Exception exception) {
                exception.printStackTrace();
            }

            tunnelMethod = null;
        }

        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            tunnelMethod = ITunnelMethod.Stub.asInterface(service);
            try {
                tunnelMethod.addListener("tile", tunnelEvent);
            } catch (Exception exception) {
                exception.printStackTrace();
            }

            // not necessary, already running on main thread
            new Handler(Looper.getMainLooper()).post(() -> updateState());
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            try {
                tunnelMethod.removeListener("tile");
            } catch (Exception exception) {
                exception.printStackTrace();
            }

            tunnelMethod = null;
        }
    };

    private final ITunnelEvent tunnelEvent = new ITunnelEvent.Stub() {
        @Override
        public void onMessage(String message) {
        }

        @Override
        public void onServerChanged(int serverId) {
        }

        @Override
        public void onStateChanged(int state) {
            new Handler(Looper.getMainLooper()).post(() -> updateState(state));
        }
    };

    private void bindTunnel() {
        // bind service
        final Context context = getApplicationContext();
        context.bindService(
            new Intent(context, SSService.class),
            serviceConnection, Context.BIND_AUTO_CREATE);
    }

    private void unbindTunnel() {
        // unbind and stop service
        final Context context = getApplicationContext();
        try {
            context.unbindService(serviceConnection);
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }

    private void updateState() {
        final int tunnelState;
        try {
            tunnelState = tunnelMethod.getState();
        } catch (Exception exception) {
            return;
        }

        updateState(tunnelState);
    }

    private void updateState(int tunnelState) {
        final Tile tile = getQsTile();
        if (tunnelState == TunnelCore.STATE_CONNECTED) {
            tile.setState(Tile.STATE_ACTIVE);
        } else if (tunnelState == TunnelCore.STATE_STOPPED) {
            tile.setState(Tile.STATE_INACTIVE);
        } else {
            tile.setState(Tile.STATE_UNAVAILABLE);
        }

        // update tile
        tile.updateTile();
    }

    @Override
    public void onClick() {
        if (tunnelMethod != null) {
            boolean toggled;
            try {
                toggled = tunnelMethod.toggleService();
            } catch (Exception exception) {
                toggled = false;
                exception.printStackTrace();
            }

            if (toggled) {
                //new Handler(Looper.getMainLooper()).postDelayed(this::updateState, 300);
                return;
            }
        }

        Toast.makeText(this, "Unable to perform action", Toast.LENGTH_LONG)
            .show();
    }

    // pull down status bar
    @Override
    public void onStartListening() {
        super.onStartListening();

        if (tunnelMethod != null) {
            updateState();
        } else {
            bindTunnel();
        }
    }

    @Override
    public void onStopListening() {
        super.onStopListening();
        unbindTunnel();
    }

    @Override
    public void onTileAdded() {
        super.onTileAdded();

        if (tunnelMethod != null) {
            updateState();
        } else {
            bindTunnel();
        }
    }

    @Override
    public void onTileRemoved() {
        super.onTileRemoved();
        unbindTunnel();
    }
}
