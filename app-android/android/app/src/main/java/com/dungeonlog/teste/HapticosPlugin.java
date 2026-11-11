package com.dungeonlog.teste;

import android.content.Context;
import android.os.Build;
import android.view.inputmethod.InputMethodManager;
import android.webkit.WebView;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.os.VibrationAttributes;
import android.media.AudioAttributes;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import org.json.JSONArray;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "Hapticos")
public class HapticosPlugin extends Plugin {

    // Dispara com o "uso" declarado: touch (cliques de interface) ou padrao
    private void disparar(Vibrator v, VibrationEffect e, boolean touch) {
        if (touch && Build.VERSION.SDK_INT >= 33) {
            v.vibrate(e, VibrationAttributes.createForUsage(VibrationAttributes.USAGE_TOUCH));
        } else if (touch && Build.VERSION.SDK_INT >= 26) {
            v.vibrate(e, new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION).setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION).build());
        } else {
            v.vibrate(e);
        }
    }


    // Efeitos prontos do Android (API 29+): 0 click, 1 double click, 2 tick, 5 heavy click
    @PluginMethod
    public void efeito(PluginCall call) {
        int id = call.getInt("id", 0);
        try {
            Vibrator v = (Vibrator) getContext().getSystemService(Context.VIBRATOR_SERVICE);
            if (v != null && Build.VERSION.SDK_INT >= 29) {
                disparar(v, VibrationEffect.createPredefined(id), call.getBoolean("touch", false));
                call.resolve();
            } else {
                call.reject("sem suporte");
            }
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    // Constantes de HapticFeedback da View (tap de teclado, tique de relogio, confirmar, rejeitar...)
    @PluginMethod
    public void feedback(final PluginCall call) {
        final int c = call.getInt("tipo", 3);
        final int flag = call.getInt("flag", 2);
        try {
            getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {
                        // flag 2 = FLAG_IGNORE_GLOBAL_SETTING (vibra mesmo com "vibrar ao toque" desligado no sistema)
                        getBridge().getWebView().performHapticFeedback(c, flag);
                        call.resolve();
                    } catch (Exception e) {
                        call.reject(e.getMessage());
                    }
                }
            });
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    // Onda com intensidade: tempos (ms) alternando pausa/vibra e amps (0-255) do mesmo tamanho
    @PluginMethod
    public void onda(PluginCall call) {
        try {
            JSONArray t = call.getArray("tempos");
            JSONArray a = call.getArray("amps");
            long[] tempos = new long[t.length()];
            int[] amps = new int[a.length()];
            for (int i = 0; i < tempos.length; i++) tempos[i] = t.getLong(i);
            for (int i = 0; i < amps.length; i++) amps[i] = a.getInt(i);
            Vibrator v = (Vibrator) getContext().getSystemService(Context.VIBRATOR_SERVICE);
            if (v != null && Build.VERSION.SDK_INT >= 26) {
                disparar(v, VibrationEffect.createWaveform(tempos, amps, -1), call.getBoolean("touch", false));
                JSObject r = new JSObject();
                r.put("controleIntensidade", v.hasAmplitudeControl());
                call.resolve(r);
            } else {
                call.reject("sem suporte");
            }
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }

    // Primitivas (API 30+): ids 1 click, 2 thud, 3 spin, 4 quick rise, 5 slow rise, 6 quick fall, 7 tick, 8 low tick
    @PluginMethod
    public void primitivas(PluginCall call) {
        try {
            JSONArray ids = call.getArray("ids");
            JSONArray esc = call.getArray("escalas");
            JSONArray atr = call.getArray("atrasos");
            Vibrator v = (Vibrator) getContext().getSystemService(Context.VIBRATOR_SERVICE);
            if (v == null || Build.VERSION.SDK_INT < 30) { call.reject("sem suporte (API<30)"); return; }
            VibrationEffect.Composition c = VibrationEffect.startComposition();
            for (int i = 0; i < ids.length(); i++) {
                int id = ids.getInt(i);
                if (!v.areAllPrimitivesSupported(id)) { call.reject("primitiva " + id + " nao suportada"); return; }
                c.addPrimitive(id, (float) esc.getDouble(i), atr.getInt(i));
            }
            disparar(v, c.compose(), call.getBoolean("touch", false));
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    // Vibra DENTRO do evento de toque (sincrono, na thread de UI), como um app nativo faz.
    // quando: 0 = ao encostar (DOWN), 1 = ao soltar (UP); tipo < 0 desliga
    @PluginMethod
    public void modoToque(final PluginCall call) {
        final int tipo = call.getInt("tipo", -1);
        final int quando = call.getInt("quando", 1);
        final int flag = call.getInt("flag", 0);
        try {
            getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    final android.webkit.WebView w = getBridge().getWebView();
                    if (tipo < 0) { w.setOnTouchListener(null); call.resolve(); return; }
                    w.setOnTouchListener(new android.view.View.OnTouchListener() {
                        public boolean onTouch(android.view.View v, android.view.MotionEvent e) {
                            int a = e.getActionMasked();
                            if ((quando == 0 && a == android.view.MotionEvent.ACTION_DOWN) || (quando == 1 && a == android.view.MotionEvent.ACTION_UP)) {
                                v.performHapticFeedback(tipo, flag);
                            }
                            return false;
                        }
                    });
                    call.resolve();
                }
            });
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    // Feedback disparado pela janela principal (DecorView) ou por uma View nativa nova, nao pelo WebView
    @PluginMethod
    public void feedbackJanela(final PluginCall call) {
        final int c = call.getInt("tipo", 3);
        final int flag = call.getInt("flag", 0);
        final String alvo = call.getString("alvo", "decor");
        try {
            getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {
                        android.view.View v;
                        if ("nova".equals(alvo)) {
                            v = new android.view.View(getActivity());
                            ((android.view.ViewGroup) getActivity().getWindow().getDecorView()).addView(v, new android.view.ViewGroup.LayoutParams(1, 1));
                            v.performHapticFeedback(c, flag);
                            ((android.view.ViewGroup) getActivity().getWindow().getDecorView()).removeView(v);
                        } else if ("content".equals(alvo)) {
                            getActivity().findViewById(android.R.id.content).performHapticFeedback(c, flag);
                        } else {
                            getActivity().getWindow().getDecorView().performHapticFeedback(c, flag);
                        }
                        call.resolve();
                    } catch (Exception e) {
                        call.reject(e.getMessage());
                    }
                }
            });
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
    // Toca um preset do Pulsar pelo nome (ex.: "Tick", "Knock", "Peck")
    @PluginMethod
    public void pulsar(PluginCall call) {
        try {
            PulsarHelper.tocar(getContext(), call.getString("nome", ""));
            call.resolve();
        } catch (Throwable e) {
            call.reject("pulsar: " + e);
        }
    }

    // Abre o teclado na hora (focus() fora de gesto nao abre o IME no WebView)
    @PluginMethod
    public void teclado(PluginCall call) {
        final WebView wv = getBridge().getWebView();
        getActivity().runOnUiThread(() -> {
            try {
                wv.requestFocus();
                InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                if (imm != null) imm.showSoftInput(wv, InputMethodManager.SHOW_IMPLICIT);
            } catch (Throwable e) { }
        });
        call.resolve();
    }
}
