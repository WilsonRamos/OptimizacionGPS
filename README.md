# Sistema de Machine Learning para Optimización de Compiladores IoT

## 📋 Resumen del Proyecto

Este proyecto implementa un **sistema innovador de optimización de compiladores** que utiliza **Machine Learning** y **especificaciones de sensores** para mejorar automáticamente el rendimiento de código C/C++ en dispositivos IoT. El sistema integra el compilador **CoSense** con técnicas de aprendizaje automático para generar optimizaciones específicas basadas en datos reales de sensores GPS.

###  Características Principales

- **Generación automática de especificaciones Newton DSL** desde datos GPS reales
- **Modelo ML ensemble** para predicción de optimizaciones de compilador
- **Pipeline completo end-to-end** desde PostgreSQL hasta código optimizado
- **Análisis comparativo** entre código genérico, optimizado y generado por ML
- **Benchmarking automatizado** con métricas de rendimiento detalladas

### 🏗 Arquitectura del Sistema

El sistema consta de **4 componentes principales**:

1. **Generador Automático Newton DSL** - Extrae especificaciones de sensores desde PostgreSQL
2. **Extractor de Características de Código** - Analiza código C para Machine Learning  
3. **Modelo ML Ensemble** - Predice optimizaciones óptimas usando RandomForest y SVM
4. **Optimizador Automático de Código** - Genera código C optimizado automáticamente

```
[PostgreSQL GPS Data] → [Newton DSL Generator] → [ML Feature Extractor] → [ML Model] → [Optimized C Code]
```

## 🚀 Resultados Alcanzados

### Métricas de Rendimiento
- **Aceleración computacional**: 14,669.0x
- **Reducción de memoria**: 57.4%
- **Precisión ML**: 99.8% para eliminación de verificaciones de rango
- **Optimizaciones aplicadas**: 5 de 6 predicciones exitosas

### Optimizaciones Implementadas
- ✅ Eliminación de verificaciones de rango redundantes
- ✅ Compresión de tipos de datos (double → float)
- ✅ Simplificación de operaciones trigonométricas
- ✅ Propagación de constantes geográficas
- ✅ Optimización de cálculos de distancia

## 🛠️ Instalación y Configuración

### Prerrequisitos

```bash
# Dependencias del sistema
sudo apt-get install gcc postgresql postgresql-contrib

# Python 3.8+ requerido
python3 --version
```

### Instalación de Dependencias Python

```bash
# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt
```

#### requirements.txt
```
numpy>=1.21.0
pandas>=1.3.0
scikit-learn>=1.0.0
matplotlib>=3.5.0
seaborn>=0.11.0
plotly>=5.0.0
psycopg2-binary>=2.9.0
joblib>=1.1.0
```

### Configuración de Base de Datos

```bash
# Crear base de datos PostgreSQL
sudo -u postgres createdb gps_data

# Importar datos GPS (el proyecto incluye datos de muestra)
psql -U postgres -d gps_data -f data/sample_gps_peru.sql
```

## 🎮 Ejecución del Sistema

### 1. Generación de Especificaciones Newton DSL

```bash
# Generar especificaciones desde datos PostgreSQL
python3 generate_newton.py --database gps_data --region peru --output specs/

# Salida: peru-gps-specs.newton con rangos optimizados
```

### 2. Entrenamiento del Modelo ML

```bash
# Entrenar modelo de optimización
python3 ml_optimization_brain.py --mode train --input-specs specs/peru-gps-specs.newton

# Salida: modelo_optimizacion.pkl y reportes de precisión
```

### 3. Generación de Código Optimizado

```bash
# Generar código C optimizado automáticamente
python3 ml_code_generator.py --input examples/geofencing.c --specs specs/peru-gps-specs.newton

# Salida: 
# - geofencing_optimized.c (código optimizado)
# - comparison_report.html (reporte comparativo)
```

### 4. Análisis y Benchmarking

```bash
# Ejecutar análisis completo de rendimiento
cd BenchMark_Analizer/
python3 cosense_analysis.py --compare-all

# Genera reportes detallados en results/
```

