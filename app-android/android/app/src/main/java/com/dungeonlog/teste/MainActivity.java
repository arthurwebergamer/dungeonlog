package com.dungeonlog.teste;

import android.os.Build;
import android.view.Display;
import android.view.WindowManager;

import android.view.View;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsAnimationCompat;
import androidx.core.view.WindowInsetsCompat;
import android.webkit.WebView;
import com.getcapacitor.BridgeActivity;
import com.getcapacitor.WebViewListener;
import java.util.List;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(android.os.Bundle savedInstanceState) {
        registerPlugin(HapticosPlugin.class);
        super.onCreate(savedInstanceState);
        pedirMaiorTaxaDeAtualizacao();
        acompanharAnimacaoDoTeclado();
    }

    private float densidade() { return getResources().getDisplayMetrics().density; }

    private void enviarTeclado(int pxInferior) {
        final int dp = Math.round(pxInferior / densidade());
        if (getBridge() == null || getBridge().getWebView() == null) return;
        getBridge().getWebView().evaluateJavascript("window.__kb&&window.__kb(" + dp + ")", null);
    }

    // O teclado NAO redimensiona mais o WebView (isso refazia o layout da pagina inteira a cada quadro = travada).
    // A janela fica fixa; mandamos a altura do teclado pro JS, que so sobe a folha (transform, barato).
    private void acompanharAnimacaoDoTeclado() {
        final View decor = getWindow().getDecorView();
        ViewCompat.setOnApplyWindowInsetsListener(decor, (v, insets) -> {
            Insets sb = insets.getInsets(WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.displayCutout());
            boolean tecladoVisivel = insets.isVisible(WindowInsetsCompat.Type.ime());
            v.setPadding(0, 0, 0, 0);
            WindowInsetsCompat novos = new WindowInsetsCompat.Builder(insets)
                .setInsets(WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.displayCutout(),
                    Insets.of(sb.left, sb.top, sb.right, tecladoVisivel ? 0 : sb.bottom))
                .build();
            float d = densidade();
            if (getBridge() != null && getBridge().getWebView() != null) {
                String js = "try{var r=document.documentElement.style;"
                    + "r.setProperty('--safe-area-inset-top','" + (int) (sb.top / d) + "px');"
                    + "r.setProperty('--safe-area-inset-right','" + (int) (sb.right / d) + "px');"
                    + "r.setProperty('--safe-area-inset-bottom','" + (int) ((tecladoVisivel ? 0 : sb.bottom) / d) + "px');"
                    + "r.setProperty('--safe-area-inset-left','" + (int) (sb.left / d) + "px');}catch(e){}";
                getBridge().getWebView().evaluateJavascript(js, null);
            }
            if (!tecladoVisivel) enviarTeclado(0);
            return novos;
        });
        // pagina carregou: reaplica os insets (na 1a abertura os valores chegam antes da pagina existir e se perdiam)
        getBridge().addWebViewListener(new WebViewListener() {
            @Override
            public void onPageCommitVisible(WebView view, String url) {
                view.post(() -> { view.requestApplyInsets(); decor.requestApplyInsets(); });
            }
            @Override
            public void onPageLoaded(WebView view) {
                view.post(() -> { view.requestApplyInsets(); decor.requestApplyInsets(); });
            }
        });
        ViewCompat.setWindowInsetsAnimationCallback(decor, new WindowInsetsAnimationCompat.Callback(WindowInsetsAnimationCompat.Callback.DISPATCH_MODE_CONTINUE_ON_SUBTREE) {
            @Override
            public WindowInsetsCompat onProgress(WindowInsetsCompat insets, List<WindowInsetsAnimationCompat> animacoes) {
                for (WindowInsetsAnimationCompat a : animacoes) {
                    if ((a.getTypeMask() & WindowInsetsCompat.Type.ime()) != 0) {
                        int ime = insets.getInsets(WindowInsetsCompat.Type.ime()).bottom;
                        int nav = insets.getInsets(WindowInsetsCompat.Type.navigationBars()).bottom;
                        enviarTeclado(Math.max(0, ime - nav));
                        break;
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
