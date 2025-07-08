/*
 * GEOFENCING GENÉRICO - SIN OPTIMIZACIONES
 * 
 * Esta versión representa el código típico sin conocimiento de
 * especificaciones de sensores. Debe funcionar para cualquier
 * coordenada GPS del mundo.
 */

#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

// ====================================================================
// TIPOS GENÉRICOS - SIN OPTIMIZACIONES DE RANGO
// ====================================================================

typedef double generic_latitude;
typedef double generic_longitude;
typedef double generic_altitude;
typedef double generic_speed;
typedef int generic_satellites;
typedef double generic_hdop;

typedef struct {
    generic_latitude lat;
    generic_longitude lon;
    generic_altitude alt;
    generic_speed speed;
    generic_satellites sats;
    generic_hdop hdop;
} GenericGPSPoint;

typedef struct {
    generic_latitude center_lat;
    generic_longitude center_lon;
    double radius_meters;
    char name[64];
} GenericGeofence;

// ====================================================================
// FUNCIONES GENÉRICAS - CON TODAS LAS VERIFICACIONES
// ====================================================================

/*
 * Verificamos si las corordenadas estan dentro de los rangos fisicamente posibles
 */
bool validateGPSCoordinates(generic_latitude lat, generic_longitude lon) {
    
    if (lat < -90.0 || lat > 90.0) {
        printf("Error: Latitud fuera del rango válido: %.6f\n", lat);
        return false;
    }
    //Recuerda que 0  grados en el meridiano de greenwich es el punto de referencia
    // y que la longitud se mide desde el meridiano de greenwich hacia el este
    // y hacia el oeste, por lo que el rango es de -180 a 180 grados
    if (lon < -180.0 || lon > 180.0) {
        printf("Error: Longitud fuera del rango válido: %.6f\n", lon);
        return false;
    }
    return true;
}

/*
 * Validar calidad de señal GPS
 */
bool validateGPSQuality(generic_satellites sats, generic_hdop hdop) {
    if (sats < 0 || sats > 50) {
        printf("Warning: Número de satélites sospechoso: %d\n", sats);
        return false;
    }
    if (hdop < 0.0 || hdop > 50.0) {
        printf("Warning: HDOP fuera del rango típico: %.2f\n", hdop);
        return false;
    }
    return true;
}

/*
 * Cálculo de distancia usando fórmula Haversine completa
 * Funciona para cualquier par de coordenadas en el mundo
 */
double generic_calculateDistance(generic_latitude lat1, generic_longitude lon1,
                                generic_latitude lat2, generic_longitude lon2) {
    // Verificaciones de seguridad completas
    if (!validateGPSCoordinates(lat1, lon1) || !validateGPSCoordinates(lat2, lon2)) {
        return -1.0; // Error
    }
    
    const double EARTH_RADIUS = 6371000.0; // metros
    
    // Conversión a radianes (operación costosa)
    double dlat = (lat2 - lat1) * M_PI / 180.0;
    double dlon = (lon2 - lon1) * M_PI / 180.0;
    double rlat1 = lat1 * M_PI / 180.0;
    double rlat2 = lat2 * M_PI / 180.0;
    
    // Fórmula Haversine completa (costosa pero precisa)
    double a = sin(dlat/2.0) * sin(dlat/2.0) + 
               cos(rlat1) * cos(rlat2) * sin(dlon/2.0) * sin(dlon/2.0);
    double c = 2.0 * atan2(sqrt(a), sqrt(1.0-a));
    
    double distance = EARTH_RADIUS * c;
    
    // Verificación de resultado
    if (distance < 0.0 || distance > 20037508.34) { // Circunferencia máxima de la Tierra
        printf("Warning: Distancia calculada sospechosa: %.2f metros\n", distance);
        return -1.0;
    }
    
    return distance;
}

/*
 * Verificar si un punto está dentro de una geocerca
 * Con todas las verificaciones de seguridad
 */
