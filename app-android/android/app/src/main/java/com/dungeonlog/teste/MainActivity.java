package com.dungeonlog.teste;

import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(android.os.Bundle savedInstanceState) {
        registerPlugin(HapticosPlugin.class);
        super.onCreate(savedInstanceState);
    }
}
