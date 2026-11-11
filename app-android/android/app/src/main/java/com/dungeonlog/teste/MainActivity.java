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

    // Teste: fixa a taxa em ~60 Hz pra ritmo de quadros estavel (a 120 Hz o ritmo ficou irregular nas gravacoes).
    private void pedirMaiorTaxaDeAtualizacao() {
        try {
            if (Build.VERSION.SDK_INT < 23) return;
            Display d = Build.VERSION.SDK_INT >= 30 ? getDisplay() : getWindowManager().getDefaultDisplay();
            if (d == null) return;
            Display.Mode atual = d.getMode();
            Display.Mode melhor = atual;
            for (Display.Mode m : d.getSupportedModes()) {
                // fixa em ~60 Hz (ritmo estavel, como o Chrome): escolhe o modo mais proximo de 60 na mesma resolucao
                if (m.getPhysicalWidth() == atual.getPhysicalWidth() && m.getPhysicalHeight() == atual.getPhysicalHeight()
                        && Math.abs(m.getRefreshRate() - 60f) < Math.abs(melhor.getRefreshRate() - 60f)) {
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
