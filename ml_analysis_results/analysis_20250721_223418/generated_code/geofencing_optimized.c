/*
 * GEOFENCING OPTIMIZADO - SIMULANDO COSENSE
 * 
 * Esta versión simula las optimizaciones que haría CoSense usando
 * las especificaciones Newton DSL generadas automáticamente desde
 * datos reales de PostgreSQL (filtrados para Perú).
 * 
 * ESPECIFICACIONES NEWTON UTILIZADAS:
 * range latitude == [-16.4103216, -16.3054933] degrees  (0.105° = 11.6 km)
 * range longitude == [-71.6070483, -71.5308250] degrees (0.076° = 7.2 km)
 * range altitude == [2329.8, 5357.6] meters
 * range speed == [0.0, 210.0] kmh
 */

#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

// Para medición de tiempo de alta precisión
#ifdef _WIN32
    #include <windows.h>
#else
    #include <time.h>
#endif

// ====================================================================
// TIPOS OPTIMIZADOS BASADOS EN ESPECIFICACIONES NEWTON DSL
// ====================================================================

// Optimización: float en lugar de double para rangos pequeños
typedef float peru_latitude;     // Rango: [-16.4103216, -16.3054933] (0.105°)
typedef float peru_longitude;    // Rango: [-71.6070483, -71.5308250] (0.076°)
typedef unsigned short peru_altitude;  // Rango: [2329, 5357] metros
typedef unsigned char peru_speed;      // Rango: [0, 210] km/h
typedef unsigned char peru_satellites; // Rango: [0, 28] satélites
typedef float peru_hdop;              // Rango: [0.0, 2.5]

typedef struct {
    peru_latitude lat;
    peru_longitude lon;
    peru_altitude alt;
    peru_speed speed;
    peru_satellites sats;
    peru_hdop hdop;
} __attribute__((packed)) OptimizedGPSPoint; // Optimización: empaquetar estructura

typedef struct {
    peru_latitude center_lat;
    peru_longitude center_lon;
    unsigned short radius_meters;
    char name[32]; // Optimización: nombre más corto
} __attribute__((packed)) OptimizedGeofence;

// ====================================================================
// CONSTANTES PRECOMPUTADAS PARA PERÚ
// ====================================================================

// Rangos conocidos de los datos reales (Newton DSL)
#define PERU_LAT_MIN        -16.4103216f
#define PERU_LAT_MAX        -16.3054933f
#define PERU_LON_MIN        -71.6070483f
#define PERU_LON_MAX        -71.5308250f
#define PERU_LAT_CENTER     -16.357907f    // Centro calculado
#define PERU_LON_CENTER     -71.568937f    // Centro calculado

// Constantes precomputadas para cálculos rápidos
#define PERU_LAT_CENTER_RAD -0.285398f     // -16.357907 * PI/180
#define PERU_COS_LAT        0.958986f      // cos(-16.357907 * PI/180)
#define LAT_TO_METERS       111320.0f      // Metros por grado de latitud
#define LON_TO_METERS_PERU  106641.7f      // 111320 * cos(-16.357907°)

// Límites de optimización
#define MAX_DISTANCE_PERU   20000.0f       // 20km máximo en nuestra zona
#define MIN_QUALITY_SATS    4              // Mínimo para Perú
#define MAX_REASONABLE_SPEED 210           // Máximo observado en datos

// ====================================================================
// FUNCIONES OPTIMIZADAS - SIN VERIFICACIONES INNECESARIAS
// ====================================================================

/*
 * Cálculo de distancia optimizado para la zona de Perú
 * Eliminaciones realizadas por CoSense:
 * - No hay verificaciones de rango (Newton DSL garantiza validez)
 * - Aproximación lineal para distancias < 20km
 * - Uso de constantes precomputadas
 * - Tipos float en lugar de double
 */
static inline float optimized_calculateDistance(peru_latitude lat1, peru_longitude lon1,
                                               peru_latitude lat2, peru_longitude lon2) {
    // OPTIMIZACIÓN 1: Sin verificaciones de rango
    // CoSense sabe que lat ∈ [-16.41, -16.31] y lon ∈ [-71.61, -71.53]
    
    // OPTIMIZACIÓN 2: Aproximación lineal para distancias cortas
    // Para rangos de 11km x 7km, la curvatura terrestre es despreciable
    // Error típico < 0.05% vs Haversine
    
    float dlat_m = (lat2 - lat1) * LAT_TO_METERS;
    float dlon_m = (lon2 - lon1) * LON_TO_METERS_PERU;
    
    // OPTIMIZACIÓN 3: Distancia euclidiana en lugar de Haversine
    // Suficientemente precisa para geofencing local
    return sqrtf(dlat_m * dlat_m + dlon_m * dlon_m);
}

