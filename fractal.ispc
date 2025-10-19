struct Complex {
    double re;
    double im;
};

void calculate_roots(uniform double n, uniform Complex uniform *roots) {
    uniform float pi2 = 6.283185307179586f;
    uniform int un = n;
    for (uniform int k = 0; k < un; k++) {
        uniform Complex root;
        sincos(pi2 * (uniform double)k / n, &root.re, &root.im);
        roots[k] = root;
    }
}

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

export void draw_image(uniform int width, uniform int height,
                       uniform int buffer[], uniform int n, uniform int max_iter, Complex uniform &a) {
    uniform int color_mode = 0;
    uniform double SQ3 = 1.7320508075688772;
    uniform Complex a_ = a;
    uniform double xscale = 10.0 / (double)width;
    uniform double yscale = 10.0 / (double)height;
    uniform Complex uniform* roots = new Complex[n];

    if (color_mode == 1) {
        calculate_roots((uniform double)n, roots);
    }

    for (uniform int y = 0; y < height; y++) {
        foreach (x = 0 ... width) {
            varying int idx = x + y * width;
            varying Complex z;
            z.re = (double)x * xscale - 5.0;
            z.im = -((double)y * yscale - 5.0);
            varying Complex w = poly(z, n);
            varying double f = 1.0;
            varying int iter = 0;

            while (f > 0.01 && complex_mag2(w) > 0.01 && iter < max_iter / 2) {
                varying Complex dw = dpoly(z, n);
                z = newton_step(z, w, dw, a_);
                w = poly(z, n);
                f *= 0.95;
                iter++;
            }

            double min = 1000000.0;
            int min_ri = 0;
            for (uniform int ri = 0; ri < n; ri++) {
                Complex root = roots[ri];
                Complex temp = {root.re - z.re, root.im - z.im};
                double d = complex_mag2(temp);
                if (d < min) {
                    min = d;
                    min_ri = ri;
                }
            }
            if (color_mode == 0) {
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
            } else {
                z = roots[min_ri];
                f = 0.6;
            }

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

            buffer[idx] = (A << 24) | (R << 16) | (G << 8) | B;
        }
    }

    delete[] roots;
    roots = NULL;
}