#include <iostream>
#include <fstream>
#include <cstdio>
#include <getopt.h>
#include "include/fractal_ispc.h"

void print_usage(const char* prog_name) {
    std::cout << "Usage: " << prog_name << " [OPTIONS]\n"
              << "Optional:\n"
              << "  -d, --degree N        Polynomial degree\n"
              << "  -s, --size WxH        Image resolution (default: 1024x1024)\n"
              << "  -i, --max-iter N      Maximum iterations (default: 250)\n"
              << "  -a, --step RE,IM      Step scaling complex (default: 1.0,0.0)\n"
              << "  -o, --output FILE     Output PPM (default: newton_fractal.ppm)\n"
              << "  -h, --help            Show help\n";
}

bool parse_size(const char* size_str, int& width, int& height) {
    int w, h;
    return (sscanf(size_str, "%dx%d", &w, &h) == 2 || sscanf(size_str, "%d x %d", &w, &h) == 2)
           && w > 0 && h > 0 && (width = w, height = h, true);
}

bool parse_complex(const char* size_str, ispc::Complex& a) {
    int re, im;
    return (sscanf(size_str, "%d,%d", &re, &im) == 2 || sscanf(size_str, "%d, %d", &re, &im) == 2)
           && (a.re = re, a.im = im, true);
}

int main(const int argc, char* argv[]) {
    ispc::DrawParams params = {
        .a = {1.0, 0.0},
        .buffer = nullptr,
        .width = 1024,
        .height = 1024,
        .n = 5,
        .max_iter = 250,
    };
    std::string output_file = "newton_fractal.ppm";

    static struct option long_options[] = {
        {"degree",    required_argument, nullptr, 'd'},
        {"size",      required_argument, nullptr, 's'},
        {"max-iter",  required_argument, nullptr, 'i'},
        {"step",      required_argument, nullptr, 'a'},
        {"output",    required_argument, nullptr, 'o'},
        {"help",      no_argument,       nullptr, 'h'},
        {nullptr, 0, nullptr, 0}
    };

    int opt;
    while ((opt = getopt_long(argc, argv, "d:s:i:a:o:h", long_options, nullptr)) != -1) {
        switch (opt) {
            case 'd':
                if ((params.n = std::atoi(optarg)) <= 0) { std::cerr << "Error: Degree > 0\n"; return 1; }
                break;
            case 's':
                if (!parse_size(optarg, params.width, params.height)) { std::cerr << "Error: Invalid size\n"; return 1; }
                break;
            case 'i':
                if ((params.max_iter = std::atoi(optarg)) <= 0) { std::cerr << "Error: Max iter > 0\n"; return 1; }
                break;
            case 'a':
                if (!parse_complex(optarg, params.a)) { std::cerr << "Error: Invalid step complex number\n"; return 1; }
                break;
            case 'o': output_file = optarg; break;
            case 'h': print_usage(argv[0]); return 0;
            default: print_usage(argv[0]); return 1;
        }
    }

    params.buffer = new int32_t[params.width * params.height];

    std::cout << "Rendering Newton fractal (z^" << params.n << " - 1 = 0)\n";

    ispc::draw_image(params);

    std::ofstream file(output_file, std::ios::binary);
    if (!file) { std::cerr << "Error: Cannot write file\n"; delete[] params.buffer; return 1; }

    file << "P6\n" << params.width << " " << params.height << "\n255\n";
    for (int i = 0; i < params.width * params.height; ++i) {
        unsigned int val = params.buffer[i];
        unsigned char r = (val >> 16) & 0xFF;
        unsigned char g = (val >> 8) & 0xFF;
        unsigned char b = val & 0xFF;
        file.write(reinterpret_cast<const char*>(&r), 1);
        file.write(reinterpret_cast<const char*>(&g), 1);
        file.write(reinterpret_cast<const char*>(&b), 1);
    }

    file.close();
    delete[] params.buffer;
    std::cout << "Saved " << output_file << std::endl;
    return 0;
}