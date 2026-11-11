package com.dungeonlog.teste;

import android.content.Context;
import android.os.Build;
import android.os.VibrationEffect;
import android.os.Vibrator;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import org.json.JSONArray;
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
                v.vibrate(VibrationEffect.createWaveform(tempos, amps, -1));
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
            v.vibrate(c.compose());
            call.resolve();
        } catch (Exception e) {
            call.reject(e.getMessage());
        }
    }
}
