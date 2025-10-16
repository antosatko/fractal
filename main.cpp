#include <iostream>
#include <fstream>
#include <getopt.h>
#include <cstdio>

extern "C" {
    void draw_image(int width, int height, unsigned int *buffer, int n, int max_iter, double a);
}

void print_usage(const char* prog_name) {
    std::cout << "Usage: " << prog_name << " [OPTIONS]\n"
              << "Optional:\n"
              << "  -d, --degree N        Polynomial degree\n"
              << "  -s, --size WxH        Image resolution (default: 1024x1024)\n"
              << "  -i, --max-iter N      Maximum iterations (default: 250)\n"
              << "  -a, --step A          Step scaling (default: 1.0)\n"
              << "  -o, --output FILE     Output PPM (default: newton_fractal.ppm)\n"
              << "  -h, --help            Show help\n";
}

bool parse_size(const char* size_str, int& width, int& height) {
    int w, h;
    return (sscanf(size_str, "%dx%d", &w, &h) == 2 || sscanf(size_str, "%d x %d", &w, &h) == 2)
           && w > 0 && h > 0 && (width = w, height = h, true);
}

int main(int argc, char* argv[]) {
    int degree = 5, width = 1024, height = 1024, max_iter = 250;
    double step = 1.0;
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
                if ((degree = std::atoi(optarg)) <= 0) { std::cerr << "Error: Degree > 0\n"; return 1; }
                break;
            case 's':
                if (!parse_size(optarg, width, height)) { std::cerr << "Error: Invalid size\n"; return 1; }
                break;
            case 'i':
                if ((max_iter = std::atoi(optarg)) <= 0) { std::cerr << "Error: Max iter > 0\n"; return 1; }
                break;
            case 'a': step = std::atof(optarg); break;
            case 'o': output_file = optarg; break;
            case 'h': print_usage(argv[0]); return 0;
            default: print_usage(argv[0]); return 1;
        }
    }

    auto* buffer = new unsigned int[width * height];

    std::cout << "Rendering Newton fractal (z^" << degree << " - 1 = 0)\n";
    draw_image(width, height, buffer, degree, max_iter, step);

    std::ofstream file(output_file, std::ios::binary);
    if (!file) { std::cerr << "Error: Cannot write file\n"; delete[] buffer; return 1; }

    file << "P6\n" << width << " " << height << "\n255\n";
    for (int i = 0; i < width * height; ++i) {
        unsigned int val = buffer[i];
        unsigned char r = (val >> 16) & 0xFF;
        unsigned char g = (val >> 8) & 0xFF;
        unsigned char b = val & 0xFF;
        file.write(reinterpret_cast<const char*>(&r), 1);
        file.write(reinterpret_cast<const char*>(&g), 1);
        file.write(reinterpret_cast<const char*>(&b), 1);
    }

    file.close();
    delete[] buffer;
    std::cout << "Saved " << output_file << std::endl;
    return 0;
}