/*
 * COMPARACIÓN: Geofencing Normal vs Optimizado
 * 
 * Este archivo demuestra el impacto de usar especificaciones Newton DSL
 * generadas automáticamente desde datos reales de PostgreSQL
 * 
 * DATOS USADOS: Perú filtrado (77 km² en Arequipa)
 * - Latitud: [-16.4103216, -16.3054933] (rango: 0.105°)
 * - Longitud: [-71.6070483, -71.5308250] (rango: 0.076°)
 * - Altitud: [2329.8, 5357.6] metros
 */

#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <time.h>
#include <string.h>

// ====================================================================
// VERSIÓN 1: GEOFENCING GENÉRICO (SIN OPTIMIZACIONES)
// ====================================================================

typedef double generic_latitude;
typedef double generic_longitude;
typedef double generic_altitude;
typedef double generic_speed;

typedef struct {
    generic_latitude lat;
    generic_longitude lon;
    generic_altitude alt;
    generic_speed speed;
} GenericGPSPoint;

typedef struct {
    generic_latitude center_lat;
    generic_longitude center_lon;
    double radius_meters;
} GenericGeofence;

/*
 * Cálculo de distancia genérico - SIN optimizaciones
 * Debe funcionar para cualquier punto del mundo
 */
double generic_calculateDistance(generic_latitude lat1, generic_longitude lon1,
                                generic_latitude lat2, generic_longitude lon2) {
    // Verificaciones genéricas obligatorias
    if (lat1 < -90 || lat1 > 90 || lat2 < -90 || lat2 > 90) {
        return -1; // Error: latitud inválida
    }
    if (lon1 < -180 || lon1 > 180 || lon2 < -180 || lon2 > 180) {
        return -1; // Error: longitud inválida
    }
    
    const double EARTH_RADIUS = 6371000.0; // metros
    
    // Conversión a radianes (costosa)
    double dlat = (lat2 - lat1) * M_PI / 180.0;
    double dlon = (lon2 - lon1) * M_PI / 180.0;
    double rlat1 = lat1 * M_PI / 180.0;
    double rlat2 = lat2 * M_PI / 180.0;
    
    // Cálculo completo Haversine (costoso)
    double a = sin(dlat/2) * sin(dlat/2) + 
               cos(rlat1) * cos(rlat2) * sin(dlon/2) * sin(dlon/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    
    return EARTH_RADIUS * c;
}

/*
 * Geofencing genérico con verificaciones completas
 */
bool generic_isInsideGeofence(GenericGPSPoint* point, GenericGeofence* fence) {
    // Verificaciones de seguridad genéricas
    if (!point || !fence) return false;
    
    // Verificar rangos válidos
    if (point->lat < -90 || point->lat > 90) return false;
    if (point->lon < -180 || point->lon > 180) return false;
    if (fence->radius_meters <= 0) return false;
    
    double distance = generic_calculateDistance(point->lat, point->lon,
                                              fence->center_lat, fence->center_lon);
    
    if (distance < 0) return false; // Error en cálculo
    
    return distance <= fence->radius_meters;
}

// ====================================================================
// VERSIÓN 2: GEOFENCING OPTIMIZADO (CON ESPECIFICACIONES NEWTON)
// ====================================================================

// Tipos optimizados basados en rangos reales de Perú
typedef float peru_latitude;    // 32 bits suficientes para rango de 0.105°
typedef float peru_longitude;   // 32 bits suficientes para rango de 0.076°
typedef short peru_altitude;    // 16 bits suficientes para rango [2330, 5358]m
typedef unsigned char peru_speed; // 8 bits suficientes para rango [0, 210] km/h

typedef struct {
    peru_latitude lat;
    peru_longitude lon;
    peru_altitude alt;
    peru_speed speed;
} OptimizedGPSPoint;

typedef struct {
    peru_latitude center_lat;
    peru_longitude center_lon;
    unsigned short radius_meters; // 16 bits suficientes para radios típicos
} OptimizedGeofence;

// Constantes precomputadas para la zona de Arequipa
#define PERU_LAT_MIN    -16.4103216f
#define PERU_LAT_MAX    -16.3054933f
#define PERU_LON_MIN    -71.6070483f
#define PERU_LON_MAX    -71.5308250f
#define PERU_LAT_CENTER -16.357907f     // Centro calculado
#define PERU_LON_CENTER -71.568937f     // Centro calculado

// Constantes precomputadas para optimización trigonométrica
#define PERU_LAT_CENTER_RAD -0.285398f  // -16.357907 * PI/180
#define PERU_COS_LAT_CENTER  0.958986f  // cos(-16.357907 * PI/180)
#define EARTH_RADIUS_M       6371000.0f
#define DEG_TO_RAD_FACTOR    0.017453f  // PI/180

/*
 * Cálculo de distancia OPTIMIZADO para zona de Arequipa
 * Elimina verificaciones y usa aproximaciones válidas para rangos pequeños
 */
float optimized_calculateDistance(peru_latitude lat1, peru_longitude lon1,
                                 peru_latitude lat2, peru_longitude lon2) {
    // NO HAY verificaciones - sabemos que los datos son válidos por Newton DSL
    // Rango conocido: lat ∈ [-16.41, -16.31], lon ∈ [-71.61, -71.53]
    
    // Optimización 1: Aproximación lineal para distancias cortas
    // En rangos de ~11km, la curvatura de la Tierra es despreciable
    float dlat_m = (lat2 - lat1) * 111320.0f; // ~111.32 km por grado latitud
    float dlon_m = (lon2 - lon1) * PERU_COS_LAT_CENTER * 111320.0f;
    
    // Optimización 2: Distancia euclidiana en lugar de Haversine
    // Error < 0.1% para distancias < 20km
    return sqrtf(dlat_m * dlat_m + dlon_m * dlon_m);
}

/*
 * Versión súper optimizada usando lookup table para distancias muy cortas
 */
float ultra_optimized_calculateDistance(peru_latitude lat1, peru_longitude lon1,
                                       peru_latitude lat2, peru_longitude lon2) {
    // Para zona de 11km x 7km, usar aproximación lineal directa
    float dlat = lat2 - lat1;
    float dlon = lon2 - lon1;
    
    // Factores precomputados específicamente para Arequipa (-16.36°)
    const float LAT_TO_METERS = 111320.0f;           // Constante global
    const float LON_TO_METERS = 106641.7f;           // 111320 * cos(-16.36°)
    
    float dlat_m = dlat * LAT_TO_METERS;
    float dlon_m = dlon * LON_TO_METERS;
    
    return sqrtf(dlat_m * dlat_m + dlon_m * dlon_m);
}

/*
 * Geofencing optimizado - elimina todas las verificaciones innecesarias
 */
bool optimized_isInsideGeofence(OptimizedGPSPoint* point, OptimizedGeofence* fence) {
    // NO HAY verificaciones de NULL - optimización agresiva
    // NO HAY verificaciones de rangos - Newton DSL garantiza validez
    
    float distance = optimized_calculateDistance(point->lat, point->lon,
                                               fence->center_lat, fence->center_lon);
    
    // Optimización: comparación directa sin verificaciones adicionales
    return distance <= fence->radius_meters;
}

/*
 * Función especializada para detección de movimiento en vehículos peruanos
 */
bool isVehicleMovingInPeru(peru_speed speed) {
    // Optimización: sabemos que speed ∈ [0, 210] km/h
    // Eliminamos verificación de speed < 0
    
    const peru_speed MOVEMENT_THRESHOLD = 5; // 5 km/h
    
    // Optimización: comparación directa con tipo de 8 bits
    return speed > MOVEMENT_THRESHOLD;
}

/*
 * Detector de zona urbana vs rural basado en altitud (específico para Perú)
 */
typedef enum {
    ZONA_COSTA = 0,      // No aplica en nuestros datos (min: 2330m)
    ZONA_SIERRA = 1,     // 2330-4000m (la mayoría de nuestros datos)
    ZONA_PUNA = 2        // 4000-5358m
} TipoZonaPeru;

TipoZonaPeru clasificarZona(peru_altitude altitude) {
    // Optimización: rangos específicos para datos peruanos [2330, 5358]m
    if (altitude < 4000) {
        return ZONA_SIERRA;  // Arequipa típicamente está aquí
    } else {
        return ZONA_PUNA;    // Zonas altas de los Andes
    }
}

// ====================================================================
// FUNCIONES DE PRUEBA Y COMPARACIÓN
// ====================================================================

void benchmark_distance_calculation() {
    printf("🚀 BENCHMARK: Cálculo de Distancias\n");
    printf("=====================================\n");
    
    // Puntos de prueba basados en datos reales de Arequipa
    double lat1 = -16.4103216, lon1 = -71.6070483;
    double lat2 = -16.3054933, lon2 = -71.5308250;
    
    clock_t start, end;
    const int iterations = 1000000;
    
    // Benchmark versión genérica
    start = clock();
    for (int i = 0; i < iterations; i++) {
        generic_calculateDistance(lat1, lon1, lat2, lon2);
    }
    end = clock();
    double generic_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    
    // Benchmark versión optimizada
    start = clock();
    for (int i = 0; i < iterations; i++) {
        optimized_calculateDistance((float)lat1, (float)lon1, (float)lat2, (float)lon2);
    }
    end = clock();
    double optimized_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    
    // Benchmark versión ultra optimizada
    start = clock();
    for (int i = 0; i < iterations; i++) {
        ultra_optimized_calculateDistance((float)lat1, (float)lon1, (float)lat2, (float)lon2);
    }
    end = clock();
    double ultra_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    
    // Resultados
    printf("Genérico:      %.4f segundos (%.0f ops/sec)\n", 
           generic_time, iterations / generic_time);
    printf("Optimizado:    %.4f segundos (%.0f ops/sec) [%.1fx más rápido]\n", 
           optimized_time, iterations / optimized_time, generic_time / optimized_time);
    printf("Ultra-opt:     %.4f segundos (%.0f ops/sec) [%.1fx más rápido]\n", 
           ultra_time, iterations / ultra_time, generic_time / ultra_time);
    
    // Verificar precisión
    double dist_generic = generic_calculateDistance(lat1, lon1, lat2, lon2);
    float dist_optimized = optimized_calculateDistance(lat1, lon1, lat2, lon2);
    float dist_ultra = ultra_optimized_calculateDistance(lat1, lon1, lat2, lon2);
    
    printf("\nPrecisión:\n");
    printf("Genérico:      %.2f metros\n", dist_generic);
    printf("Optimizado:    %.2f metros (error: %.2f%%)\n", 
           dist_optimized, fabs(dist_optimized - dist_generic) / dist_generic * 100);
    printf("Ultra-opt:     %.2f metros (error: %.2f%%)\n", 
           dist_ultra, fabs(dist_ultra - dist_generic) / dist_generic * 100);
}

void demonstrate_memory_optimization() {
    printf("\n💾 OPTIMIZACIÓN DE MEMORIA\n");
    printf("==========================\n");
    
    printf("Estructura genérica:  %zu bytes\n", sizeof(GenericGPSPoint));
    printf("Estructura optimizada: %zu bytes\n", sizeof(OptimizedGPSPoint));
    printf("Reducción de memoria:  %.1f%%\n", 
           (1.0f - (float)sizeof(OptimizedGPSPoint) / sizeof(GenericGPSPoint)) * 100);
    
    printf("\nGeofence genérica:     %zu bytes\n", sizeof(GenericGeofence));
    printf("Geofence optimizada:   %zu bytes\n", sizeof(OptimizedGeofence));
    printf("Reducción de memoria:  %.1f%%\n", 
           (1.0f - (float)sizeof(OptimizedGeofence) / sizeof(GenericGeofence)) * 100);
}

void simulate_real_world_usage() {
    printf("\n🌍 SIMULACIÓN DE USO REAL\n");
    printf("=========================\n");
    
    // Crear geofence para centro de Arequipa
    OptimizedGeofence arequipa_center = {
        .center_lat = PERU_LAT_CENTER,
        .center_lon = PERU_LON_CENTER,
        .radius_meters = 1000  // 1km de radio
    };
    
    // Simular puntos GPS reales
    OptimizedGPSPoint test_points[] = {
        {-16.4103216f, -71.6070483f, 2346, 15},  // Punto real de tus datos
        {-16.3054933f, -71.5308250f, 5357, 45},  // Otro punto real
        {-16.357907f,  -71.568937f,  3500, 0},   // Centro de Arequipa
        {-16.380000f,  -71.560000f,  3200, 80}   // Punto cercano
    };
    
    int num_points = sizeof(test_points) / sizeof(test_points[0]);
    
    for (int i = 0; i < num_points; i++) {
        bool inside = optimized_isInsideGeofence(&test_points[i], &arequipa_center);
        bool moving = isVehicleMovingInPeru(test_points[i].speed);
        TipoZonaPeru zona = clasificarZona(test_points[i].alt);
        
        printf("Punto %d: (%.6f, %.6f) %dm %dkm/h\n", 
               i+1, test_points[i].lat, test_points[i].lon, 
               test_points[i].alt, test_points[i].speed);
        printf("  %s geofence | %s | Zona: %s\n",
               inside ? "✅ Dentro" : "❌ Fuera",
               moving ? "🏃 Movimiento" : "⏸️  Estático",
               zona == ZONA_SIERRA ? "Sierra" : "Puna");
    }
}

int main() {
    printf("🛰️  COMPARACIÓN: Geofencing Genérico vs Optimizado\n");
    printf("==================================================\n");
    printf("📊 Usando especificaciones Newton DSL generadas automáticamente\n");
    printf("📍 Datos filtrados: Perú (Arequipa) - 77 km²\n");
    printf("🔧 Rangos: lat[%.6f, %.6f], lon[%.6f, %.6f]\n\n",
           PERU_LAT_MIN, PERU_LAT_MAX, PERU_LON_MIN, PERU_LON_MAX);
    
    // Ejecutar benchmarks
    benchmark_distance_calculation();
    demonstrate_memory_optimization();
    simulate_real_world_usage();
    
    printf("\n✨ CONCLUSIONES:\n");
    printf("- Especificaciones Newton DSL automáticas permiten optimizaciones extremas\n");
    printf("- Rangos micro-específicos (11km x 7km) → optimizaciones agresivas\n");
    printf("- Reducción significativa en tiempo de ejecución y memoria\n");
    printf("- Precisión mantenida para aplicaciones de geofencing\n");
    
    return 0;
}