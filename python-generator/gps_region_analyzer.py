#!/usr/bin/env python3
"""
Analizador de Datos GPS por Región
Investiga qué datos GPS tienes y filtra por regiones específicas
"""

import psycopg2
import pandas as pd
from typing import Dict, List, Tuple
import matplotlib.pyplot as plt

class GPSRegionAnalyzer:
    def __init__(self, db_config: Dict[str, str]):
        self.db_config = db_config
        self.connection = None
        
    def connect_database(self) -> bool:
        try:
            self.connection = psycopg2.connect(
                host=self.db_config['host'],
                port=self.db_config['port'],
                database=self.db_config['database'],
                user=self.db_config['user'],
                password=self.db_config['password']
            )
            print(f"✅ Conectado a la base de datos '{self.db_config['database']}'")
            return True
        except Exception as e:
            print(f"❌ Error conectando: {e}")
            return False
    
    def get_gps_tables(self) -> List[str]:
        """Encuentra todas las tablas con datos GPS"""
        try:
            cursor = self.connection.cursor()
            cursor.execute("""
                SELECT DISTINCT table_name 
                FROM information_schema.columns 
                WHERE column_name IN ('latitude', 'longitude')
                AND table_schema = 'public'
                ORDER BY table_name;
            """)
            tables = [row[0] for row in cursor.fetchall()]
            print(f"📋 Tablas con datos GPS: {tables}")
            return tables
        except Exception as e:
            print(f"❌ Error: {e}")
            return []
    
    def analyze_geographic_distribution(self, table_name: str):
        """Analiza la distribución geográfica de los datos"""
        try:
            cursor = self.connection.cursor()
            
            # Obtener estadísticas por región
            query = f"""
            SELECT 
                COUNT(*) as total_points,
                MIN(latitude) as lat_min,
                MAX(latitude) as lat_max,
                MIN(longitude) as lon_min,
                MAX(longitude) as lon_max,
                AVG(latitude) as lat_avg,
                AVG(longitude) as lon_avg,
                STDDEV(latitude) as lat_stddev,
                STDDEV(longitude) as lon_stddev
            FROM {table_name}
            WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
            """
            
            cursor.execute(query)
            stats = cursor.fetchone()
            
            print(f"\n🌍 ANÁLISIS GEOGRÁFICO - Tabla: {table_name}")
            print("="*50)
            print(f"Total de puntos GPS: {stats[0]}")
            print(f"Latitud: {stats[1]:.6f}° a {stats[2]:.6f}°")
            print(f"Longitud: {stats[3]:.6f}° a {stats[4]:.6f}°")
            print(f"Centro promedio: ({stats[5]:.6f}°, {stats[6]:.6f}°)")
            
            # Identificar regiones
            self.identify_regions(stats[1], stats[2], stats[3], stats[4])
            
            # Obtener muestra de datos para análisis
            return self.get_sample_data(table_name)
            
        except Exception as e:
            print(f"❌ Error analizando: {e}")
            return None
    
    def identify_regions(self, lat_min, lat_max, lon_min, lon_max):
        """Identifica qué regiones/países están incluidos en los datos"""
        regions = []
        
        # Perú: aproximadamente lat [-18, -0], lon [-81, -68]
        if lat_min >= -18 and lat_max <= 0 and lon_min >= -81 and lon_max <= -68:
            regions.append("🇵🇪 SOLO PERÚ")
        elif lat_min >= -17 and lat_max <= -15 and lon_min >= -72 and lon_max <= -70:
            regions.append("🏔️ AREQUIPA, PERÚ")
        else:
            # Verificar múltiples países
            if lat_min <= -10 and lon_min <= -70:
                regions.append("🇵🇪 Perú (parcial)")
            if lat_max >= 35 and lon_max >= -10:
                regions.append("🇪🇸 España (parcial)")
            if lat_max >= 20 and lat_min <= 50 and lon_min <= 10:
                regions.append("🌍 Europa (parcial)")
        
        if not regions:
            regions.append("🗺️ Región no identificada")
        
        print(f"📍 Regiones detectadas: {', '.join(regions)}")
        
        # Alertas específicas
        if lat_max > 35:
            print("⚠️  ALERTA: Datos incluyen Europa (latitud > 35°)")
        if lon_max > -10:
            print("⚠️  ALERTA: Datos incluyen Europa/África (longitud > -10°)")
        if lat_min < -20:
            print("⚠️  ALERTA: Datos van más al sur de Perú (latitud < -20°)")
    
    def get_sample_data(self, table_name: str, limit: int = 10):
        """Obtiene muestra de datos para inspección"""
        try:
            cursor = self.connection.cursor()
            query = f"""
            SELECT latitude, longitude, altitude, speed, timestamp
            FROM {table_name}
            WHERE latitude IS NOT NULL AND longitude IS NOT NULL
            ORDER BY ABS(latitude) DESC, ABS(longitude) DESC
            LIMIT {limit};
            """
            
            cursor.execute(query)
            samples = cursor.fetchall()
            
            print(f"\n📊 MUESTRA DE DATOS EXTREMOS:")
            print("-" * 60)
            for i, row in enumerate(samples, 1):
                lat, lon, alt, speed, timestamp = row
                region = self.classify_coordinate(lat, lon)
                print(f"{i:2d}. ({lat:8.5f}°, {lon:8.5f}°) {region} - {timestamp}")
            
            return samples
            
        except Exception as e:
            print(f"❌ Error obteniendo muestra: {e}")
            return []
    
    def classify_coordinate(self, lat: float, lon: float) -> str:
        """Clasifica una coordenada por región"""
        if -18 <= lat <= -10 and -82 <= lon <= -68:
            return "🇵🇪 Perú"
        elif -17 <= lat <= -15 and -72 <= lon <= -70:
            return "🏔️ Arequipa"
        elif 35 <= lat <= 45 and -10 <= lon <= 5:
            return "🇪🇸 España"
        elif lat > 20 and lon > -20:
            return "🌍 Europa/África"
        elif lat < -20:
            return "🌊 Sur de Perú/Chile"
        else:
            return "❓ Desconocido"
    
    def filter_peru_data(self, table_name: str) -> Dict:
        """Filtra solo datos de Perú y regenera estadísticas"""
        try:
            cursor = self.connection.cursor()
            
            # Filtrar solo datos de Perú (aproximadamente)
            query = f"""
            SELECT 
                COUNT(*) as total_records,
                MIN(latitude) as lat_min,
                MAX(latitude) as lat_max,
                AVG(latitude) as lat_avg,
                STDDEV(latitude) as lat_stddev,
                MIN(longitude) as lon_min,
                MAX(longitude) as lon_max,
                AVG(longitude) as lon_avg,
                STDDEV(longitude) as lon_stddev,
                MIN(altitude) as alt_min,
                MAX(altitude) as alt_max,
                AVG(altitude) as alt_avg,
                MIN(speed) as speed_min,
                MAX(speed) as speed_max,
                AVG(speed) as speed_avg,
                MIN(satellites) as sat_min,
                MAX(satellites) as sat_max,
                AVG(satellites) as sat_avg,
                MIN(hdop) as hdop_min,
                MAX(hdop) as hdop_max,
                AVG(hdop) as hdop_avg
            FROM {table_name}
            WHERE latitude BETWEEN -18 AND 0 
            AND longitude BETWEEN -82 AND -68
            AND latitude IS NOT NULL 
            AND longitude IS NOT NULL;
            """
            
            cursor.execute(query)
            row = cursor.fetchone()
            
            if row[0] == 0:
                print("❌ No se encontraron datos en el rango de Perú")
                return {}
            
            stats = {
                'total_records': row[0],
                'latitude': {
                    'min': float(row[1]) if row[1] else 0,
                    'max': float(row[2]) if row[2] else 0,
                    'avg': float(row[3]) if row[3] else 0,
                    'stddev': float(row[4]) if row[4] else 0
                },
                'longitude': {
                    'min': float(row[5]) if row[5] else 0,
                    'max': float(row[6]) if row[6] else 0,
                    'avg': float(row[7]) if row[7] else 0,
                    'stddev': float(row[8]) if row[8] else 0
                },
                'altitude': {
                    'min': float(row[9]) if row[9] else 0,
                    'max': float(row[10]) if row[10] else 0,
                    'avg': float(row[11]) if row[11] else 0
                },
                'speed': {
                    'min': float(row[12]) if row[12] else 0,
                    'max': float(row[13]) if row[13] else 0,
                    'avg': float(row[14]) if row[14] else 0
                },
                'satellites': {
                    'min': int(row[15]) if row[15] else 0,
                    'max': int(row[16]) if row[16] else 0,
                    'avg': float(row[17]) if row[17] else 0
                },
                'hdop': {
                    'min': float(row[18]) if row[18] else 0,
                    'max': float(row[19]) if row[19] else 0,
                    'avg': float(row[20]) if row[20] else 0
                }
            }
            
            # Calcular precisión para Perú
            stats['precision'] = {
                'latitude_meters': stats['latitude']['stddev'] * 111000,
                'longitude_meters': stats['longitude']['stddev'] * 111000 * abs(stats['latitude']['avg'] * 0.017453),
                'suggested_decimal_places': max(4, int(-stats['latitude']['stddev'] * 100000) + 1)
            }
            
            print(f"\n🇵🇪 DATOS FILTRADOS PARA PERÚ:")
            print("="*40)
            print(f"Registros en Perú: {stats['total_records']}")
            print(f"Latitud: {stats['latitude']['min']:.6f}° a {stats['latitude']['max']:.6f}°")
            print(f"Longitud: {stats['longitude']['min']:.6f}° a {stats['longitude']['max']:.6f}°")
            print(f"Altitud: {stats['altitude']['min']:.1f}m a {stats['altitude']['max']:.1f}m")
            print(f"Velocidad: {stats['speed']['min']:.1f} a {stats['speed']['max']:.1f} km/h")
            
            return stats
            
        except Exception as e:
            print(f"❌ Error filtrando datos de Perú: {e}")
            return {}
    
    def run_analysis(self):
        """Ejecuta análisis completo"""
        print("🔍 INICIANDO ANÁLISIS DE REGIONES GPS")
        print("="*50)
        
        if not self.connect_database():
            return False
        
        # Encontrar tablas GPS
        tables = self.get_gps_tables()
        if not tables:
            print("❌ No se encontraron tablas con datos GPS")
            return False
        
        # Analizar cada tabla
        for table in tables:
            print(f"\n📋 Analizando tabla: {table}")
            self.analyze_geographic_distribution(table)
            
            # Filtrar datos de Perú
            peru_stats = self.filter_peru_data(table)
            
            if peru_stats:
                # Generar Newton DSL filtrado
                self.generate_peru_newton(peru_stats, table)
        
        if self.connection:
            self.connection.close()
        
        return True
    
    def generate_peru_newton(self, stats: Dict, table_name: str):
        """Genera Newton DSL solo con datos de Perú"""
        from datetime import datetime
        
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        newton_content = f"""// Especificaciones Newton DSL - SOLO PERÚ
// Generado: {timestamp}
// Registros analizados: {stats['total_records']} (filtrados de Perú)
// Tabla: {table_name}

// Sensor GPS de Perú basado en datos reales filtrados
peruGPS: sensor (
    latitude: gps_latitude,
    longitude: gps_longitude,
    altitude: gps_altitude,
    speed: gps_speed,
    satellites: gps_satellites,
    hdop: gps_hdop
) = {{
    // Rangos geográficos de Perú únicamente
    range latitude == [{stats['latitude']['min']:.7f} degrees, {stats['latitude']['max']:.7f} degrees],
    range longitude == [{stats['longitude']['min']:.7f} degrees, {stats['longitude']['max']:.7f} degrees],
    range altitude == [{stats['altitude']['min']:.1f} meters, {stats['altitude']['max']:.1f} meters],
    
    // Rangos de movimiento en Perú
    range speed == [{stats['speed']['min']:.1f} kmh, {stats['speed']['max']:.1f} kmh],
    
    // Calidad de señal GPS en Perú
    range satellites == [{stats['satellites']['min']}, {stats['satellites']['max']}],
    range hdop == [{stats['hdop']['min']:.1f}, {stats['hdop']['max']:.1f}],
    
    // Precisión específica para Perú
    precision latitude == {stats['precision']['suggested_decimal_places']} decimal_places,
    precision longitude == {stats['precision']['suggested_decimal_places']} decimal_places,
    precision altitude == 1.0 meters,
    
    // Metadatos para Perú
    // Centro promedio: ({stats['latitude']['avg']:.6f}°, {stats['longitude']['avg']:.6f}°)
    // Precisión estimada: ~{stats['precision']['latitude_meters']:.1f}m
    // Zona geográfica: Perú únicamente
}};

// Tipos optimizados para GPS de Perú
// typedef double gps_latitude;    // Rango Perú: [{stats['latitude']['min']:.6f}, {stats['latitude']['max']:.6f}]
// typedef double gps_longitude;   // Rango Perú: [{stats['longitude']['min']:.6f}, {stats['longitude']['max']:.6f}]
// typedef double gps_altitude;    // Rango Perú: [{stats['altitude']['min']:.1f}, {stats['altitude']['max']:.1f}]
// typedef double gps_speed;       // Rango Perú: [{stats['speed']['min']:.1f}, {stats['speed']['max']:.1f}]
"""
        
        # Guardar archivo filtrado
        filename = f"peru-gps-specs.newton"
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(newton_content)
            print(f"✅ Archivo Newton para Perú guardado: {filename}")
        except Exception as e:
            print(f"❌ Error guardando archivo: {e}")

def main():
    # Configuración de base de datos
    db_config = {
        'host': '35.153.253.112',
        'port': '5432',
        'database': 'santiago',
        'user': 'postgres',
        'password': 'blf278'
    }
    
    analyzer = GPSRegionAnalyzer(db_config)
    analyzer.run_analysis()

if __name__ == "__main__":
    main()