bool generic_isInsideGeofence(GenericGPSPoint* point, GenericGeofence* fence) {
    // Verificaciones de punteros NULL
    if (!point || !fence) {
        printf("Error: Puntero NULL en isInsideGeofence\n");
        return false;
    }
    
    // Verificar coordenadas del punto
    if (!validateGPSCoordinates(point->lat, point->lon)) {
        return false;
    }
    
    // Verificar coordenadas de la geocerca
    if (!validateGPSCoordinates(fence->center_lat, fence->center_lon)) {
        return false;
    }
    
    // Verificar radio válido
    if (fence->radius_meters <= 0.0 || fence->radius_meters > 20037508.34) {
        printf("Error: Radio de geocerca inválido: %.2f metros\n", fence->radius_meters);
        return false;
    }
    
    // Verificar calidad de GPS
    if (!validateGPSQuality(point->sats, point->hdop)) {
        printf("Warning: Señal GPS de baja calidad\n");
        // Continuar pero con precaución
    }
    
    // Calcular distancia
    double distance = generic_calculateDistance(point->lat, point->lon,
                                              fence->center_lat, fence->center_lon);
    
    if (distance < 0.0) {
        printf("Error: No se pudo calcular la distancia\n");
        return false;
    }
    
    return distance <= fence->radius_meters;
}

/*
 * Evaluar calidad de señal GPS genérica
 */
int generic_evaluateGPSQuality(generic_satellites sats, generic_hdop hdop) {
    // Verificaciones completas
    if (sats < 0 || hdop < 0.0) {
        return -1; // Error
    }
    
    // Evaluación conservadora para uso mundial
    if (sats >= 8 && hdop <= 1.0) {
        return 4; // Excelente
    } else if (sats >= 6 && hdop <= 2.0) {
        return 3; // Buena
    } else if (sats >= 4 && hdop <= 5.0) {
        return 2; // Aceptable
    } else if (sats >= 3 && hdop <= 10.0) {
        return 1; // Pobre pero usable
    } else {
        return 0; // Inutilizable
    }
}

/*
 * Detectar movimiento con verificaciones completas
 */
bool generic_isVehicleMoving(generic_speed speed) {
    // Verificar velocidad válida
    if (speed < 0.0) {
        printf("Error: Velocidad negativa: %.2f km/h\n", speed);
        return false;
    }
    
    if (speed > 1000.0) { // 1000 km/h es sospechoso para vehículos terrestres
        printf("Warning: Velocidad muy alta: %.2f km/h\n", speed);
    }
    
    const double MOVEMENT_THRESHOLD = 5.0; // km/h
    return speed > MOVEMENT_THRESHOLD;
}

/*
 * Función de procesamiento principal con manejo completo de errores
 */
int generic_processGeofencing(GenericGPSPoint* point, GenericGeofence* fences, int num_fences) {
    if (!point || !fences) {
        printf("Error: Punteros NULL en processGeofencing\n");
        return -1;
    }
    
    if (num_fences <= 0) {
        printf("Error: Número de geocercas inválido: %d\n", num_fences);
        return -1;
    }
    
    // Evaluar calidad GPS
    int quality = generic_evaluateGPSQuality(point->sats, point->hdop);
    if (quality < 2) {
        printf("Warning: Calidad GPS insuficiente (calidad: %d)\n", quality);
        return -2; // Señal GPS insuficiente
    }
    
    // Verificar si está en movimiento
    bool moving = generic_isVehicleMoving(point->speed);
    
    // Verificar cada geocerca
    for (int i = 0; i < num_fences; i++) {
        if (generic_isInsideGeofence(point, &fences[i])) {
            printf("Punto dentro de geocerca: %s\n", fences[i].name);
            if (moving) {
                return i + 100; // En geocerca + movimiento
            } else {
                return i; // En geocerca + estático
            }
        }
    }
    
    return -3; // Fuera de todas las geocercas
}

// ====================================================================
// FUNCIONES DE PRUEBA Y BENCHMARK
// ====================================================================

