struct Complex {
    double re;
    double im;
};

export struct DrawParams {
    uniform Complex a;
    uniform int *uniform buffer;
    uniform int width;
    uniform int height;
    uniform int n;
    uniform int max_iter;
    uniform int threads;
};

inline varying Complex complex_mul(varying Complex a, varying Complex b) {
    varying Complex result = {
        a.re * b.re - a.im * b.im,
        a.re * b.im + a.im * b.re
    };
    return result;
}

inline varying double complex_mag2(varying Complex z) {
    return z.re * z.re + z.im * z.im;
}

varying Complex poly(varying Complex z, uniform int n) {
    varying Complex power = {1.0, 0.0};
    for (uniform int i = 0; i < n; i++) {
    power = complex_mul(power, z);
    }
    power.re -= 1.0;
    return power;
}

varying Complex dpoly(varying Complex z, uniform int n) {
    varying Complex power = {1.0, 0.0};
    for (uniform int i = 1; i < n; i++) {
        power = complex_mul(power, z);
    }
    varying Complex n_complex = {(double)n, 0.0};
    return complex_mul(n_complex, power);
}

varying Complex newton_step(varying Complex z, varying Complex w, varying Complex dw, varying Complex a) {
    varying double denom = complex_mag2(dw);
    if (denom < 1e-12) {
        return z;
    }
    varying Complex step;
    step.re = (w.re * dw.re + w.im * dw.im) / denom;
    step.im = (w.im * dw.re - w.re * dw.im) / denom;
    step = complex_mul(a, step);
    varying Complex result;
    result.re = z.re - step.re;
    result.im = z.im - step.im;
    return result;
}
void draw_task(uniform DrawParams uniform &params)
{
    uniform int color_mode = 0;
    uniform double SQ3 = 1.7320508075688772;
    uniform double xscale = 10.0 / (uniform double)params.width;
    uniform double yscale = 10.0 / (uniform double)params.height;
    uniform int max_iter_f2 = params.max_iter / 2;

    for (uniform int y = 0; y < params.height; y++) {
        foreach (x = 0 ... params.width) {
            varying int idx = x + y * params.width;
            varying Complex z;
            z.re = (double)x * xscale - 5.0;
            z.im = -((double)y * yscale - 5.0);
            varying Complex w = poly(z, params.n);
            varying double f = 1.0;
            varying int iter = 0;

            while (f > 0.01 && complex_mag2(w) > 0.01 && iter < max_iter_f2) {
                varying Complex dw = dpoly(z, params.n);
                z = newton_step(z, w, dw, params.a);
                w = poly(z, params.n);
                f *= 0.95;
                iter++;
            }

            varying Complex z_sq = complex_mul(z, z);
            varying double mag2 = complex_mag2(z);
            if (mag2 > 1e-12) {
                varying double scale = f * mag2;
                z_sq.re *= scale / mag2;
                z_sq.im *= scale / mag2;
            } else {
                z_sq.re = 0.0;
                z_sq.im = 0.0;
            }
            z = z_sq;

            varying double r = 0.5 * f + 0.24 * z.re - (SQ3 * 0.24) * z.im;
            varying double g = 0.5 * f + 0.24 * z.re + (SQ3 * 0.24) * z.im;
            varying double b = 0.5 * f - 0.48 * z.re;


            r = r < 0.0 ? 0.0 : (r > 1.0 ? 1.0 : r);
            g = g < 0.0 ? 0.0 : (g > 1.0 ? 1.0 : g);
            b = b < 0.0 ? 0.0 : (b > 1.0 ? 1.0 : b);

            varying int R = (int)(255.0 * r);
            varying int G = (int)(255.0 * g);
            varying int B = (int)(255.0 * b);
            varying int A = 255;

            params.buffer[idx] = (A << 24) | (R << 16) | (G << 8) | B;
        }
    }
}
export void draw_image(uniform DrawParams uniform &params) {
    draw_task(params);
}