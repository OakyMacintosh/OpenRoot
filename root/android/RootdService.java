package me.openroot;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;
import java.io.File;
import java.io.IOException;

public class RootdService extends Service {
    private static final String TAG = "RootdService";
    private static final String ROOTD_DIR = "/data/data/me.openroot/rootd";
    private Process rootdProcess;

    @Override
    public void onCreate() {
        super.onCreate();
        setupRootd();
    }

    private void setupRootd() {
        File rootdDir = new File(ROOTD_DIR);
        if (!rootdDir.exists()) {
            // Run installation script
            try {
                Process process = Runtime.getRuntime().exec("su -c sh /data/data/me.openroot/install.sh");
                process.waitFor();
            } catch (IOException | InterruptedException e) {
                Log.e(TAG, "Failed to run installation script", e);
            }
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        startRootd();
        return START_STICKY;
    }

    private void startRootd() {
        try {
            String[] cmd = {ROOTD_DIR + "/bin/rootd", "--config", ROOTD_DIR + "/etc/rootd.conf"};
            rootdProcess = Runtime.getRuntime().exec(cmd);
            
            // Start monitoring process output
            new Thread(() -> {
                try {
                    int exitCode = rootdProcess.waitFor();
                    Log.i(TAG, "rootd exited with code: " + exitCode);
                } catch (InterruptedException e) {
                    Log.e(TAG, "rootd process interrupted", e);
                }
            }).start();
        } catch (IOException e) {
            Log.e(TAG, "Failed to start rootd", e);
        }
    }

    @Override
    public void onDestroy() {
        if (rootdProcess != null) {
            rootdProcess.destroy();
        }
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}