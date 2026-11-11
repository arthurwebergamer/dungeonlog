package com.dungeonlog.teste;

import android.content.Context;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "Hapticos")
public class HapticosPlugin extends Plugin {

    // Efeitos prontos do Android (API 29+): 0 click, 1 double click, 2 tick, 5 heavy click
    @PluginMethod
    public void efeito(PluginCall call) {
        int id = call.getInt("id", 0);
        try {
            Vibrator v = (Vibrator) getContext().getSystemService(Context.VIBRATOR_SERVICE);
            if (v != null && Build.VERSION.SDK_INT >= 29) {
                v.vibrate(VibrationEffect.createPredefined(id));
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
        try {
            getActivity().runOnUiThread(new Runnable() {
                public void run() {
                    try {
                        // flag 2 = FLAG_IGNORE_GLOBAL_SETTING (vibra mesmo com "vibrar ao toque" desligado no sistema)
                        getBridge().getWebView().performHapticFeedback(c, 2);
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
}
