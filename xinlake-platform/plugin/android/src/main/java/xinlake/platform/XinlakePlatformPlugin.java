package xinlake.platform;

import android.Manifest;
import android.app.Activity;
import android.app.UiModeManager;
import android.content.ClipData;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.util.Consumer;
import androidx.core.util.Pair;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import xinlake.armoury.XinFile;
import xinlake.armoury.XinMobile;

/**
 * XinlakePlatformPlugin
 *
 * @author Xinlake Liu
 * @version 2022.04
 */
public class XinlakePlatformPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static final int ACTION_PICK_FILE = 7039;

    private MethodChannel channel;
    private ActivityPluginBinding binding;

    private int actionRequestCode = 1000;
    private int permissionRequestCode = 1000;
    private final HashMap<Integer, Pair<Integer, Consumer<LinkedList<Uri>>>> activityRequests = new HashMap<>();
    private final HashMap<Integer, Pair<String, Consumer<Boolean>>> permissionRequests = new HashMap<>();

    private void pickFile(MethodCall call, Result result) {
        final String mimeType;
        final XinFile.AppDir cacheDir;
        final Boolean cacheOverwrite;
        final Boolean multiSelection;

        // check parameters
        try {
            multiSelection = call.argument("multiSelection");
            mimeType = call.argument("fileTypes");
            cacheOverwrite = call.argument("cacheOverwrite");

            if (mimeType == null) {
                throw new Exception();
            }

            // 0: internalCacheDir, 1: internalFilesDir
            // 2: externalCacheDir, 3: externalFilesDir
            final Number argCacheDirIndex = call.argument("cacheDirIndex");
            final int cacheDirIndex = (argCacheDirIndex != null)
                ? argCacheDirIndex.intValue() : -1;

            switch (cacheDirIndex) {
                case 0:
                    cacheDir = XinFile.AppDir.InternalCache;
                    break;
                case 1:
                    cacheDir = XinFile.AppDir.InternalFiles;
                    break;
                case 2:
                    cacheDir = XinFile.AppDir.ExternalCache;
                    break;
                case 3:
                    cacheDir = XinFile.AppDir.ExternalFiles;
                    break;
                default:
                    cacheDir = null;
                    break;
            }
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        // create intent
        final Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.putExtra(Intent.EXTRA_LOCAL_ONLY, true);
        intent.setTypeAndNormalize(mimeType);
        if (multiSelection != null) {
            intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, multiSelection);
        }

        final Activity activity = binding.getActivity();
        if (intent.resolveActivity(activity.getPackageManager()) == null) {
            result.error("Unable to handle this intent", null, null);
            return;
        }

        // start the intent
        activityRequests.put(++actionRequestCode, new Pair<>(ACTION_PICK_FILE, uriList -> {
            // user canceled
            if (uriList == null) {
                result.success(null);
                return;
            }

            // get path and send results
            if (cacheDir != null) {
                new Thread(() -> {
                    final ArrayList<String> pathList = new ArrayList<>();
                    final boolean overwrite = (cacheOverwrite != null && cacheOverwrite);
                    for (Uri uri : uriList) {
                        final String filePath = XinFile.cacheFromUri(activity, uri, cacheDir, overwrite);
                        if (filePath != null) {
                            pathList.add(filePath);
                        }
                    }
                    // send results when files has been copied
                    activity.runOnUiThread(() -> result.success(pathList));
                }).start();
            } else {
                final ArrayList<HashMap<String, Object>> pathList = new ArrayList<>();
                for (Uri uri : uriList) {
                    final String filePath = XinFile.getPath(activity, uri);
                    if (filePath != null) {
                        final File file = new File(filePath);
                        final HashMap<String, Object> map = new HashMap<>();
                        map.put("name", XinFile.getName(filePath));
                        map.put("path", filePath);
                        map.put("length", file.length());
                        map.put("modified-ms", file.lastModified());
                        pathList.add(map);
                    }
                }
                result.success(pathList);
            }
        }));

        try {
            activity.startActivityForResult(intent, actionRequestCode);
        } catch (Exception exception) {
            result.error("Unable to handle this intent", null, null);
        }
    }

    // UI is rendered by Flutter, just modify the color of the navigate bar here
    private void setNativeUiMode(MethodCall call, Result result) {
        final int nightMode;
        final int darkColor;
        final int lightColor;
        final Integer dividerColor;
        final int animateMs;

        try {
            final Number argModeIndex = call.argument("modeIndex");
            final Number argDarkColor = call.argument("darkColor");
            final Number argLightColor = call.argument("lightColor");
            if (argModeIndex == null || argDarkColor == null || argLightColor == null) {
                throw new Exception();
            }

            // light = 0, dark, system, custom
            switch (argModeIndex.intValue()) {
                case 0:
                    nightMode = UiModeManager.MODE_NIGHT_NO;
                    break;
                case 1:
                    nightMode = UiModeManager.MODE_NIGHT_YES;
                    break;
                case 2:
                case 3:
                    nightMode = UiModeManager.MODE_NIGHT_AUTO;
                    // TODO: nightMode = UiModeManager.MODE_NIGHT_CUSTOM;
                    break;
                default:
                    throw new Exception();
            }

            darkColor = argDarkColor.intValue();
            lightColor = argLightColor.intValue();

            final Number argDividerColor = call.argument("dividerColor");
            if (argDividerColor != null) {
                dividerColor = argDividerColor.intValue();
            } else {
                dividerColor = null;
            }

            final Number argAnimateMs = call.argument("animateMs");
            if (argAnimateMs != null) {
                animateMs = argAnimateMs.intValue();
            } else {
                animateMs = 0;
            }
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        final Activity activity = binding.getActivity();
        final boolean isDark = (nightMode == UiModeManager.MODE_NIGHT_AUTO)
            ? XinMobile.getNightMode(activity)
            : (nightMode == UiModeManager.MODE_NIGHT_YES);

        XinMobile.setNavigationBar(activity,
            isDark ? darkColor : lightColor,
            dividerColor, animateMs);

        result.success(null);
    }

    private void getAppDir(MethodCall call, Result result) {
        final int appDirIndex;

        try {
            final Number argAppDirIndex = call.argument("appDirIndex");
            if (argAppDirIndex != null) {
                appDirIndex = argAppDirIndex.intValue();
            } else {
                appDirIndex = -1;
            }
        } catch (Exception exception) {
            result.error("Invalid parameters", null, null);
            return;
        }

        // 0: internalCacheDir, 1: internalFilesDir
        // 2: externalCacheDir, 3: externalFilesDir
        final String dirPath;
        switch (appDirIndex) {
            case 0:
                dirPath = binding.getActivity().getCacheDir().getAbsolutePath();
                break;
            case 1:
                dirPath = binding.getActivity().getFilesDir().getAbsolutePath();
                break;
            case 2:
                dirPath = binding.getActivity().getExternalCacheDir().getAbsolutePath();
                break;
            case 3:
                dirPath = binding.getActivity().getExternalFilesDir(null).getAbsolutePath();
                break;
            default:
                dirPath = binding.getActivity().getDataDir().getAbsolutePath();
                break;
        }

        result.success(dirPath);
    }

    private void getAppVersion(Result result) {
        final Activity activity = binding.getActivity();
        final PackageInfo packageInfo;
        try {
            String packageName = activity.getPackageName();
            packageInfo = activity.getPackageManager().getPackageInfo(packageName, 0);
        } catch (Exception exception) {
            result.error("getPackageInfo", null, null);
            return;
        }

        result.success(new HashMap<String, Object>() {{
            put("version", packageInfo.versionName);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                put("build-number", packageInfo.getLongVersionCode());
            } else {
                put("build-number", packageInfo.versionCode);
            }
            put("package-name", packageInfo.packageName);
            put("updated-utc", packageInfo.lastUpdateTime);
        }});
    }

    private void checkAndRequestPermission(Consumer<Boolean> consumer) {
        final String permission = Manifest.permission.READ_EXTERNAL_STORAGE;
        final String[] permissions = new String[]{permission};

        final Activity activity = binding.getActivity();
        permissionRequests.put(++permissionRequestCode, new Pair<>(permission, consumer));
        if (activity.checkSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
            activity.requestPermissions(permissions, permissionRequestCode);
        } else {
            handlePermissionResult.onRequestPermissionsResult(permissionRequestCode, permissions,
                new int[]{PackageManager.PERMISSION_GRANTED});
        }
    }

    private final PluginRegistry.ActivityResultListener handleActivityResult =
        (requestCode, resultCode, data) -> {
            Pair<Integer, Consumer<LinkedList<Uri>>> action = activityRequests.remove(requestCode);
            if (action != null) {
                assert action.first != null;
                assert action.second != null;
                if (action.first == ACTION_PICK_FILE) {
                    // read results
                    if (resultCode == Activity.RESULT_OK && data != null) {
                        final Uri uriData = data.getData();
                        final ClipData clipData = data.getClipData();

                        final LinkedList<Uri> uriList = new LinkedList<>();
                        if (uriData != null) {
                            uriList.add(uriData);
                        } else if (clipData != null) {
                            int count = clipData.getItemCount();
                            for (int i = 0; i < count; ++i) {
                                uriList.add(clipData.getItemAt(i).getUri());
                            }
                        }

                        action.second.accept(uriList);
                    } else {
                        // user canceled
                        action.second.accept(null);
                    }
                }

                return true;
            }

            return false;
        };

    private final PluginRegistry.RequestPermissionsResultListener handlePermissionResult =
        (requestCode, permissions, grantResults) -> {
            Pair<String, Consumer<Boolean>> request = permissionRequests.remove(requestCode);
            if (request != null) {
                assert request.second != null;

                String permission = request.first;
                boolean granted = (binding.getActivity().checkSelfPermission(permission)
                    == PackageManager.PERMISSION_GRANTED);

                request.second.accept(granted);
                return true;
            }

            return false;
        };

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "pickFile":
                checkAndRequestPermission(granted -> {
                    if (granted) {
                        pickFile(call, result);
                    } else {
                        result.error("Permission Denied", null, null);
                    }
                });
                break;
            case "setNativeUiMode":
                setNativeUiMode(call, result);
                break;
            case "getAppDir":
                getAppDir(call, result);
                break;
            case "getAppVersion":
                getAppVersion(result);
                break;
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "xinlake_platform");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    // ActivityAware -------------------------------------------------------------------------------
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        binding.addRequestPermissionsResultListener(handlePermissionResult);
        binding.addActivityResultListener(handleActivityResult);
        this.binding = binding;
    }

    @Override
    public void onDetachedFromActivity() {
        binding.removeRequestPermissionsResultListener(handlePermissionResult);
        binding.removeActivityResultListener(handleActivityResult);
        binding = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        binding.addRequestPermissionsResultListener(handlePermissionResult);
        binding.addActivityResultListener(handleActivityResult);
        this.binding = binding;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        binding.removeRequestPermissionsResultListener(handlePermissionResult);
        binding.removeActivityResultListener(handleActivityResult);
        binding = null;
    }
}