void generic_benchmark() {
    printf("🔄 BENCHMARK GENÉRICO - Sin optimizaciones\n");
    printf("==========================================\n");
    
    // Puntos de prueba globales (incluye extremos)
    GenericGPSPoint test_points[] = {
        {-16.4103216, -71.6070483, 2346.0, 15.0, 7, 1.5},  // Arequipa, Perú
        {40.4168000, -3.7038000, 650.0, 50.0, 8, 1.0},     // Madrid, España
        {0.0, 0.0, 0.0, 0.0, 4, 3.0},                       // Ecuador + GMT
        {-89.0, 179.0, 100.0, 5.0, 6, 2.0}                 // Extremo sur+este
    };
    
    GenericGeofence test_fence = {
        -16.357907, -71.568937, 1000.0, "Centro_Arequipa"
    };
    
    const int iterations = 100000;
    clock_t start = clock();
    
    // Benchmark de cálculo de distancias
    for (int i = 0; i < iterations; i++) {
        for (int j = 0; j < 4; j++) {
            generic_calculateDistance(test_points[j].lat, test_points[j].lon,
                                    test_fence.center_lat, test_fence.center_lon);
        }
    }
    
    clock_t end = clock();
    double total_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    
    printf("Tiempo total: %.4f segundos\n", total_time);
    printf("Operaciones por segundo: %.0f\n", (iterations * 4) / total_time);
    printf("Tiempo por operación: %.2f μs\n", (total_time * 1000000) / (iterations * 4));
    
    // Benchmark de geofencing completo
    start = clock();
    for (int i = 0; i < iterations / 10; i++) {
        for (int j = 0; j < 4; j++) {
            generic_processGeofencing(&test_points[j], &test_fence, 1);
        }
    }
    end = clock();
    total_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    
    printf("Geofencing completo: %.0f ops/seg\n", (iterations * 4 / 10) / total_time);
}

void generic_memory_usage() {
    printf("\n💾 USO DE MEMORIA GENÉRICO\n");
    printf("=========================\n");
    printf("Tamaño GenericGPSPoint: %zu bytes\n", sizeof(GenericGPSPoint));
    printf("Tamaño GenericGeofence: %zu bytes\n", sizeof(GenericGeofence));
    printf("Total por punto + geocerca: %zu bytes\n", 
           sizeof(GenericGPSPoint) + sizeof(GenericGeofence));
}

void generic_accuracy_test() {
    printf("\n🎯 PRUEBA DE PRECISIÓN GENÉRICA\n");
    printf("===============================\n");
    
    // Casos de prueba con distancias conocidas
    struct {
        double lat1, lon1, lat2, lon2;
        double expected_distance_km;
        const char* description;
    } test_cases[] = {
        {-16.4103216, -71.6070483, -16.3054933, -71.5308250, 12.1, "Arequipa local"},
        {40.4168000, -3.7038000, -16.3054933, -71.5308250, 8856.5, "Madrid-Arequipa"},
        {0.0, 0.0, 0.0, 1.0, 111.32, "1 grado longitud en ecuador"},
        {90.0, 0.0, -90.0, 0.0, 20015.09, "Polo a polo"}
    };
    
    for (int i = 0; i < 4; i++) {
        double calculated = generic_calculateDistance(
            test_cases[i].lat1, test_cases[i].lon1,
            test_cases[i].lat2, test_cases[i].lon2
        ) / 1000.0; // Convertir a km
        
        double error_percent = fabs(calculated - test_cases[i].expected_distance_km) 
                              / test_cases[i].expected_distance_km * 100.0;
        
        printf("%s: %.2f km (esperado: %.2f km, error: %.2f%%)\n",
               test_cases[i].description, calculated, 
               test_cases[i].expected_distance_km, error_percent);
    }
}

int main() {
    printf("🌍 GEOFENCING GENÉRICO - SIN OPTIMIZACIONES\n");
    generic_benchmark();
    generic_memory_usage();
    generic_accuracy_test();
    
    printf("\n📋 CARACTERÍSTICAS:\n");
    printf("- Verificaciones completas de rangos GPS\n");
    printf("- Manejo robusto de errores\n");
    printf("- Fórmula Haversine precisa para cualquier distancia\n");
    printf("- Tipos de datos genéricos (double para todo)\n");
    printf("- Funciona desde el Polo Norte hasta el Polo Sur\n");
    
    return 0;
}