package com.dungeonlog.teste;

import android.content.Context;
import com.swmansion.pulsar.Pulsar;

// Isolado do plugin principal: se o Pulsar falhar ao carregar, so ele quebra.
public class PulsarHelper {
    private static Pulsar pulsar;

    public static void tocar(Context ctx, String nome) throws Exception {
        if (pulsar == null) pulsar = new Pulsar(ctx.getApplicationContext());
        var preset = pulsar.getPresets().getByName(nome);
        if (preset == null) throw new Exception("preset nao encontrado: " + nome);
        preset.play();
    }
}
