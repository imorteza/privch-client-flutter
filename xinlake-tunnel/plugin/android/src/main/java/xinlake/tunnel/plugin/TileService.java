package xinlake.tunnel.plugin;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.graphics.drawable.Icon;
import android.os.IBinder;
import android.service.quicksettings.Tile;

import xinlake.tunnel.R;
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
    // tunnel service
    private ITunnelMethod tunnelMethod;
    private final ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            tunnelMethod = ITunnelMethod.Stub.asInterface(service);

            TileService.this.registerReceiver(tunnelReceiver,
                new IntentFilter(TunnelCore.ACTION_EVENT_BROADCAST));

            // refresh tile
            updateState();
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            TileService.this.unregisterReceiver(tunnelReceiver);
            tunnelMethod = null;

            // disable tile
            updateState(-1);
        }

        @Override
        public void onBindingDied(ComponentName name) {
            TileService.this.unregisterReceiver(tunnelReceiver);
            tunnelMethod = null;

            // disable tile
            updateState(-1);
        }
    };

    private final BroadcastReceiver tunnelReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            int status = intent.getIntExtra("status", -1);
            updateState(status);
        }
    };

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
            tile.setIcon(Icon.createWithResource(this, R.drawable.sharp_gpp_good_24));
        } else if (tunnelState == TunnelCore.STATE_STOPPED) {
            tile.setState(Tile.STATE_INACTIVE);
            tile.setIcon(Icon.createWithResource(this, R.drawable.sharp_security_24));
        } else {
            tile.setState(Tile.STATE_UNAVAILABLE);
            tile.setIcon(Icon.createWithResource(this, R.drawable.sharp_gpp_maybe_24));
        }

        // update tile
        tile.updateTile();
    }

    // bind tunnel service
    private void bindTunnel() {
        final Context context = getApplicationContext();
        context.bindService(
            new Intent(context, SSService.class),
            serviceConnection, Context.BIND_AUTO_CREATE);
    }

    // unbind tunnel service
    private void unbindTunnel() {
        final Context context = getApplicationContext();
        try {
            context.unbindService(serviceConnection);
        } catch (Exception exception) {
            exception.printStackTrace();
        }
    }

    @Override
    public void onClick() {
        if (tunnelMethod != null) {
            boolean toggleable;
            try {
                toggleable = tunnelMethod.toggleService();
            } catch (Exception exception) {
                toggleable = false;
                exception.printStackTrace();
            }

            if (toggleable) {
                return;
            }
        }

        updateState(-1);
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