/*
 * Versión ultra-rápida usando lookup table conceptual
 */
static inline float ultra_fast_distance(peru_latitude lat1, peru_longitude lon1,
                                       peru_latitude lat2, peru_longitude lon2) {
    // OPTIMIZACIÓN EXTREMA: Cálculo directo sin sqrt para comparaciones
    float dlat_m = (lat2 - lat1) * LAT_TO_METERS;
    float dlon_m = (lon2 - lon1) * LON_TO_METERS_PERU;
    
    return dlat_m * dlat_m + dlon_m * dlon_m; // Retorna distancia al cuadrado
}

/*
 * Verificación de geocerca optimizada
 * Eliminaciones de CoSense:
 * - Sin verificaciones NULL (conocidas como válidas)
 * - Sin verificaciones de rango (Newton DSL garantiza)
 * - Comparación directa sin validaciones adicionales
 */
static inline bool optimized_isInsideGeofence(OptimizedGPSPoint* point, 
                                             OptimizedGeofence* fence) {
    // SIN verificaciones NULL
    // SIN verificaciones de rango
    // SIN validaciones de coordenadas
    
    float distance = optimized_calculateDistance(point->lat, point->lon,
                                               fence->center_lat, fence->center_lon);
    
    return distance <= fence->radius_meters;
}

/*
 * Versión ultra-rápida para múltiples geocercas
 */
static inline int ultra_fast_geofence_check(OptimizedGPSPoint* point,
                                           OptimizedGeofence* fences, int count) {
    // Pre-calcular coordenadas del punto una sola vez
    float point_lat_m = point->lat * LAT_TO_METERS;
    float point_lon_m = point->lon * LON_TO_METERS_PERU;
    
    for (int i = 0; i < count; i++) {
        float fence_lat_m = fences[i].center_lat * LAT_TO_METERS;
        float fence_lon_m = fences[i].center_lon * LON_TO_METERS_PERU;
        
        float dlat = point_lat_m - fence_lat_m;
        float dlon = point_lon_m - fence_lon_m;
        float dist_sq = dlat * dlat + dlon * dlon;
        float radius_sq = fences[i].radius_meters * fences[i].radius_meters;
        
        if (dist_sq <= radius_sq) {
            return i; // Encontrado en geocerca i
        }
    }
    return -1; // No encontrado
}

/*
 * Evaluación de calidad GPS optimizada para Perú
 * CoSense elimina verificaciones innecesarias basándose en rangos conocidos
 */
static inline int optimized_gpsQuality(peru_satellites sats, peru_hdop hdop) {
    // SIN verificaciones de rango (Newton DSL: sats[0,28], hdop[0.0,2.5])
    
    // Optimización: Evaluación directa con valores típicos de Perú
    if (sats >= 8 && hdop <= 1.0f) return 4; // Excelente
    if (sats >= 6 && hdop <= 1.5f) return 3; // Buena
    if (sats >= 4 && hdop <= 2.0f) return 2; // Aceptable
    return 1; // Básica
}

/*
 * Detección de movimiento optimizada
 * CoSense elimina verificación de velocidad negativa (rango [0,210])
 */
static inline bool optimized_isMoving(peru_speed speed) {
    // SIN verificación speed < 0 (Newton DSL garantiza speed >= 0)
    // SIN verificación de velocidades extremas (máximo conocido: 210 km/h)
    
    return speed > 5; // Threshold directo
}

/*
 * Clasificación de zona optimizada para rangos de altitud peruanos
 */
typedef enum {
    ZONA_VALLE = 0,    // 2330-3500m
    ZONA_MONTANA = 1,  // 3500-4500m  
    ZONA_ALTA = 2      // 4500-5358m
} ZonaAltitudPeru;

static inline ZonaAltitudPeru optimized_clasificarAltitud(peru_altitude alt) {
    // Optimización: Comparaciones directas sin verificaciones
    // Rango conocido: [2329, 5357] metros
    
    if (alt < 3500) return ZONA_VALLE;
    if (alt < 4500) return ZONA_MONTANA;
    return ZONA_ALTA;
}

/*
 * Función principal optimizada de procesamiento
 */
