package com.dungeonlog.teste;

import android.os.Build;
import android.view.Display;
import android.view.WindowManager;

import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(android.os.Bundle savedInstanceState) {
        registerPlugin(HapticosPlugin.class);
        super.onCreate(savedInstanceState);
        pedirMaiorTaxaDeAtualizacao();
    }

    @Override
    public void onResume() {
        super.onResume();
        pedirMaiorTaxaDeAtualizacao();
    }

    // O WebView de um app costuma ficar em 60 Hz; o Chrome pede a taxa maxima da tela. Pedimos a maior (mesma resolucao).
    private void pedirMaiorTaxaDeAtualizacao() {
        try {
            if (Build.VERSION.SDK_INT < 23) return;
            Display d = Build.VERSION.SDK_INT >= 30 ? getDisplay() : getWindowManager().getDefaultDisplay();
            if (d == null) return;
            Display.Mode atual = d.getMode();
            Display.Mode melhor = atual;
            for (Display.Mode m : d.getSupportedModes()) {
                if (m.getPhysicalWidth() == atual.getPhysicalWidth() && m.getPhysicalHeight() == atual.getPhysicalHeight()
                        && m.getRefreshRate() > melhor.getRefreshRate()) {
                    melhor = m;
                }
            }
            WindowManager.LayoutParams lp = getWindow().getAttributes();
            lp.preferredDisplayModeId = melhor.getModeId();
            lp.preferredRefreshRate = melhor.getRefreshRate();
            getWindow().setAttributes(lp);
        } catch (Throwable t) {
            // sem efeito colateral: se falhar, fica como estava
        }
    }
}