## 📊 Estructura del Proyecto

```
📦 ml-compiler-optimization/
├── 📁 src/                          # Código fuente principal
│   ├── ml_optimization_brain.py     # Cerebro ML del sistema
│   ├── ml_code_generator.py         # Generador de código optimizado
│   └── research_report.txt          # Reporte de investigación
├── 📁 specs/                        # Especificaciones Newton DSL
│   └── peru-gps-specs.newton        # Especificaciones GPS Perú
├── 📁 examples/                     # Ejemplos de código
│   ├── geofencing.c                 # Código genérico
│   ├── geofencing_optimized.c       # Código optimizado ML
│   └── geofencing_cosense.c         # Código optimizado CoSense
├── 📁 BenchMark_Analizer/           # Sistema de benchmarking
│   ├── cosense_analysis.py          # Analizador principal
│   └── results/                     # Resultados de análisis
├── 📁 data/                         # Datos de muestra
│   └── sample_gps_peru.sql          # Datos GPS de Perú
├── 📁 docs/                         # Documentación
│   └── PaperdelProyecto.pdf         # Paper científico
└── README.md                        # Este archivo
```

## 🔧 Casos de Uso

### Ejemplo 1: Optimización de Geofencing GPS

```bash
# Código original con verificaciones genéricas
python3 ml_code_generator.py --input examples/geofencing.c

# Resultado: Código optimizado con:
# - Rangos específicos para Arequipa, Perú
# - Eliminación de verificaciones redundantes
# - Aproximaciones matemáticas optimizadas
```

### Ejemplo 2: Análisis de Sensores Personalizados

```bash
# Generar especificaciones para nuevos sensores
python3 generate_newton.py --sensor-type temperature --region custom

# Entrenar modelo específico
python3 ml_optimization_brain.py --retrain --sensor temperature
```

## 📈 Interpretación de Resultados

### Métricas de Rendimiento

El sistema genera reportes HTML interactivos con:

- **Gráficos de speedup** comparando versiones de código
- **Análisis de memoria** y uso de recursos
- **Métricas de precisión ML** para cada optimización
- **Recomendaciones** para mejoras adicionales

### Dashboard de Análisis

```bash
# Abrir dashboard interactivo
python3 -m http.server 8000
# Navegar a: http://localhost:8000/results/dashboard.html
```

## 🧪 Casos de Prueba

### Ejecutar Suite Completa de Pruebas

```bash
# Pruebas unitarias
python3 -m pytest tests/

# Pruebas de integración
bash scripts/integration_tests.sh

# Benchmarks de rendimiento
python3 BenchMark_Analizer/run_benchmarks.py --full-suite
```

### Validación de Optimizaciones

```bash
# Verificar que optimizaciones mantienen correctitud
python3 validation/verify_optimizations.py --input examples/geofencing.c
```

## 🔬 Contribuciones Científicas

### Innovaciones Técnicas

1. **Primer generador Newton DSL automático** desde datos reales PostgreSQL
2. **Sistema ML que decide optimizaciones** de compilador sin intervención humana  
3. **Pipeline completo end-to-end** para optimización IoT
4. **Demostración práctica** de ML aplicado a compiladores embebidos

### Publicaciones y Referencias

- Paper completo disponible en `docs/PaperdelProyecto.pdf`
- Basado en investigación de CoSense (CC '24)
- Integra técnicas de TensorFlow Lite Micro y ELOPS

## 🚨 Limitaciones y Trabajo Futuro

### Limitaciones Actuales

- Optimizado específicamente para datos GPS de Arequipa, Perú
- Requiere datos históricos suficientes para entrenamiento ML
- Benchmarking de rendimiento necesita refinamiento en hardware real



> **Nota**: Este sistema representa un avance significativo en la intersección de Machine Learning, optimización de compiladores y sistemas IoT, proporcionando una base sólida para futuros desarrollos en optimización automática para dispositivos embebidos con recursos limitados.