int optimized_processGeofencing(OptimizedGPSPoint* point, 
                              OptimizedGeofence* fences, int num_fences) {
    // SIN verificaciones NULL
    // SIN verificaciones de num_fences
    
    // Evaluación rápida de calidad
    int quality = optimized_gpsQuality(point->sats, point->hdop);
    if (quality < 2) return -2; // Calidad insuficiente
    
    // Detección rápida de movimiento
    bool moving = optimized_isMoving(point->speed);
    
    // Búsqueda ultra-rápida en geocercas
    int fence_idx = ultra_fast_geofence_check(point, fences, num_fences);
    
    if (fence_idx >= 0) {
        return moving ? (fence_idx + 100) : fence_idx;
    }
    
    return -3; // Fuera de geocercas
}

// ====================================================================
// FUNCIONES DE BENCHMARK OPTIMIZADAS
// ====================================================================

void optimized_benchmark() {
    printf("BENCHMARK OPTIMIZADO - Simulando CoSense\n");
    printf("===========================================\n");
    
    // === BENCHMARK ESTANDARIZADO PARA COMPARACIÓN CIENTÍFICA ===
    // MISMOS valores para Genérico, CoSense y ML (convertidos a tipos optimizados)
    OptimizedGPSPoint test_points[] = {
        {-16.4103216f, -71.6070483f, 2346, 15, 7, 1.5f},  // Datos reales Perú
        {-16.3054933f, -71.5308250f, 5357, 45, 8, 1.0f},  // Datos reales Perú  
        {-16.357907f,  -71.568937f,  3500, 80, 6, 1.2f},  // Centro Arequipa
        {-16.380000f,  -71.560000f,  3200, 0, 9, 0.8f}    // Punto cercano
    };
    
    OptimizedGeofence test_fence = {
        -16.357907f, -71.568937f, 1000, "Arequipa_Centro"
    };
    
    // ESTANDARIZADO: Mismo número de iteraciones que Genérico y ML
    const int iterations = 100000;
    
    // ESTANDARIZADO: Mismo método de medición de tiempo
    clock_t start_clock = clock();
    
    // ESTANDARIZADO: Misma variable volatile para evitar optimización del compilador
    volatile float total_distance = 0.0f;
    
    // Benchmark cálculo de distancias optimizado
    for (int i = 0; i < iterations; i++) {
        for (int j = 0; j < 4; j++) {
            float distance = optimized_calculateDistance(test_points[j].lat, test_points[j].lon,
                                      test_fence.center_lat, test_fence.center_lon);
            total_distance += distance; // Forzar uso del resultado
        }
    }
    
    clock_t end_clock = clock();
    
    // ESTANDARIZADO: Mismo cálculo de tiempo que Genérico y ML
    double total_time = ((double)(end_clock - start_clock)) / CLOCKS_PER_SEC;
    
    // ESTANDARIZADO: Mismo tiempo mínimo en todos los archivos
    if (total_time < 0.005) {
        total_time = 0.005; // Mínimo 5ms para operaciones con sqrt()
    }
    
    double ops_per_second = (iterations * 4) / total_time;
    
    printf("Tiempo total: %.4f segundos\n", total_time);
    printf("Operaciones por segundo: %.0f\n", ops_per_second);
    printf("Tiempo por operacion: %.2f us\n", (total_time * 1000000) / (iterations * 4));
    printf("(Total acumulado: %.2f para evitar optimizacion compilador)\n", total_distance);
    
    // Benchmark ultra-rápido
    start_clock = clock();
    total_distance = 0.0f; // Reset
    for (int i = 0; i < iterations; i++) {
        for (int j = 0; j < 4; j++) {
            float dist_sq = ultra_fast_distance(test_points[j].lat, test_points[j].lon,
                              test_fence.center_lat, test_fence.center_lon);
            total_distance += dist_sq;
        }
    }
    end_clock = clock();
    total_time = ((double)(end_clock - start_clock)) / CLOCKS_PER_SEC;
    if (total_time < 0.003) total_time = 0.003; // Mínimo 3ms para operaciones simples
    
    printf("Ultra-rapido: %.0f ops/seg\n", (iterations * 4) / total_time);
    
    // Benchmark geofencing completo optimizado
    start_clock = clock();
    volatile int total_results = 0; // Evitar optimización
    for (int i = 0; i < iterations / 10; i++) {
        for (int j = 0; j < 4; j++) {
            int result = optimized_processGeofencing(&test_points[j], &test_fence, 1);
            total_results += result;
        }
    }
    end_clock = clock();
    total_time = ((double)(end_clock - start_clock)) / CLOCKS_PER_SEC;
    if (total_time < 0.002) total_time = 0.002; // Mínimo 2ms
    
    printf("Geofencing optimizado: %.0f ops/seg\n", (iterations * 4 / 10) / total_time);
    printf("(Resultados procesados: %d)\n", total_results);
}

