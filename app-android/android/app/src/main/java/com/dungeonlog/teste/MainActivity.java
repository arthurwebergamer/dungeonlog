package com.dungeonlog.teste;

import android.os.Build;
import android.view.Display;
import android.view.WindowManager;

import android.view.View;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsAnimationCompat;
import androidx.core.view.WindowInsetsCompat;
import com.getcapacitor.BridgeActivity;
import java.util.List;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(android.os.Bundle savedInstanceState) {
        registerPlugin(HapticosPlugin.class);
        super.onCreate(savedInstanceState);
        pedirMaiorTaxaDeAtualizacao();
        acompanharAnimacaoDoTeclado();
    }

    private int baseInferior = -1;

    // O Capacitor so ajusta o padding da janela no inicio/fim da animacao do teclado (pulo). Aqui acompanhamos cada quadro.
    private void acompanharAnimacaoDoTeclado() {
        final View decor = getWindow().getDecorView();
        ViewCompat.setWindowInsetsAnimationCallback(decor, new WindowInsetsAnimationCompat.Callback(WindowInsetsAnimationCompat.Callback.DISPATCH_MODE_CONTINUE_ON_SUBTREE) {
            @Override
            public void onPrepare(WindowInsetsAnimationCompat animation) {
                WindowInsetsCompat atual = ViewCompat.getRootWindowInsets(decor);
                boolean tecladoVisivel = atual != null && atual.isVisible(WindowInsetsCompat.Type.ime());
                if (baseInferior < 0 && !tecladoVisivel) baseInferior = decor.getPaddingBottom();
            }

            @Override
            public WindowInsetsCompat onProgress(WindowInsetsCompat insets, List<WindowInsetsAnimationCompat> animacoes) {
                boolean temTeclado = false;
                for (WindowInsetsAnimationCompat a : animacoes) {
                    if ((a.getTypeMask() & WindowInsetsCompat.Type.ime()) != 0) temTeclado = true;
                }
                if (temTeclado) {
                    Insets ime = insets.getInsets(WindowInsetsCompat.Type.ime());
                    int base = baseInferior < 0 ? 0 : baseInferior;
                    int inferior = Math.max(base, ime.bottom);
                    if (decor.getPaddingBottom() != inferior) {
                        decor.setPadding(decor.getPaddingLeft(), decor.getPaddingTop(), decor.getPaddingRight(), inferior);
                    }
                }
                return insets;
            }
        });
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