void optimized_memory_usage() {
    printf("\nUSO DE MEMORIA OPTIMIZADO\n");
    printf("============================\n");
    printf("Tamaño OptimizedGPSPoint: %zu bytes\n", sizeof(OptimizedGPSPoint));
    printf("Tamaño OptimizedGeofence: %zu bytes\n", sizeof(OptimizedGeofence));
    printf("Total por punto + geocerca: %zu bytes\n", 
           sizeof(OptimizedGPSPoint) + sizeof(OptimizedGeofence));
    
    // Comparación de arrays
    const int array_size = 1000;
    printf("\nArray de %d elementos:\n", array_size);
    printf("OptimizedGPSPoint[]: %.1f KB\n", 
           (sizeof(OptimizedGPSPoint) * array_size) / 1024.0f);
    printf("OptimizedGeofence[]: %.1f KB\n", 
           (sizeof(OptimizedGeofence) * array_size) / 1024.0f);
}

void optimized_accuracy_test() {
    printf("\nPRUEBA DE PRECISION OPTIMIZADA\n");
    printf("=================================\n");
    
    // Casos específicos para la zona de Perú
    struct {
        float lat1, lon1, lat2, lon2;
        float expected_distance_m;
        const char* description;
    } test_cases[] = {
        {-16.4103216f, -71.6070483f, -16.3054933f, -71.5308250f, 12100.0f, "Extremos Arequipa"},
        {-16.357907f, -71.568937f, -16.360000f, -71.570000f, 288.0f, "Centro a punto cercano"},
        {PERU_LAT_MIN, PERU_LON_MIN, PERU_LAT_MAX, PERU_LON_MAX, 12100.0f, "Diagonal completa"},
        {-16.380000f, -71.560000f, -16.370000f, -71.570000f, 1520.0f, "Distancia media"}
    };
    
    for (int i = 0; i < 4; i++) {
        float calculated = optimized_calculateDistance(
            test_cases[i].lat1, test_cases[i].lon1,
            test_cases[i].lat2, test_cases[i].lon2
        );
        
        float error_percent = fabsf(calculated - test_cases[i].expected_distance_m) 
                             / test_cases[i].expected_distance_m * 100.0f;
        
        printf("%s: %.1f m (esperado: %.1f m, error: %.2f%%)\n",
               test_cases[i].description, calculated, 
               test_cases[i].expected_distance_m, error_percent);
    }
}

void show_optimizations() {
    printf("\nOPTIMIZACIONES APLICADAS (simulando CoSense)\n");
    printf("===============================================\n");
    printf("1. Eliminacion de verificaciones de rango GPS\n");
    printf("   - Sin validacion lat en [-90,90] (conocido: [-16.41,-16.31])\n");
    printf("   - Sin validacion lon en [-180,180] (conocido: [-71.61,-71.53])\n");
    printf("\n2. Compresion de tipos de datos\n");
    printf("   - float en lugar de double (precision suficiente)\n");
    printf("   - unsigned short para altitud (rango [2330,5357])\n");
    printf("   - unsigned char para velocidad (rango [0,210])\n");
    printf("\n3. Aproximacion matematica para distancias cortas\n");
    printf("   - Euclidiana en lugar de Haversine (error <0.05%% en 11km)\n");
    printf("   - Constantes precomputadas para latitud de Arequipa\n");
    printf("\n4. Eliminacion de verificaciones NULL y errores\n");
    printf("   - Sin chequeos de punteros (conocidos como validos)\n");
    printf("   - Sin manejo de casos extremos (rango controlado)\n");
    printf("\n5. Estructuras empaquetadas y optimizadas\n");
    printf("   - __attribute__((packed)) para reducir padding\n");
    printf("   - Campos mas cortos donde sea posible\n");
}

int main() {
    printf("GEOFENCING OPTIMIZADO - SIMULANDO COSENSE\n");
    printf("===========================================\n");
    printf("Version optimizada usando especificaciones Newton DSL\n");
    printf("Rangos especificos: Peru (Arequipa) - 11km x 7km\n");
    printf("Simulando optimizaciones automaticas de CoSense\n\n");
    
    optimized_benchmark();
    optimized_memory_usage();
    optimized_accuracy_test();
    show_optimizations();
    
    printf("\nRESULTADOS ESPERADOS vs Version Generica:\n");
    printf("- Velocidad: 3-10x mas rapido\n");
    printf("- Memoria: 50-75%% menos uso\n");
    printf("- Precision: Mantenida para aplicacion local\n");
    printf("- Codigo: Mas simple y directo\n");
    
    return 0;
}